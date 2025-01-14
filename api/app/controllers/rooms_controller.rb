class RoomsController < ApplicationController
  def index
    render json: Room.all.as_json(only: [:id, :name, :max_players], methods: :current_players)
  end

  def create
    room = Room.new(name: params["name"], max_players: params["max_players"])

    if room.valid?
      room.save
      render json: room.as_json(only: [:id, :name, :max_players], methods: :current_players), status: :created
    else
      render json: room.errors.full_messages, status: :bad_request
    end
  end

  def show
    room = RoomService.get_room(params[:id])

    render json: room.as_json(except: [:created_at, :updated_at], methods: :current_players)
  end

  def join
    response = RoomService.join_player(params[:id], params["player_id"])
    render json: response
  end

  def leave
    response = RoomService.remove_player(params[:id], params["player_id"])
    render json: response
  end

  def start
    response = RoomService.start_game(params[:id])
    render json: response
  end

  def action
    player_action = { player_id: params["player_id"].to_i, action: params["player_action"], amount: params["amount"].to_i }
    response = PlayerActionService.register_action(player_action)

    render json: response
  end

  def next_phase
    response = RoomService.next_phase(params[:id])
    render json: response
  end

  def end
    response = RoomService.finish_game(params[:id])
    render json: response
  end
end