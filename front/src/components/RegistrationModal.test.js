import { render, screen, fireEvent } from '@testing-library/react';
import RegistrationModal from './RegistrationModal';

describe('RegistrationModal', () => {
  it('does not render when isOpen is false', () => {
    render(<RegistrationModal isOpen={false} onRegister={jest.fn()} />);
    expect(screen.queryByText(/register/i)).not.toBeInTheDocument();
  });

  it('renders correctly when isOpen is true', () => {
    render(<RegistrationModal isOpen={true} onRegister={jest.fn()} />);
    expect(screen.getByText(/register user/i)).toBeInTheDocument();
    expect(screen.getByPlaceholderText(/enter your name/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /register/i })).toBeInTheDocument();
  });

  it('calls onRegister with the entered name when valid input is provided', () => {
    const mockOnRegister = jest.fn();
    render(<RegistrationModal isOpen={true} onRegister={mockOnRegister} />);

    const input = screen.getByPlaceholderText(/enter your name/i);
    const button = screen.getByRole('button', { name: /register/i });

    fireEvent.change(input, { target: { value: 'John Doe' } });
    fireEvent.click(button);

    expect(mockOnRegister).toHaveBeenCalledWith('John Doe');
  });

  it('shows an alert if the input is empty', () => {
    window.alert = jest.fn(); // Mock the alert function

    render(<RegistrationModal isOpen={true} onRegister={jest.fn()} />);

    const button = screen.getByRole('button', { name: /register/i });
    fireEvent.click(button);

    expect(window.alert).toHaveBeenCalledWith('Please enter a valid name!');
  });

  it('does not call onRegister if the input is empty', () => {
    const mockOnRegister = jest.fn();

    render(<RegistrationModal isOpen={true} onRegister={mockOnRegister} />);

    const button = screen.getByRole('button', { name: /register/i });
    fireEvent.click(button);

    expect(mockOnRegister).not.toHaveBeenCalled();
  });
});
