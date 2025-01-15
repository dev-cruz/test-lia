import { useState } from 'react';

const RegistrationModal = ({ isOpen, onRegister }) => {
  const [playerName, setPlayerName] = useState('');

  if (!isOpen) return null;

  const handleRegister = () => {
    if (playerName.trim()) {
      onRegister(playerName);
    } else {
      alert('Please enter a valid name!');
    }
  };

  return (
    <>
    <div className="modal-backdrop fade show"></div>
    <div className="modal show d-block" tabIndex="-1" role="dialog">
      <div className="modal-dialog" role="document">
        <div className="modal-content">
          <div className="modal-header">
            <h5 className="modal-title">Register User</h5>
          </div>
          <div className="modal-body">
            <input
              type="text"
              className="form-control"
              placeholder="Enter your name"
              value={playerName}
              onChange={(e) => setPlayerName(e.target.value)}
            />
          </div>
          <div className="modal-footer">
            <button className="btn btn-primary" onClick={handleRegister}>
              Register
            </button>
          </div>
        </div>
      </div>
    </div>
    </>
  );
};

export default RegistrationModal;
