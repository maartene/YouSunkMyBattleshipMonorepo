# TECHDEBT

## ⚠️ TODO
- GameService should only return a game state. More is not needed.
- Make fetching game state asynchronous

## 🚧 DOING
- When a second game is started, the board glitches. Probably because the viewmodels coordinates are overwritten by the second board


## ✅ DONE
- Multiple expects in tests -> split up tests
- Fix: dragging outside of board should cancel dragging action
- GameBoardView is getting large
    - [X] Rename GameBoardView -> GameView
    - [X] Extract everything related to the board into a new GameBoardView
    - [X] Extract everything related to the 'game status' into a new View
- Time to introduce a "Game" protocol, to make testing from the ViewModel easier
- Use Coordinates like A1...J10 instead of (0,0)...(9,9)
- ViewModel.shipsToPlace violates DRY
- Searching for texts where a very specific text is needed does not need an explicit hierarchy
- Get labels from the ViewModel
- ViewModel.cellsForOpponent has feature envy on Game and Board
- getting row and column labels is not dependent on player
- interacting with GameService needs to be asynchronous
- Going from GameViewModel to ClientViewModel
