import { render, screen, fireEvent } from '@testing-library/react';
import RoomsList from './RoomsList';

describe('RoomsList Component', () => {
  const mockJoinRoom = jest.fn();

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('renders the header correctly', () => {
    render(<RoomsList rooms={[]} joinRoom={mockJoinRoom} />);
    expect(screen.getByText(/available rooms/i)).toBeInTheDocument();
  });

  it('displays a message when no rooms are available', () => {
    render(<RoomsList rooms={[]} joinRoom={mockJoinRoom} />);
    expect(screen.getByText(/no rooms available/i)).toBeInTheDocument();
  });

  it('renders a list of rooms when they are available', () => {
    const rooms = [
      { id: 1, name: 'Room 1', current_players: ['Player 1', 'Player 2'] },
      { id: 2, name: 'Room 2', current_players: [] },
    ];

    render(<RoomsList rooms={rooms} joinRoom={mockJoinRoom} />);

    expect(screen.getByText(/room 1/i)).toBeInTheDocument();
    expect(screen.getByText(/room 2/i)).toBeInTheDocument();
    expect(screen.getByText(/2 players/i)).toBeInTheDocument();
    expect(screen.getByText(/0 players/i)).toBeInTheDocument();
  });

  it('calls joinRoom when a room is clicked', () => {
    const rooms = [
      { id: 1, name: 'Room 1', current_players: ['Player 1', 'Player 2'] },
    ];

    render(<RoomsList rooms={rooms} joinRoom={mockJoinRoom} />);

    const roomButton = screen.getByRole('button', { button: /room 1/i });
    fireEvent.click(roomButton);

    expect(mockJoinRoom).toHaveBeenCalledTimes(1);
    expect(mockJoinRoom).toHaveBeenCalledWith(1);
  });
});
