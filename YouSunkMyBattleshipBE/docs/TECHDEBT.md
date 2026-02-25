# TECHDEBT 🧹

## ⚠️ TODO

## 🚧 DOING
- [ ] getGameState should become private
    - [ ] main.swift can no longer call into getGameState
        - [ ] GameService should become responsible for sending updates
            - [X] Create a storage for senders
                - [X] Requires a container to hold senders
            - [X] Send ship placement updates
            - [X] Send fire updates
            - [X] Create game updates
            - [X] Load game updates
        - [ ] Use spy in tests
            - [X] ShipPlacementAcceptanceTests
            - [X] ShipPlacementUnitTests
            - [X] FireShotsAcceptanceTests
            - [X] FireShotsUnitTests
            - [X] DetectSinkingShipAcceptanceTests
            - [X] VictoryConditionAcceptanceTests
            - [X] VictoryConditionUnitTests
            - [X] CPUOpponentAcceptanceTests
            - [X] CPUOpponentUnitTests
            - [ ] GamePersistenceAcceptanceTests
            - [ ] GamePersistenceUnitTests
            

## ✅ DONE
- [X] GameService assumes in many places that two players already exist. This requires more robust error handling.
- [X] Player should have arbitrary IDs instead of being enum cases.
- [X] Use backend for placing ships
    - [X] Change `createGame` command such that it creates a game with a single empty board
        - [X] Parallel change: use a new CreateGame command
        - [X] Place ships using a new PlaceShip command
        - [X] Delete old CreateGame command
