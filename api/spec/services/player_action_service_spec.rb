require "rails_helper"

RSpec.describe PlayerActionService do
  describe "register_action" do
    let(:player) { double("Player", id: 1, room_id: 1, chips: 1000, is_active: true) }
    let(:room) { double("Room", id: 1, pot: 500, current_bet: 0, current_turn: 1, current_players: [1, 2]) }

    before do
      allow(Player).to receive(:find).with(player.id).and_return(player)
      allow(Room).to receive(:find).with(room.id).and_return(room)
      allow(room).to receive(:current_players).and_return([1, 2])
    end

    context "when player is inactive" do
      before { allow(player).to receive(:is_active).and_return(false) }

      it "returns an error response" do
        result = described_class.register_action({ player_id: player.id, action: "bet", amount: 100 })

        expect(result[:message]).to eq("Invalid action: Player is inactive")
        expect(result[:game_state][:current_turn]).to eq(room.current_turn)
        expect(result[:game_state][:pot]).to eq(room.pot)
      end
    end

    context "when player does not belong to the room" do
      let(:room) { double("Room", id: 1, current_turn: 1, pot: 0) }
      let(:player) { double("Player", id: 1, room_id: 2, is_active: true) }

      before do
        allow(Player).to receive(:find).with(player.id).and_return(player)
        allow(Room).to receive(:find).with(player.room_id).and_return(room)
      end

      it "returns an error response" do
        result = described_class.register_action({ player_id: player.id, action: "bet", amount: 100 })

        expect(result[:message]).to eq("Invalid action: Player does not belong to the room")
      end
    end

    context "when action is 'bet'" do
      context "with a valid bet" do
        it "updates the player's chips and room's pot, and returns a success response" do
          bet_amount = 100
          expect(player).to receive(:update!).with(chips: player.chips - bet_amount)
          expect(room).to receive(:update!).with(pot: room.pot + bet_amount, current_bet: bet_amount, current_turn: room.current_turn + 1)

          result = described_class.register_action({ player_id: player.id, action: "bet", amount: bet_amount })

          expect(result[:message]).to eq("Action performed successfully")
          expect(result[:game_state][:pot] + bet_amount).to eq(room.pot + bet_amount)
        end
      end

      context "when there is already a bet" do
        before { allow(room).to receive(:current_bet).and_return(50) }

        it "returns an error response" do
          result = described_class.register_action({ player_id: player.id, action: "bet", amount: 100 })

          expect(result[:message]).to eq("Invalid action: There is already a bet on the table")
        end
      end

      context "when the player has insufficient chips" do
        before { allow(player).to receive(:chips).and_return(50) }

        it "returns an error response" do
          result = described_class.register_action({ player_id: player.id, action: "bet", amount: 100 })

          expect(result[:message]).to eq("Invalid action: Insufficient chips to bet")
        end
      end
    end

    context "when action is 'check'" do
      it "updates the room's turn and returns a success response" do
        expect(room).to receive(:update!).with(current_turn: room.current_turn + 1)

        result = described_class.register_action({ player_id: player.id, action: "check" })

        expect(result[:message]).to eq("Action performed successfully")
        expect(result[:game_state][:current_turn] + 1).to eq(room.current_turn + 1)
      end
    end

    context "when action is 'call'" do
      before { allow(room).to receive(:current_bet).and_return(100) }

      context "with sufficient chips" do
        it "updates the player's chips and room's pot, and returns a success response" do
          expect(player).to receive(:update!).with(chips: player.chips - room.current_bet)
          expect(room).to receive(:update!).with(pot: room.pot + room.current_bet, current_turn: room.current_turn + 1)

          result = described_class.register_action({ player_id: player.id, action: "call" })

          expect(result[:message]).to eq("Action performed successfully")
        end
      end

      context "with insufficient chips" do
        before { allow(player).to receive(:chips).and_return(50) }

        it "returns an error response" do
          result = described_class.register_action({ player_id: player.id, action: "call" })

          expect(result[:message]).to eq("Invalid action: Insufficient chips to call")
        end
      end
    end

    context "when action is 'fold'" do
      it "marks the player as inactive and updates the room's turn" do
        expect(player).to receive(:update!).with(is_active: false)
        expect(room).to receive(:update!).with(current_turn: room.current_turn + 1)

        result = described_class.register_action({ player_id: player.id, action: "fold" })

        expect(result[:message]).to eq("Action performed successfully")
      end
    end

    context "when action is invalid" do
      it "returns an error response" do
        result = described_class.register_action({ player_id: player.id, action: "invalid_action" })

        expect(result[:message]).to eq("Invalid action: Invalid action")
      end
    end
  end
end
