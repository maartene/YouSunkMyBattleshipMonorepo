//
//  AcceptanceTests.swift
//  YouSunkMyBattleshipTests
//
//  Created by Maarten Engels on 27/11/2025.
//

import Testing
@testable import YouSunkMyBattleship
import ViewInspector
import SwiftUI
import Combine

/// As a player 
/// I want to place my fleet on the board
/// So that I can prepare for battle
@MainActor
@Suite(.tags(.`E2E tests`)) struct `Feature: Ship Placement` {
    let viewModel: ClientViewModel
    let view: GameView
        
    init() {
        self.viewModel = ClientViewModel(dataProvider: MockDataProvider(dataToReceiveOnSend: gameStateDataAfterCompletingPlacement, ))
        self.view = GameView(viewModel: viewModel)
    }

    @Test func `Scenario: Player places a ship successfully`() throws {
        try `Given I have an empty board`()
        try `When I start a drag from A1`()
        try `And end the drag at A5`()
        try `Then the cells A1 through A5 display 🚢`()
        try `And the ship placement is confirmed`()
    }
    
    @Test func `Scenario: Player confirms being done with placing ships`() async throws {
        try `Given I placed all my ships`(usingDrag: true)
        try await `When I confirm placement`()
        try `Then the game shows my board is done`()
        try `And it shows the target board as well`()
        try `And it shows that there are 5 ships remaining to be destroyed`()
    }
    
    @Test func `Scenario: Player wants to replace ships`() throws {
        try `Given I placed all my ships`(usingDrag: false)
        try `When I cancel placement`()
        try `Then I get a new empty board to place ships`()
    }
}
    

// MARK: Steps
extension `Feature: Ship Placement` {
    private func gesture() throws -> InspectableView<ViewType.Gesture<DragGesture>> {
        let inspectedView = try getPlayerBoard(from: view)
        return try inspectedView.grid(0).gesture(DragGesture.self)
    }

    private func `Given I have an empty board`() throws {
        addViewsToViewModel(viewModel)
    }
    private func `When I start a drag from A1`() throws {
        let value = DragGesture.Value(time: Date(), location: CGPoint(x: 56, y: 301), startLocation: CGPoint(x: 56, y: 301), velocity: .zero)
        try gesture().callOnChanged(value: value)
        view.publisher.send()
    }
    private func `And end the drag at A5`() throws {
        let value = DragGesture.Value(time: Date(), location: CGPoint(x: 185, y: 301), startLocation: CGPoint(x: 185, y: 301), velocity: .zero)
        try gesture().callOnEnded(value: value)
        view.publisher.send()
    }
    
    private func `Then the cells A1 through A5 display 🚢`() throws {
        let rows = try getPlayerBoard(from: view)
        
        let row = try #require(rows.first)
        let columns = row.findAll(CellView.self)
        
        for col in 0 ..< 5 {
            #expect(try columns[col].geometryReader().text().string() == "🚢")
        }
    }
    
    private func `And the ship placement is confirmed`() throws {
        let inspectedView = try view.inspect().find(GameStateView.self)
        #expect(try inspectedView.text().string().contains("Carrier(5)") == false)
    }
    
    private func `Given I placed all my ships`(usingDrag: Bool) throws {
        addViewsToViewModel(viewModel)
        if usingDrag {
            try drag(from: CGPoint(x: 56, y: 301), to: CGPoint(x: 185, y: 301), in: view)
            try drag(from: CGPoint(x: 248, y: 301), to: CGPoint(x: 248, y: 397), in: view)
            try drag(from: CGPoint(x: 56, y: 365), to: CGPoint(x: 120, y: 365), in: view)
            try drag(from: CGPoint(x: 312, y: 301), to: CGPoint(x: 312, y: 365), in: view)
            try drag(from: CGPoint(x: 312, y: 461), to: CGPoint(x: 344, y: 461), in: view)
        } else {
            completePlacement(on: viewModel)
        }
        
        #expect(viewModel.state == .awaitingConfirmation)
    }
    
    private func `When I confirm placement`() async throws {
        let inspectedView = try view.inspect().find(GameStateView.self)
        let button = try inspectedView.find(button: "Done!")
        try button.tap()
        
        while viewModel.state != .play {
            try await Task.sleep(nanoseconds: 1000)
        }
    }
    
    private func `Then the game shows my board is done`() throws {
        
        let inspectedView = try view.inspect()
        let gameStateView = try inspectedView.find(GameStateView.self)
        _ = try inspectedView.find(text: "Play!")
    }
    
    private func `And it shows the target board as well`() throws {
        let gameBoardViews = try view.inspect().findAll(GameBoardView.self)
        #expect(gameBoardViews.count == 2)
    }
    
    private func `And it shows that there are 5 ships remaining to be destroyed`() throws {
        let inspectedView = try view.inspect().find(GameStateView.self)
        _ = try inspectedView.find(text: "Remaining ships: 5")
    }
    
    private func `When I cancel placement`() throws {
        let inspectedView = try view.inspect().find(GameStateView.self)
        let button = try inspectedView.find(button: "Clear board")
        try button.tap()
    }
    
    private func `Then I get a new empty board to place ships`() throws {
        let rows = try getPlayerBoard(from: view)
            .find(GameBoardView.self)
            .findAll(BoardRowView.self)
        #expect(rows.count == 10)
        
        for row in rows {
            let columns = row.findAll(CellView.self)
            #expect(columns.count == 10)
            
            for cell in columns {
                #expect(try cell.geometryReader().text().string() == "🌊")
            }
        }
    }
}
