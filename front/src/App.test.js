import { render, screen, fireEvent, waitFor } from '@testing-library/react';
// import { MemoryRouter } from 'react-router-dom';
import App from './App';
import * as api from './services/api';

jest.mock('./services/api', () => ({
  getRooms: jest.fn(),
  createPlayer: jest.fn(),
  joinRoom: jest.fn(),
}));

describe('App Component', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  test('opens registration modal if no player in localStorage', () => {
    render(
        <App />
    );

    expect(screen.getByText(/register/i)).toBeInTheDocument();
  });

  test('registers a player successfully', async () => {
    const mockPlayer = { id: 1, name: 'John Doe' };
    api.createPlayer.mockResolvedValueOnce({ data: mockPlayer });

    render(
        <App />
    );

    fireEvent.change(screen.getByLabelText(/name/i), { target: { value: 'John Doe' } });
    fireEvent.click(screen.getByText(/register/i));

    await waitFor(() => expect(screen.queryByText(/register/i)).not.toBeInTheDocument());

    expect(localStorage.getItem('player')).toEqual(JSON.stringify(mockPlayer));
  });

  test('fetches and displays available rooms', async () => {
    const mockRooms = [
      { id: 1, current_players: [], max_players: 4 },
      { id: 2, current_players: [1], max_players: 4 },
    ];
    api.getRooms.mockResolvedValueOnce({ data: mockRooms });

    render(
        <App />
    );

    await screen.findByText(/room 1/i);
    expect(screen.getByText(/room 2/i)).toBeInTheDocument();
  });

  test('allows player to join a room', async () => {
    const mockPlayer = { id: 1, name: 'John Doe' };
    const mockRooms = [
      { id: 1, current_players: [], max_players: 4 },
    ];
    api.getRooms.mockResolvedValueOnce({ data: mockRooms });
    api.joinRoom.mockResolvedValueOnce({});

    localStorage.setItem('player', JSON.stringify(mockPlayer));

    render(
        <App />
    );

    await screen.findByText(/room 1/i);

    fireEvent.click(screen.getByText(/join/i));

    expect(api.joinRoom).toHaveBeenCalledWith(1, mockPlayer.id);
  });

  test('logs out the player', () => {
    const mockPlayer = { id: 1, name: 'John Doe' };
    localStorage.setItem('player', JSON.stringify(mockPlayer));

    render(
        <App />
    );

    fireEvent.click(screen.getByText(/log out/i));

    expect(screen.getByText(/register/i)).toBeInTheDocument();
    expect(localStorage.getItem('player')).toBeNull();
  });
});
