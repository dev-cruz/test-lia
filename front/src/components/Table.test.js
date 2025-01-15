import React from 'react';
import { render, screen, fireEvent, act } from '@testing-library/react';
import { MemoryRouter, Route } from 'react-router-dom';
import Table from './Table';
import * as api from '../services/api';

jest.mock('../services/api');

const mockRoomData = {
  phase: 'pre-flop',
  pot: 1000,
  current_bet: 50,
  community_cards: ['AH', 'KH', 'QH'],
  current_players: [1, 2],
  players: [
    { id: 1, cards: ['2H', '3H'], chips: 1000 },
    { id: 2, cards: ['4H', '5H'], chips: 800 },
  ],
};

const mockPlayer = { id: 1, cards: ['2H', '3H'], chips: 1000 };

describe('Table Component', () => {
  beforeEach(() => {
    localStorage.setItem('player', JSON.stringify(mockPlayer));
    jest.clearAllMocks();
  });

  const renderTable = async () => {
    await act(async () => {
      render(
        <MemoryRouter initialEntries={['/table/1']}>
          <Route path="/table/:roomId">
            <Table />
          </Route>
        </MemoryRouter>
      );
    });
  };

  it('renders loading state initially', async () => {
    api.getRoom.mockResolvedValueOnce({ data: mockRoomData });

    await renderTable();

    expect(screen.getByText(/Loading/i)).toBeInTheDocument();
  });

  it('renders room details and community cards after loading', async () => {
    api.getRoom.mockResolvedValueOnce({ data: mockRoomData });

    await renderTable();

    expect(screen.getByText(/Phase: pre-flop/i)).toBeInTheDocument();
    expect(screen.getByText(/Pot: 1000/i)).toBeInTheDocument();
    expect(screen.getByText(/Current Bet: 50/i)).toBeInTheDocument();

    const communityCards = screen.getAllByRole('img');
    expect(communityCards).toHaveLength(3);
    expect(communityCards[0]).toHaveAttribute('alt', 'AH');
    expect(communityCards[1]).toHaveAttribute('alt', 'KH');
    expect(communityCards[2]).toHaveAttribute('alt', 'QH');
  });

  it('handles the start game action', async () => {
    api.getRoom.mockResolvedValueOnce({ data: mockRoomData });
    api.startGame.mockResolvedValueOnce({
      data: { initial_state: { phase: 'flop', community_cards: ['AH', 'KH', 'QH'] } },
    });

    await renderTable();

    const startButton = screen.getByText(/Start Game/i);
    expect(startButton).toBeInTheDocument();

    await act(async () => {
      fireEvent.click(startButton);
    });

    expect(api.startGame).toHaveBeenCalledWith('1');
    expect(screen.getByText(/Phase: flop/i)).toBeInTheDocument();
  });

  it('handles player actions like call', async () => {
    api.getRoom.mockResolvedValueOnce({ data: mockRoomData });
    api.playerAction.mockResolvedValueOnce({});

    await renderTable();

    const callButton = screen.getByText(/Call/i);
    expect(callButton).toBeInTheDocument();

    await act(async () => {
      fireEvent.click(callButton);
    });

    expect(api.playerAction).toHaveBeenCalledWith('1', { player_action: 'call', player_id: 1 });
  });

  it('handles bet and updates input value', async () => {
    api.getRoom.mockResolvedValueOnce({ data: mockRoomData });
    api.playerAction.mockResolvedValueOnce({});

    await renderTable();

    const betInput = screen.getByPlaceholderText(/Enter amount/i);
    fireEvent.change(betInput, { target: { value: '200' } });
    expect(betInput.value).toBe('200');

    const betButton = screen.getByText(/Bet/i);
    await act(async () => {
      fireEvent.click(betButton);
    });

    expect(api.playerAction).toHaveBeenCalledWith('1', { player_action: 'bet', player_id: 1, amount: 200 });
  });

  it('handles finishing the game and displays the winner', async () => {
    api.getRoom.mockResolvedValueOnce({ data: mockRoomData });
    api.finishGame.mockResolvedValueOnce({
      data: {
        winner: { player_id: 1, hand: 'Royal Flush' },
      },
    });

    await renderTable();

    const finishButton = screen.getByText(/Finish Game/i);
    expect(finishButton).toBeInTheDocument();

    await act(async () => {
      fireEvent.click(finishButton);
    });

    expect(api.finishGame).toHaveBeenCalledWith('1');
    expect(screen.getByText(/Winner: Player 1 with hand Royal Flush/i)).toBeInTheDocument();
  });
});
