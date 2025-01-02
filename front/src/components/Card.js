import React from 'react';
import PropTypes from 'prop-types';
import './Card.css';

const Card = ({ card }) => {
  if (!card) return null;

  return (
    <img
      src={`/assets/cards/${card}.svg`}
      alt={card}
      className="card-svg"
    />
  );
};

Card.propTypes = {
  card: PropTypes.string.isRequired,
};

export default Card;
