class RoomService
  @@suits = ["H", "D", "S", "C"]
  @@ranks = ["A", "K", "Q", "J", "10", "9", "8", "7", "6", "5", "4", "3", "2"]
  @@phases = ["pre-flop", "flop", "turn", "river"]
  @@hands_rank = [
    "high_card",
    "one_pair",
    "two_pair",
    "three_of_a_kind",
    "straight",
    "flush",
    "full_house",
    "four_of_a_kind",
    "straight_flush",
    "royal_flush"
  ]

  def self.join_player(room_id, player_id)
    room = Room.find(room_id)

    return { message: "Room is already full" } unless room.current_players.count < room.max_players

    player = Player.find(player_id)
    player.update!(room_id: room.id)
  
    { message: "Player joined successfully" }
  end

  def self.get_room(room_id)
    room = Room.find(room_id)
    community_cards = community_cards_by_phase(room.community_cards, room.phase)
    room.community_cards = community_cards
    room
  end

  def self.remove_player(room_id, player_id)
    room = Room.find(room_id)
    player = Player.find(player_id)
    player.update!(room_id: nil)

    { message: "Player left successfully" }
  end

  def self.start_game(room_id)
    room = Room.find(room_id)
    deck = generate_deck()
    players = Player.where(id: room.current_players)

    return { message: "Not enough players to start the game" } unless players.count >= 2
    return { message: "Game already started" } if room.phase

    ActiveRecord::Base.transaction do
      players.each do | player |
        player.update!(cards: deck.shuffle!.pop(2))
      end
  
      room.update!(community_cards: deck.shuffle!.pop(5), phase: "pre-flop")
    end

    {
      message: "Game started",
      initial_state: {
        players: players,
        community_cards: community_cards_by_phase(room.community_cards, room.phase),
        pot: room.pot
      }
    }
  end

  def self.next_phase(room_id)
    room = Room.find(room_id)

    return { message: "There is no next phase" } if room.phase == "river"

    next_phase = @@phases[(@@phases.index room.phase) + 1]
    room.update!(phase: next_phase, current_bet: 0, current_turn: 1)

    {
      phase: room.phase,
      community_cards: community_cards_by_phase(room.community_cards, room.phase)
    }
  end

  def self.finish_game(room_id)
    room = Room.find(room_id)
    players = Player.where(id: room.current_players)
    player_by_hand_index = {}

    players.each do |player|
      all_cards = player.cards + room.community_cards
      player_hand = HandEvaluator.check_combination(all_cards)
      player_by_hand_index[player.id] = @@hands_rank.index player_hand
    end

    winner_id, hand_index = player_by_hand_index.max_by { |player_id, ranked_hand| ranked_hand }
    winner_player = Player.find(winner_id)
    winner_hand = @@hands_rank[hand_index]
    winner_pot = room.pot

    ActiveRecord::Base.transaction do
      winner_player.update!(chips: winner_player.chips + winner_pot)
      room.update!(phase: "pre-flop", current_bet: 0, current_turn: 1, pot: 0)
    end

    {
      winner: {
        player_id: winner_id,
        hand: winner_hand
      },
      pot: winner_pot
    }
  end

  private

  def self.generate_deck
    @@ranks.product(@@suits).map { |card, suit| "#{card}#{suit}" }
  end

  def self.community_cards_by_phase(community_cards, phase)
    cards_by_phase = {"pre-flop" => 0, "flop" => 3, "turn" => 4, "river" => 5}
    community_cards.slice(0, cards_by_phase[phase])
  end
end