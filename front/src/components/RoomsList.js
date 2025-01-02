const RoomsList = ({ rooms, joinRoom }) => {
  return (
    <div className="card shadow-lg mx-auto my-4 border-0" style={{ maxWidth: '800px' }}>
      <div className="card-header bg-dark text-white text-center py-3">
        <h2 className="m-0">Available Rooms</h2>
      </div>
      <div className="list-group list-group-flush">
        {rooms.length > 0 ? (
          rooms.map((room) => (
            <button
              type="button"
              className="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
              key={room.id}
              onClick={() => joinRoom(room.id)}
            >
              <span className="fw-bold">{room.name}</span>
              <span className="badge bg-success rounded-pill">{room.current_players.length} Players</span>
            </button>
          ))
        ) : (
          <div className="text-center py-4 text-muted">
            <p className="m-0">No rooms available. Please create or wait for rooms to appear.</p>
          </div>
        )}
      </div>
    </div>
  );
};


export default RoomsList;
