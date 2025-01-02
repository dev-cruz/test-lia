import './App.css';
import { useState, useEffect } from 'react';
import { Routes, Route, useNavigate } from 'react-router-dom';
import { createPlayer, joinRoom, getRooms } from './services/api';
import RegistrationModal from './components/RegistrationModal';
import RoomsList from './components/RoomsList';
import Table from './components/Table';

function App() {
  const [isModalOpen, setModalOpen] = useState(false);
  const [availableRooms, setAvailableRooms] = useState([]);
  const [playerData, setPlayerData] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    const storedPlayer = localStorage.getItem('player');

    if (!storedPlayer) {
      setModalOpen(true);
    } else {
      setPlayerData(JSON.parse(storedPlayer));
    }

    const fetchRooms = async () => {
      const roomsResponse = await getRooms();
      const availableRooms = roomsResponse.data.filter(room => room.current_players.length < room.max_players);
      setAvailableRooms(availableRooms);
    };

    fetchRooms();
  }, []);

  const handlePlayerRegister = async (name) => {
    try {
      const { data } = await createPlayer(name);

      setPlayerData(data);
      localStorage.setItem('player', JSON.stringify(data));

      setModalOpen(false);
    } catch (err) {
      alert('Failed to create player.');
    }
  };

  const handleJoinRoom = async (roomId) => {
    try {
      await joinRoom(roomId, playerData.id);
      navigate(`/table/${roomId}`);
    } catch (err) {
      alert('Failed to join room.');
    }
  };

  const handleLogOut = () => {
    localStorage.removeItem('player');
    setPlayerData(null);
    setModalOpen(true);
  }

  return (
    <div className='d-flex flex-column bg-dark'>
      <Routes>
        <Route
          path='/'
          element={
            <>
              <RegistrationModal isOpen={isModalOpen} onRegister={handlePlayerRegister} />
              <RoomsList rooms={availableRooms} joinRoom={handleJoinRoom} />
              {playerData &&
                <div className='align-self-center mt-3'>
                  <button className='btn btn-danger' onClick={handleLogOut}>
                    Log Out
                  </button>
                </div>
              }
            </>
          }
        />
        <Route path='/table/:roomId' element={<Table />} />
      </Routes>
    </div>
  );
}

export default App;
