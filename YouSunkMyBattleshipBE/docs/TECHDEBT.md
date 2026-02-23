# TECHDEBT 🧹

## ⚠️ TODO

## 🚧 DOING
- [X] Use backend for placing ships
    - [X] Change `createGame` command such that it creates a game with a single empty board
        - [X] Parallel change: use a new CreateGame command
        - [X] Place ships using a new PlaceShip command
        - [X] Delete old CreateGame command

## ✅ DONE
- [X] GameService assumes in many places that two players already exist. This requires more robust error handling.
- [X] Player should have arbitrary IDs instead of being enum cases.
