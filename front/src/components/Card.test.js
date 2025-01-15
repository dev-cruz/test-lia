import React from 'react';
import { render, screen } from '@testing-library/react';
import Card from './Card';

describe('Card Component', () => {
  it('renders correctly with a valid card prop', () => {
    render(<Card card="AH" />);

    const cardImage = screen.getByRole('img', { name: /AH/i });
    expect(cardImage).toBeInTheDocument();
    expect(cardImage).toHaveAttribute('src', '/assets/cards/AH.svg');
    expect(cardImage).toHaveClass('card-svg');
  });

  it('does not render anything when the card prop is null', () => {
    render(<Card card={null} />);
    expect(screen.queryByRole('img')).not.toBeInTheDocument();
  });

  it('does not render anything when the card prop is undefined', () => {
    render(<Card card={undefined} />);
    expect(screen.queryByRole('img')).not.toBeInTheDocument();
  });
});
