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
Feature: Ship Placement        
    Scenario: Player confirms being done with placing ships
        Given I placed all my ships
        When I confirm placement
        Then the game shows my board is done

## Story 3: Take Shots at Enemy ✅
As a player
I want to fire at coordinates on the enemy board
So that I can try to sink their ships

### Acceptance Criteria: 
1. Input coordinates to fire (e.g., "B5") ✅
2. Show miss with ❌ emoji ✅
3. Show hit with 💥 emoji ✅
4. Display both my board and tracking board ✅

### Scenarios:
Feature: Firing Shots  
    Scenario: Player fires and misses 
        Given the game has started with all ships placed    
        When I fire at coordinate B5    
        Then the tracking board shows ❌ at B5    
        And I receive feedback "Miss!"
        
    Scenario: Player fires and hits 
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
Feature: Ship Sinking Detection  
    Scenario: Player sinks enemy destroyer    
        Given the enemy has a Destroyer at C3-C4    
        And I have hit C3    
        When I fire at C4    
        Then both C3 and C4 show 🔥    

## Story 5: Determine Game Victory
Asa player
I want the game to end when all ships are sunk
So that a winner is declared

### Acceptance Criteria:
1. Detect when all ships of one player are sunk
2. Display victory message with 🎉 emoji
3. Show final board state
4. Option to start new game

### Scenario:
Feature: Victory Condition  
    Scenario: Player wins the game    
        Given only one enemy ship remains with one unhit cell    
        When I fire at the last ship's remaining cell    
        Then I see "🎉 VICTORY! You sank the enemy fleet! 🎉"    
        And the game ends
