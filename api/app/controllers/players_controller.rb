class PlayersController < ApplicationController
  def index
    render json: Player.all.as_json(only: [:id, :name, :chips])
  end

  def create
    player = Player.new(name: params["name"], chips: 1000)

    if player.valid?
      player.save
      render json: player.as_json(only: [:id, :name, :chips]), status: :created
    else
      render json: player.errors.full_messages, status: :bad_request
    end
  end

  def destroy
    player = Player.find(params[:id])
    player.destroy

    render json: { message: "Player deleted successfully" }
  rescue
      render json: { error: "Failed to delete entity" }, status: :not_found
  end
end
