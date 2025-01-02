import axios from 'axios';

const API = axios.create({
  baseURL: 'http://localhost:3000',
});

export const createPlayer = (name) => API.post('/players', { name });
export const deletePlayer = (id) => API.delete(`/players/${id}`);
export const createRoom = (room) => API.post('/rooms', room);
export const getRooms = () => API.get('/rooms');
export const getRoom = (id) => API.get(`/rooms/${id}`);
export const joinRoom = (roomId, playerId) => API.post(`/rooms/${roomId}/join`, { player_id: playerId });
export const leaveRoom = (roomId, playerId) => API.post(`/rooms/${roomId}/leave`, { player_id: playerId });
export const startGame = (roomId) => API.post(`/rooms/${roomId}/start`);

export default API;