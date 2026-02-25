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
        let dataProvider = MockDataProvider(dataToReceiveOnSend: Data())
        let view: MainMenuView

        init() {
            view = MainMenuView(
                mainMenuViewModel: ClientMainMenuViewModel(dataProvider: dataProvider),
                gameViewModel: ClientViewModel(dataProvider: dataProvider))
        }

        @Test func `the view shows a list of all games that are in progress`() async throws {
            let inspectedView = try view.inspect()

            _ = try inspectedView.find(text: "game1")
            _ = try inspectedView.find(text: "game2 (joinable)")
            _ = try inspectedView.find(text: "game3")
        }
        
        @Test func `the view does not show games that cannot be joined nor continued by this player`() async throws {
            let inspectedView = try view.inspect()
            
            #expect((try? inspectedView.find(text: "game4")) == nil)
        }

        @Test func `the view tries to load a list of games that are in progress`() throws {
            let dataProvider = DataProviderSpy()
            _ = MainMenuView(
                mainMenuViewModel: ClientMainMenuViewModel(dataProvider: dataProvider),
                gameViewModel: DummyGameViewModel()
            )

            #expect(dataProvider.getWasCalled(with: URL(string: "http://localhost:8080/games")!))
        }

        @Test func `when clicking on a game that can be continued or joined, the game to continue is passed in`() async throws {
            let inspectedView = try view.inspect()

            let link = try inspectedView.find(navigationLink: "game3")

            let nextView = try link.view(GameView.self).actualView()

            #expect(nextView.savedGame?.gameID == "game3")
        }

        @Test func `when clicking on a new game versus CPU, no game to load is passed in`() async throws {
            let inspectedView = try view.inspect()
            let link = try inspectedView.find(navigationLink: "New game (vs CPU)")

            let nextView = try link.view(GameView.self).actualView()

            #expect(nextView.savedGame == nil)
        }
        
        @Test func `when clicking on a new game versus CPU, the withCPU property is true`() async throws {
            let inspectedView = try view.inspect()
            let link = try inspectedView.find(navigationLink: "New game (vs CPU)")

            let nextView = try link.view(GameView.self).actualView()

            #expect(nextView.withCPU)
        }
        
        @Test func `when clicking on a new game versus player, no game to load is passed in`() async throws {
            let inspectedView = try view.inspect()
            let link = try inspectedView.find(navigationLink: "New game (2 player)")

            let nextView = try link.view(GameView.self).actualView()

            #expect(nextView.savedGame == nil)
        }
        
        @Test func `when clicking on a new game versus player, the withCPU property is false`() async throws {
            let inspectedView = try view.inspect()
            let link = try inspectedView.find(navigationLink: "New game (2 player)")

            let nextView = try link.view(GameView.self).actualView()

            #expect(nextView.withCPU == false)
        }

        @Test func `when no games can be loaded, display message to try again`() async throws {
            let dataProvider = ThrowingDataProvider()
            let view = MainMenuView(
                mainMenuViewModel: ClientMainMenuViewModel(dataProvider: dataProvider),
                gameViewModel: DummyGameViewModel()
            )
            let inspectedView = try view.inspect()

            _ = try inspectedView.find(text: "Could not retrieve games. Try again")
        }

        @Test func `when main menu is pulled, it tries to reload games`() async throws {
            let mainMenuViewModel = MainMenuViewModelSpy()
            let view = MainMenuView(
                mainMenuViewModel: mainMenuViewModel,
                gameViewModel: DummyGameViewModel()
            )
            let inspectedView = try view.inspect()

            let button = try inspectedView.find(button: "Could not retrieve games. Try again")
            try button.tap()

            #expect(mainMenuViewModel.refreshWasCalled)
        }
    }

    @MainActor
    @Suite struct `Interaction between GameView and ViewModel` {
        @Test func `when a gameview gets a loadable game passed in, then the viewmodel tries to load that game`() async throws {
            let viewModel = ViewModelSpy()
            var game = Game(player: Player())
            game.join(Player())
            let view = GameView(viewModel: viewModel, withCPU: true, savedGame: SavedGame(from: game))

            let inspectedView = try view.inspect()

            try inspectedView.vStack().callOnAppear()

            #expect(viewModel.loadWasCalledWithGameID(game.gameID))
        }
        
        @Test func `when a gameview gets a joinable game passed in, then the viewmodel tries to load that game`() async throws {
            let viewModel = ViewModelSpy()
            let game = Game(player: Player())
            let view = GameView(viewModel: viewModel, withCPU: true, savedGame: SavedGame(from: game))

            let inspectedView = try view.inspect()

            try inspectedView.vStack().callOnAppear()

            #expect(viewModel.joinWasCalledWithGameID(game.gameID))
        }
    }

    @MainActor
    @Suite struct ViewModelTests {
        @Test func `when viewModel tries to load a game, the load command is send to the dataprovider`() throws {
            let dataProvider = DataProviderSpy()
            let viewModel = ClientViewModel(dataProvider: dataProvider)

            viewModel.load("game3")

            let expectedCommand = GameCommand.load(gameID: "game3")

            #expect(dataProvider.sendWasCalledWith(expectedCommand))
        }
        
        @Test func `when viewModel tries to join a game, the join command is send to the dataprovider`() throws {
            let dataProvider = DataProviderSpy()
            let viewModel = ClientViewModel(dataProvider: dataProvider)

            viewModel.join("game2")

            let expectedCommand = GameCommand.join(gameID: "game2")

            #expect(dataProvider.sendWasCalledWith(expectedCommand))
        }
        
        
    }
}
