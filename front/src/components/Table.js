import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { getRoom, startGame, playerAction, nextPhase, finishGame } from '../services/api';
import './Table.css';
import Card from './Card';

const Table = () => {
  const [roomData, setRoomData] = useState(null);
  const [communityCards, setCommunityCards] = useState([]);
  const [betAmount, setBetAmount] = useState('');
  const [winner, setWinner] = useState(null);
  const { roomId } = useParams();
  const [currentPlayer, setCurrentPlayer] = useState(
    JSON.parse(localStorage.getItem('player'))
  );

  useEffect(() => {
    const fetchRoomData = async () => {
      try {
        const { data } = await getRoom(roomId);
        const players = data.current_players.map((player_id) => ({ id: player_id }));
        setRoomData({ ...data, players });
        setCommunityCards(data.community_cards || []);
      } catch (err) {
        console.error('Failed to fetch room data:', err);
      }
    };
  
    fetchRoomData();
  }, [roomId]);
  

  const handleStartGame = async () => {
    try {
      const { data } = await startGame(roomId);
      setRoomData({ ...roomData, ...data.initial_state});

      const currentPlayerData = roomData.players.find(player => player.id === currentPlayer.id);
      const updatedCurrentPlayer = { ...currentPlayer, ...currentPlayerData };
      setCurrentPlayer(updatedCurrentPlayer);
      localStorage.setItem('player', JSON.stringify(updatedCurrentPlayer));
    } catch (err) {
      console.error('Failed to start game.', err);
      alert('Failed to start game.');
    }
  };

  const handlePlayerAction = async (action, amount = null) => {
    try {
      const payload = { player_action: action, player_id: currentPlayer.id };
      if (amount) payload.amount = parseInt(amount, 10);
      await playerAction(roomId, payload);
    } catch (err) {
      console.error('Failed to perform action:', err);
      alert('Could not perform action.');
    }
  };

  const handleNextPhase = async () => {
    try {
      const { data } = await nextPhase(roomId);
      setRoomData({ ...roomData, phase: data.phase });
      setCommunityCards(data.community_cards);
    } catch (err) {
      console.error('Failed to proceed to next phase:', err);
      alert('Could not proceed to next phase.');
    }
  };

  const handleFinishGame = async () => {
    try {
      const { data } = await finishGame(roomId);
      setWinner(data.winner);
      alert(`Game Finished! Winner: Player ${data.winner.player_id} with hand ${data.winner.hand}`);
    } catch (err) {
      console.error('Failed to finish the game:', err);
      alert('Failed to finish the game.');
    }
  };

  if (!roomData) {
    return <div>Loading...</div>;
  }

  return (
    <div className='table-container p-3'>
      <div className='poker-table d-flex justify-content-center align-items-center'>
        <div>
          <div className="table-info">
            <p>Phase: {roomData.phase}</p>
            <p>Pot: {roomData.pot}</p>
            <p>Current Bet: {roomData.current_bet}</p>
            <div className="community-cards">
              {communityCards.map((card) => (
                <Card card={card} key={card} />
              ))}
          </div>
          </div>
        </div>
        {roomData.players.map((player ,index) => {
          const angle = (360 / roomData.players.length) * index;
          const x = 50 + 60 * Math.cos((angle * Math.PI) / 180);
          const y = 50 + 60 * Math.sin((angle * Math.PI) / 180);
          
          return(
            <div
              key={player.id}
              className={`player-seat ${player.id === currentPlayer.id ? 'current-player' : ''}`}
              style={{
                top: `${y}%`,
                left: `${x}%`,
                transform: 'translate(-50%, -50%)',
              }}
            >
              <div className='player-info'>
                <p className='mb-0'>Player {player.id} {player.id === currentPlayer.id ? '(You)' : ''}</p>
              </div>
            </div>
          )
        })}
      </div>
      <div className="player-interface">
        <div className="player-cards mt-3">
          <h4>Your Cards:</h4>
          <div className="cards">
            {currentPlayer.cards
              ? currentPlayer.cards.map((card) => <Card card={card} key={card} />)
              : 'No cards yet.'}
          </div>
        </div>
        {roomData.phase ? (
          <div className="actions mt-3">
            <button
              className="btn btn-success"
              onClick={() => handlePlayerAction('call')}
            >
              Call
            </button>
            <button
              className="btn btn-warning"
              onClick={() => handlePlayerAction('fold')}
            >
              Fold
            </button>
            <div className="action-with-input mt-3">
              <input
                type="number"
                className="form-control"
                value={betAmount}
                onChange={(e) => setBetAmount(e.target.value)}
                placeholder="Enter amount"
              />
              <div className="mt-2">
                <button
                  className="btn btn-info"
                  onClick={() => handlePlayerAction('bet', betAmount)}
                >
                  Bet
                </button>
                <button
                  className="btn btn-secondary ms-2"
                  onClick={() => handlePlayerAction('raise', betAmount)}
                >
                  Raise
                </button>
              </div>
            </div>
            <button className="btn btn-secondary mt-3" onClick={handleNextPhase}>
              Next Phase
            </button>
            {roomData?.phase === 'river' && (
            <>
              {winner && 
                <div className="alert alert-success mt-3">
                  <strong>Winner: Player {winner.player_id} with hand {winner.hand}</strong>
                </div>
              }
              <button className="btn btn-danger mt-3" onClick={handleFinishGame}>
                Finish Game
              </button>
            </>
          )}
          </div>
        ) : (
          <div className="d-flex justify-content-center align-items-center my-3">
            <button className="btn btn-primary" onClick={handleStartGame}>
              Start Game
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

export default Table;
