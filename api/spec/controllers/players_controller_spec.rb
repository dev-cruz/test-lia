require "rails_helper"

RSpec.describe PlayersController, type: :controller do
  describe "GET #index" do
    it "returns a list of players as JSON" do
      mocked_players = [
        double("Player", id: 1, name: "Player 1", chips: 1000),
        double("Player", id: 2, name: "Player 2", chips: 2000),
        double("Player", id: 3, name: "Player 3", chips: 3000)
      ]

      allow(Player).to receive(:all).and_return(mocked_players)

      get :index

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to match_array(
        mocked_players.map { |player| player.as_json(only: [:id, :name, :chips]) }
      )
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      let(:valid_params) { { name: "New Player" } }

      it "creates a new player and returns its details" do
        new_player = Player.new(id: 1, name: "New Player", chips: 1000)
        allow(Player).to receive(:new).with(name: valid_params[:name], chips: 1000).and_return(new_player)
        allow(new_player).to receive(:valid?).and_return(true)
        allow(new_player).to receive(:save).and_return(true)

        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to eq(
          { "id" => new_player.id, "name" => new_player.name, "chips" => new_player.chips }
        )
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { name: "" } }

      it "does not create a player and returns errors" do
        invalid_player = Player.new
        allow(invalid_player).to receive(:valid?).and_return(false)
        allow(invalid_player).to receive_message_chain(:errors, :full_messages).and_return(["Name can't be blank"])

        post :create, params: invalid_params

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to eq(["Name can't be blank"])
      end
    end
  end

  describe "DELETE #destroy" do
    let(:player) { double("Player", id: 1) }

    context "when player exists" do
      it "deletes the player and returns success message" do
        allow(Player).to receive(:find).with(player.id.to_s).and_return(player)
        allow(player).to receive(:destroy).and_return(true)

        delete :destroy, params: { id: player.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ "message" => "Player deleted successfully" })
      end
    end

    context "when player does not exist" do
      it "returns not found error" do
        allow(Player).to receive(:find).with(player.id.to_s).and_raise(ActiveRecord::RecordNotFound)

        delete :destroy, params: { id: player.id }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq({ "error" => "Failed to delete entity" })
      end
    end
  end
end
