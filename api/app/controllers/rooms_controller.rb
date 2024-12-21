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

  def join
    room = Room.find(params[:id])

    if room.current_players.count == room.max_players
      render json: { message: "Room is already full" }
    else
      player = Player.find(params["player_id"])
      player.room_id = room.id
      player.save
  
      render json: { message: "Player joined successfully" }
    end
  end

  def leave
    room = Room.find(params[:id])
    player = Player.find(params["player_id"])
    player.room_id = nil
    player.save

    render json: { message: "Player left successfully" }
  end

  def start
    room = Room.find(params[:id])
  end
end