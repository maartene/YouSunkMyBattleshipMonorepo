# Battleship Game - User Stories
## Story 1: Initialize Game Board ✅
As a player
I want to see an empty game board
So that I can visualize the battlefield

### Acceptance Criteria:
1. Display a 10x10 grid with coordinate labels (A-J, 1-10)
2. Show water using 🌊 emoji for all cells
3. Display player's board clearly labeled
4. Exit game with a command
5. Only show the player board ✅

### Scenarios:
Feature: Game Board Initialization
    Scenario: Player views empty board
        Given I start a new Battleship game
        When the game initializes
        Then I see a 10x10 grid filled with 🌊 emojis
        And the grid has row labels A-J and column labels 1-10

## Story 2: Place Ships on Board ✅
As a player
I want to place my fleet on the board
So that I can prepare for battle

### Acceptance Criteria:
1. Place 5 ships: Carrier(5), Battleship(4), Cruiser(3), Submarine(3), Destroyer(2) ✅
2. Ships shown with 🚢 emoji ✅
3. Validate placement (no overlaps, within bounds) ✅
4. Support horizontal and vertical orientation ✅

### Scenarios:
✅ Feature: Ship Placement  
    ✅ Scenario: Player places a ship successfully    
        ✅ Given I have an empty board    
        ✅ When I place the Carrier at position A1 horizontally
        ✅ Then the cells A1 through A5 display 🚢; 
        ✅ And the ship placement is confirmed

## Story 3: Take Shots at Enemy ✅
As a player
I want to fire at coordinates on the enemy board
So that I can try to sink their ships

### Acceptance Criteria:
1. ✅ Input coordinates to fire (e.g., "B5")
2. ✅ Show miss with ❌ emoji
3. ✅ Show hit with 💥 emoji
4. ✅ Display both my board and tracking board

### Scenarios:
✅ Feature: Firing Shots  
    ✅ Scenario: Player fires and misses 
        Given the game has started with all ships placed    
        When I fire at coordinate B5    
        Then the tracking board shows ❌ at B5    
        And I receive feedback "Miss!"
        
    ✅ Scenario: Player fires and hits 
        Given the game has started with all ships placed
        And one of the ship has a piece place on B5
        When I fire at coordinate B5    
        Then the tracking board shows 💥 at B5 
        And I receive feedback "Hit!"

## Story 4: Detect Ship Sinking ✅
As a player
I want to know when I've sunk an enemy ship
So that I can track my progress

### Acceptance Criteria:
1. Track hits on each ship ✅
2. Display 🔥 for sunk ship cells ✅
3. Announce ship name when sunk ✅
4. Show remaining enemy ships count ✅

### Scenarios:
✅ Feature: Ship Sinking Detection  
    ✅ Scenario: Player sinks enemy destroyer    
        Given the enemy has a Destroyer at C3-C4    
        And I have hit C3    
        When I fire at C4    
        Then both C3 and C4 show 🔥    
        And I see "You sank the enemy Destroyer!"

## Story 5: Determine Game Victory ✅
As a player
I want the game to end when all ships are sunk
So that a winner is declared

### Acceptance Criteria:
1. Detect when all ships of one player are sunk
2. Display victory message with 🎉 emoji
3. Show final board state
4. Option to start new game
5. New game resets the target board 

### Scenario: 
Feature: Victory Condition  
    Scenario: Player wins the game    
        Given only one enemy ship remains with one unhit cell    
        When I fire at the last ship's remaining cell    
        Then I see "🎉 VICTORY! You sank the enemy fleet! 🎉"    
        And the game ends


## Story 6.1: Play Against CPU Opponent
As a player
I want to play against a computer opponent
So that I can play solo games

### Acceptance Criteria:
1. CPU places ships randomly at game start
2. CPU takes turns firing after player
3. CPU uses random shot selection
4. Display CPU's move and result

### Scenario:
Feature: CPU Opponent  
    Scenario: CPU takes its turn
        Given it's the CPU's turn
        When the CPU fires    
        Then I see "CPU fires at [coordinate]"    
        And my board updates with hit 💥 or miss ❌

## Story 6.2: DevOps delivery
As a devops engineer
I want to deliver the game as a composition of containers
So that I can play the game relying on a ecosystem of atomic images fully tuned and secured

### Acceptance Criteria:
1. FrontEnd is on the container CLI as ASCII-UI
2. The backend lived into isolation on container SERVICE as API server
3. The database to store the game (future addition) will live in the DB container
4. The three containers must exist on the proper network bridge and spinning up/down without explosions

### Scenario:
Feature: Deliver as Docker Compose
    Scenario: run the CLI as docker compose game
        Given an user
        When it runs the game
        Then a docker compose start phase is well handled by a scrip
        And the ASCII-UI of the game is displayed to the user
        And the game runs in CPU VS CPU
        And it shutdown gracefully without core dumps
        And an exit 0 return to the user.


## Story 7: Save and Resume Game
As a player
I want to save my game and resume later
So that I don't lose progress

### Acceptance Criteria:
1. Save current game state into a persistence layer
2. List available saved games
3. Load and resume from saved state
4. Preserve board state, ships, and turn order
5. The persistence layer must be decoupled into a "sidecar" container

### Scenario
Feature: Game Persistence  
    Scenario: Player saves and resumes game    
        Given I'm in an active game against CPU    
        When I save the game as "game1"
        And I restart and load "game1"
        Then the board state is exactly as I left it

## Story 10: Enable Player vs Player Setup
As a player
I want to create or join a two-player game
So that I can play against another human

### Acceptance Criteria:
1. ✅ Create game returns game ID and player token
2. ✅ Second player joins with game ID
3. ✅ Each player connects from separate container
4. ✅ Turn enforcement between players
5. ✅ Player needs to be able to differentiate between making PvP games and PvCPU games
6. ✅ CPU does not take turns in PvP games (currently is the case)

### Scenario
Feature: Two Player Setup
    Scenario: Second player joins game
        Given Player 1 created game "xyz789"
        ✅ When Player 2 joins game "xyz789"
        ✅ Then both players are connected
        ✅ And the game begins with Player 1's turn

## Story 11: Play Complete PvP game
As a player
I want to play a full game against another player
So that we can compete via API

### Acceptance Criteria:
1. Each player sees only their ships
2. Turns alternate via API polling
3. Both containers communicate via REST
4. Victory notification to both players

### Scenario
Feature: Player vs Player Gameplay
    Scenario: Players take turns via API
        Given a PvP game is in progress
        When Player 1 fires via their container
        Then Player 2's container receives the shot
        And Player 2 can take their turn


## Story 12: Track Game History and Statistics
AS a player
I want to see my game history and stats
SO that I can track my performance

### Acceptance Criteria:
1. Store completed games with outcome
2. Display wins/losses/win rate
3. Show games played vs CPU and PvP
4. Persist stats across container restarts
5. Hard Requirement: the game statistic must be running as a service in a separate container.

### Scenario
Feature: Game Statistics
    Scenario: View player statistics
        Given I have completed 10 games
        When I request my statistics
        Then I see my total win games, wins losses
        And my win rate percentage is displayed