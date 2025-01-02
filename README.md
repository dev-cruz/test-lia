# Techinal Test: Poker Texas Hold'em
A poker game based on **Texas Hold'em** rules built with **Ruby on Rails**, **React** and **Postgres**.

## Instalation and Usage
```bash
$ git clone https://github.com/dev-cruz/test-lia.git
```
```bash
$ docker compose up
```

## TODO's
### Backend
- [ ] **Handle Ties**: Implement logic to properly handle ties. Currently, the first player with the better hand wins.
- [ ] **Improve API Responses**: Update the API to return more accurate status codes and messages for invalid actions. For example, when a player doesn't have enough chips to bet, call, or raise, the API should return a 400 status code (Bad Request) rather than a 200 status code.
- [ ] **Validate Player's Turn**: Ensure that actions are only allowed when it is the player’s turn to act.
- [ ]  **Unit and Integration Tests**.

### Frontend
- [ ] Improve layout (general layout fixes).
- [ ] **Player Turn Management**: Add a mechanism to manage and display the current player's turn, ensuring players can see who should act next.
- [ ] **Refactor Player Actions Logic**: Encapsulate the logic for player actions (call, fold, bet, etc.) into a separate container component.
- [ ] **Add 'Leave Room' Button**: Implement a button that allows players to exit a room and return to the main lobby.
- [ ] **Handle Inactive Players (Fold)**: Implement a system to manage and display the status of inactive players who have folded.

## Next Steps
 - Implement WebSockets for real-time updates.
 - Store game history.
 - Add user authentication.
 - Automate Game Start and End: Remove the manual game start and end buttons by implementing an automatic system that starts and ends the game based on predefined game logic (e.g., after all players are ready or all rounds are complete).
 - Add a linter on both projects.
