require "rails_helper"

RSpec.describe RoomsController, type: :controller do
  describe "GET #index" do
    it "returns a list of rooms as JSON" do
      mocked_rooms = [
        double("Room", id: 1, name: "Room 1", max_players: 5),
        double("Room", id: 2, name: "Room 2", max_players: 10)
      ]

      allow(Room).to receive(:all).and_return(mocked_rooms)
      mocked_rooms.each { |mocked_room| allow(mocked_room).to receive(:current_players).and_return([]) }

      get :index

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to match_array(
        mocked_rooms.map { |room| room.as_json(only: [:id, :name, :max_players], methods: :current_players) }
      )
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      let(:valid_params) { { name: "Room 1", max_players: 5 } }

      it "creates a new room and returns its details" do
        mocked_room = double("Room", id: 1, name: "Room 1", max_players: 5)
        allow(mocked_room).to receive(:current_players).and_return([])
        allow(mocked_room).to receive(:valid?).and_return(true)
        allow(mocked_room).to receive(:save).and_return(true)

        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to eq(
          { "id" => mocked_room.id, "name" => mocked_room.name, "max_players" => mocked_room.max_players, "current_players" => mocked_room.current_players }
        )
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { name: "", max_players: 5 } }

      it "returns errors and does not create a room" do
        mocked_room = double("Room", name: "", max_players: 5)
        allow(mocked_room).to receive(:valid?).and_return(false)
        allow(mocked_room).to receive_message_chain(:errors, :full_messages).and_return(["Name can't be blank"])

        post :create, params: invalid_params

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to eq(["Name can't be blank"])
      end
    end
  end

  describe "GET #show" do
    it "returns the details of a specific room" do
      mocked_room = double("Room", id: 1, name: "Room 1", max_players: 5)
      allow(mocked_room).to receive(:current_players).and_return([1, 2, 3])
      allow(RoomService).to receive(:get_room).with("1").and_return(mocked_room)

      get :show, params: { id: 1 }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(
        mocked_room.as_json(except: [:created_at, :updated_at], methods: :current_players)
      )
    end
  end

  describe "POST #join" do
    it "allows a player to join a room" do
      mock_response = { "message" => "Player joined successfully" }
      allow(RoomService).to receive(:join_player).with("1", "2").and_return(mock_response)

      post :join, params: { id: 1, player_id: 2 }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(mock_response)
    end
  end

  describe "POST #leave" do
    it "allows a player to leave a room" do
      mock_response = { "message" => "Player left successfully" }
      allow(RoomService).to receive(:remove_player).with("1", "2").and_return(mock_response)

      post :leave, params: { id: 1, player_id: 2 }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(mock_response)
    end
  end

  describe "POST #start" do
    it "starts the game in a room" do
      mock_response = {
        "message" => "Game started",
        "inital_state" => {
          "players" => [1, 2],
          "community_cards" => [],
          "pot" => 0
        }
      }
      allow(RoomService).to receive(:start_game).with("1").and_return(mock_response)

      post :start, params: { id: 1 }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(mock_response)
    end
  end

  describe "POST #action" do
    it "registers a player action" do
      body_params = { "player_id" => 2, "player_action" => "bet", "amount" => 100 }
      player_action = { player_id: 2, action: "bet", amount: 100 }

      mock_response = {
        "message" => "Action performed successfully",
        "game_state" => {
          "current_turn" => 2,
          "pot" => 100,
          "current_bet" => 100
        }
      }

      allow(PlayerActionService).to receive(:register_action).with(player_action).and_return(mock_response)
    
      post :action, params: { id: 1 }.merge(body_params)
    
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(mock_response)
    end      
  end

  describe "POST #next_phase" do
    it "proceeds to the next phase in the game" do
      mock_response = { "phase" => "flop", "community_cards" => ["AS", "KD", "7C"] }
      allow(RoomService).to receive(:next_phase).with("1").and_return(mock_response)

      post :next_phase, params: { id: 1 }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(mock_response)
    end
  end

  describe "POST #end" do
    it "ends the game in a room" do
      mock_response = {
        "winner" => {
          "player_id" => 1,
          "hand" => "straight"
        },
        "pot" => 500
      }
      allow(RoomService).to receive(:finish_game).with("1").and_return(mock_response)

      post :end, params: { :id => 1 }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(mock_response)
    end
  end
end
