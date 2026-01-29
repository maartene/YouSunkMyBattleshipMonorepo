import Testing
import YouSunkMyBattleshipCommon

@Suite struct `Game logic tests` {
    @Test func `a new board should contain only sea`() {
        let board = Board()
        
        let cells = board.cells
        
        for row in 0 ..< 10 {
            for column in 0 ..< 10 {
                #expect(cells[row][column] == .empty)
            }
        }
    }
}
