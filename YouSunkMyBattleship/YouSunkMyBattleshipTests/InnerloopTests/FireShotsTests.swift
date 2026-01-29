//
//  FireShotsTests.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 30/12/2025.
//

import Testing
@testable import YouSunkMyBattleship
import ViewInspector
import SwiftUI
import YouSunkMyBattleshipCommon

@Suite(.tags(.`Unit tests`)) struct FireShotsTests {
    @MainActor
    @Suite struct `Interaction between View and ViewModel` {
        let viewModelSpy = ViewModelSpy(state: .play)
        let view: GameView

        init() {
            self.view = GameView(viewModel: viewModelSpy)
        }
        
        @Test func `when a player taps the opponents board, the viewmodel is notified`() async throws {
            let rows = try getEnemyBoard(from: view)
                .findAll(BoardRowView.self)
            let randomRow = rows.randomElement()!
            let randomCell = randomRow.findAll(CellView.self).randomElement()!
            
            try randomCell.geometryReader().text().callOnTapGesture()
            
            while viewModelSpy.tapWasCalledWithCoordinate(try randomCell.actualView().coordinate, for: .player2) == false {
                try await Task.sleep(nanoseconds: 1000)
            }
        }
        
        @Test func `when a player taps their own board, the viewmodel is notified`() async throws {
            let rows = try getPlayerBoard(from: view)
                .findAll(BoardRowView.self)
            let randomRow = rows.randomElement()!
            let randomCell = randomRow.findAll(CellView.self).randomElement()!
            
            try randomCell.geometryReader().text().callOnTapGesture()
            
            while viewModelSpy.tapWasCalledWithCoordinate(try randomCell.actualView().coordinate, for: .player1) == false {
                try await Task.sleep(nanoseconds: 1000)
            }
        }
    }

    @MainActor
    @Suite struct ViewModelTests {
        @Test func `the boards for both player are independent of eachother`() {
            let viewModel = ClientViewModel(gameService: MockGameService())
            completePlacement(on: viewModel)
            
            #expect(viewModel.cells[.player1] != viewModel.cells[.player2])
        }
        
        @Test func `when the player taps the opponents board at B5, the game service should receive a message to fire at that coordinate`() async {
            let spy = GameServiceSpy()
            let viewModel = ClientViewModel(gameService: spy)
            
            await viewModel.tap(Coordinate(x: 4, y: 1), boardForPlayer: .player2)
            
            #expect(spy.fireAtWasCalledWith(Coordinate(x: 4, y: 1), player: .player2))
        }
        
        @Test func `when the player taps their own board at B5, then that should not register as an attempt`() async {
            let spy = GameServiceSpy()
            let viewModel = ClientViewModel(gameService: spy)
            
            await viewModel.tap(Coordinate(x: 4, y: 1), boardForPlayer: .player1)
            
            #expect(spy.fireAtWasNotCalled())
        }
        
        @Test func `a cell that has not been tapped, should show as 🌊`() async {
            let viewModel = ClientViewModel(gameService: MockGameService())
            
            await viewModel.tap(Coordinate("A1"), boardForPlayer: .player2)
            
            #expect(viewModel.cells[.player2]![1][1] == "🌊")
        }
        
        @Test func `a cell that was tapped where no ship is, should show as ❌`() async {
            let viewModel = ClientViewModel(gameService: MockGameService())
            
            await viewModel.tap(Coordinate("A5"), boardForPlayer: .player2)
            
            #expect(viewModel.cells[.player2]![1][4] == "❌")
        }
        
        @Test func `when the player taps the tracking board at a location where a ship is, the cell shows 💥`() async {
            let viewModel = ClientViewModel(gameService: MockGameService())
            
            await viewModel.tap(Coordinate("C5"), boardForPlayer: .player2)
            
            #expect(viewModel.cells[.player2]![2][4] == "💥")
        }
    }
}
