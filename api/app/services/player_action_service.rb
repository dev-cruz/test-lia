class PlayerActionService
  def self.register_action(player_action)
    player = Player.find(player_action[:player_id])
    action = player_action[:action]
    room = Room.find(player.room_id)
    is_player_turn = room.current_players[room.current_turn - 1] == player.id

    return error_response("Player is inactive", room) unless player.is_active
    return error_response("Player does not belong to the room") unless player.room_id == room.id

    case action
    when "bet"
      handle_bet(player, room, player_action[:amount])
    when "check"
      handle_check(player, room)
    when "call"
      handle_call(player, room)
    when "raise"
      handle_raise(player, room, player_action[:amount])
    when "fold"
      handle_fold(player, room)
    else
      error_response("Invalid action", room)
    end
  end

  private

  def self.handle_bet(player, room, amount)
    if room.current_bet > 0
      return error_response("There is already a bet on the table", room)
    end

    if amount > player.chips
      return error_response("Insufficient chips to bet")
    end

    ActiveRecord::Base.transaction do
      player.update!(chips: player.chips - amount)
      room.update!(pot: room.pot + amount, current_bet: amount, current_turn: room.current_turn + 1)
    end

    success_response(room)
  end

  def self.handle_check(player, room)
    ActiveRecord::Base.transaction do
      room.update!(current_turn: room.current_turn + 1)
    end

    success_response(room)
  end

  def self.handle_call(player, room)
    if room.current_bet == 0
      return error_response("There is no current bet to call for", room)
    end

    if room.current_bet > player.chips
      return error_response("Insufficient chips to call")
    end

    ActiveRecord::Base.transaction do
      player.update!(chips: player.chips - room.current_bet)
      room.update!(pot: room.pot + room.current_bet, current_turn: room.current_turn + 1)
    end

    success_response(room)
  end

  def self.handle_raise(player, room, amount)
    if room.current_bet == 0
      return error_response("There is no current bet to raise", room)
    end

    total_bet = room.current_bet + amount
    if total_bet > player.chips
      return error_response("Insufficient chips to raise")
    end

    ActiveRecord::Base.transaction do
      player.update!(chips: player.chips - total_bet)
      room.update!(pot: room.pot + total_bet, current_bet: total_bet, current_turn: room.current_turn + 1)
    end

    success_response(room)
  end

  def self.handle_fold(player, room)
    ActiveRecord::Base.transaction do
      player.update!(is_active: false)
      room.update!(current_turn: room.current_turn + 1)
    end

    success_response(room)
  end

  def self.error_response(message, room)
    {
      message: "Invalid action: #{message}",
      game_state: { current_turn: room.current_turn, pot: room.pot }
    }
  end

  def self.success_response(room)
    {
      message: "Action performed successfully",
      game_state: {
        current_turn: room.current_turn,
        pot: room.pot
      }
    }
  end
end