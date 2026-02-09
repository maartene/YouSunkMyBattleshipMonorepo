//
//  GamePersistenceTests.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 09/02/2026.
//

import Testing
@testable import YouSunkMyBattleship
import SwiftUI
import ViewInspector
import YouSunkMyBattleshipCommon

@Suite(.tags(.`Unit tests`)) struct GamePersistenceTests {
    @MainActor
    @Suite struct `Interaction between View and ViewModel` {
        let dataProvider = DataProviderSpy()
        let view: MainMenuView
        
        init() {
            view = MainMenuView(dataProvider: dataProvider)
        }
        
        @Test func `the view shows a list of all games that are in progress`() throws {
            let inspectedView = try view.inspect()
            _ = try inspectedView.find(text: "game1")
            _ = try inspectedView.find(text: "game2")
            _ = try inspectedView.find(text: "game3")
        }
        
        @Test func `when clicking on a game, the game to load is passed in`() async throws {
            let inspectedView = try view.inspect()
            let link = try inspectedView.find(navigationLink: "game2")
            
            let nextView = try link.view(GameView.self).actualView()
            
            #expect(nextView.gameID == "game2")
        }
    }
}
