require "rails_helper"

RSpec.describe RoomService, type: :service do
  describe "join_player" do
    it "allows a player to join if the room is not full" do
      room = double("Room", id: 1, current_players: [1], max_players: 2)
      player = double("Player", id: 2)

      allow(Room).to receive(:find).with(1).and_return(room)
      allow(room.current_players).to receive(:count).and_return(1)
      allow(Player).to receive(:find).with(2).and_return(player)
      allow(player).to receive(:update!)

      result = described_class.join_player(1, 2)

      expect(result).to eq({ message: "Player joined successfully" })
      expect(player).to have_received(:update!).with(room_id: room.id)
    end

    it "returns an error if the room is full" do
      room = double("Room", id: 1, current_players: [1, 2], max_players: 2)

      allow(Room).to receive(:find).with(1).and_return(room)
      allow(room.current_players).to receive(:count).and_return(2)

      result = described_class.join_player(1, 2)

      expect(result).to eq({ message: "Room is already full" })
    end
  end

  describe "get_room" do
    it "returns a room with the community cards filtered by phase" do
      room = double("Room", id: 1, phase: "flop", community_cards: %w[AH KH QH JH 10H])

      allow(Room).to receive(:find).with(1).and_return(room)
      allow(room).to receive(:community_cards=)

      result = described_class.get_room(1)

      expect(room).to have_received(:community_cards=).with(%w[AH KH QH])
      expect(result).to eq(room)
    end
  end

  describe "remove_player" do
    it "removes a player from a room" do
      room = double("Room", id: 1)
      player = double("Player", id: 2)

      allow(Room).to receive(:find).with(1).and_return(room)
      allow(Player).to receive(:find).with(2).and_return(player)
      allow(player).to receive(:update!)

      result = described_class.remove_player(1, 2)

      expect(result).to eq({ message: "Player left successfully" })
      expect(player).to have_received(:update!).with(room_id: nil)
    end
  end

  describe "start_game" do
    it "starts the game when there are enough players" do
      room = double("Room", id: 1, phase: nil, pot: 0)
      players = [double("Player", id: 1, cards: nil), double("Player", id: 2, cards: nil)]
      deck = ["AH", "KH", "QH", "JH", "10H", "9H", "8H", "7H", "6H"]

      allow(Room).to receive(:find).with(1).and_return(room)
      allow(room).to receive(:current_players).and_return([1, 2])
      allow(Player).to receive(:where).with(id: room.current_players).and_return(players)
      allow(RoomService).to receive(:generate_deck).and_return(deck)

      allow(room).to receive(:update!) do |attributes|
        attributes.each { |key, value| allow(room).to receive(key).and_return(value) }
      end
      
      players.each { |player| allow(player).to receive(:update!) }

      result = described_class.start_game(1)

      expect(result[:message]).to eq("Game started")
      expect(result[:initial_state][:players]).to eq(players)
      expect(result[:initial_state][:community_cards].size).to eq(0)
      expect(result[:initial_state][:pot]).to eq(room.pot)
    end

    it "returns an error if there are not enough players" do
      room = double("Room", id: 1, phase: nil)
      players = [double("Player", id: 1)]

      allow(Room).to receive(:find).with(1).and_return(room)
      allow(room).to receive(:current_players).and_return([1, 2])
      allow(Player).to receive(:where).with(id: room.current_players).and_return(players)

      result = described_class.start_game(1)

      expect(result).to eq({ message: "Not enough players to start the game" })
    end

    it "returns an error if the game is already started" do
      room = double("Room", id: 1, phase: "pre-flop")

      allow(Room).to receive(:find).with(1).and_return(room)

      result = described_class.start_game(1)

      expect(result).to eq({ message: "Game already started" })
    end
  end

  describe "next_phase" do
    it "advances to the next phase" do
      room = double("Room", id: 1, phase: "flop", community_cards: ["AH", "KH", "QH", "JH", "10H"])

      allow(Room).to receive(:find).with(1).and_return(room)
      allow(room).to receive(:update!) do |attributes|
        attributes.each { |key, value| allow(room).to receive(key).and_return(value) }
      end

      result = described_class.next_phase(1)

      expect(result[:phase]).to eq("turn")
      expect(result[:community_cards]).to eq(["AH", "KH", "QH", "JH"])
    end
  end

  describe "finish_game" do
    let(:room) do
      double(
        "Room",
        id: 1,
        community_cards: ["AD", "7D", "8D", "JH", "6S"],
        current_players: [1, 2],
        pot: 1000,
        phase: "river",
        current_bet: 50,
        current_turn: 1
      )
    end

    let(:player1) { double("Player", id: 1, chips: 500, cards: ["2D", "3D"]) }
    let(:player2) { double("Player", id: 2, chips: 700, cards: ["4S", "5S"]) }

    before do
      allow(Room).to receive(:find).with(room.id).and_return(room)
      allow(Player).to receive(:where).and_return([player1, player2])
      allow(HandEvaluator).to receive(:check_combination).with(player1.cards + room.community_cards).and_return("flush")
      allow(HandEvaluator).to receive(:check_combination).with(player2.cards + room.community_cards).and_return("straight")
      allow(Player).to receive(:find).with(player1.id).and_return(player1)
      allow(room).to receive(:update!)
      allow(player1).to receive(:update!)
      allow(player2).to receive(:update!)
    end

    it "declares the correct winner, updates the chips, and resets the room state" do
      result = described_class.finish_game(room.id)

      expect(result[:winner][:player_id]).to eq(player1.id)
      expect(result[:winner][:hand]).to eq("flush")
      expect(result[:pot]).to eq(room.pot)

      expect(player1).to have_received(:update!).with(chips: player1.chips + room.pot)
      expect(room).to have_received(:update!).with(phase: "pre-flop", current_bet: 0, current_turn: 1, pot: 0)
    end
  end
end
