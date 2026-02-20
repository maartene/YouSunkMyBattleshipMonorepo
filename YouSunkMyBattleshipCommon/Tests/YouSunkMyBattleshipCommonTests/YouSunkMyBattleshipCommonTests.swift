import Testing
import YouSunkMyBattleshipCommon

@Suite struct `Game logic tests` {
    @Test func `a new board should contain only sea`() {
        let board = Board()

        let cells = board.cells

        for row in 0..<10 {
            for column in 0..<10 {
                #expect(cells[row][column] == .empty)
            }
        }
    }

    @Suite struct `Turn order` {
        let player1 = Player()
        let player2 = Player()
        
        @Test func `a new game starts with player1 as player`() {
            let game = Game(
                player1Board: .makeFilledBoard(), player2Board: .makeAnotherFilledBoard(), player1: player1, player2: player2)

            #expect(game.currentPlayer == player1)
        }

        @Test func `after three shots, its player 2s turn`() {
            var game = Game(
                player1Board: .makeFilledBoard(), player2Board: .makeAnotherFilledBoard(), player1: player1, player2: player2)

            game.fireAt(Coordinate("A1"), target: player2)
            game.fireAt(Coordinate("A2"), target: player2)
            game.fireAt(Coordinate("A3"), target: player2)

            #expect(game.currentPlayer == player2)
        }

        @Test func `you cannot fire if its not your turn`() {
            var game = Game(
                player1Board: .makeFilledBoard(), player2Board: .makeAnotherFilledBoard(), player1: player1, player2: player2)
            game.fireAt(Coordinate("A1"), target: player2)
            game.fireAt(Coordinate("A2"), target: player2)
            game.fireAt(Coordinate("A3"), target: player2)

            game.fireAt(Coordinate("A4"), target: player2)

            #expect(game.playerBoards[player2]?.cells[0][3] == .ship)
        }

        @Test func `after three more shots, its player 1s turn`() {
            var game = Game(
                player1Board: .makeFilledBoard(), player2Board: .makeAnotherFilledBoard(), player1: player1, player2: player2)

            game.fireAt(Coordinate("A1"), target: player2)
            game.fireAt(Coordinate("A2"), target: player2)
            game.fireAt(Coordinate("A3"), target: player2)

            game.fireAt(Coordinate("A1"), target: player1)
            game.fireAt(Coordinate("A2"), target: player1)
            game.fireAt(Coordinate("A3"), target: player1)

            #expect(game.currentPlayer == player1)
        }

        @Test func `and after yet three more shots, its player 1s turn`() {
            var game = Game(
                player1Board: .makeFilledBoard(), player2Board: .makeAnotherFilledBoard(), player1: player1, player2: player2)

            game.fireAt(Coordinate("A1"), target: player2)
            game.fireAt(Coordinate("A2"), target: player2)
            game.fireAt(Coordinate("A3"), target: player2)

            game.fireAt(Coordinate("A1"), target: player1)
            game.fireAt(Coordinate("A2"), target: player1)
            game.fireAt(Coordinate("A3"), target: player1)

            game.fireAt(Coordinate("A4"), target: player2)
            game.fireAt(Coordinate("A5"), target: player2)
            game.fireAt(Coordinate("A6"), target: player2)

            #expect(game.currentPlayer == player2)
        }
    }
}

@Suite struct BotTests {
    @Test func `a bot never returns the same coordinate twice`() async {
        let bot = RandomBot()
        var chosenCoordinates: Set<Coordinate> = []

        var board = Board()

        for _ in 0..<100 {
            let coordinates = await bot.getNextMoves(board: board)
            for coordinate in coordinates {
                if chosenCoordinates.contains(coordinate) {
                    Issue.record("Should not send he same coordinate twice")
                }

                board.fire(at: coordinate)
                chosenCoordinates.insert(coordinate)
            }

        }
    }
}
