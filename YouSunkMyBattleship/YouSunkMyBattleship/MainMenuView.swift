//
//  MainMenuView.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 09/02/2026.
//

import SwiftUI
import WSDataProvider
import YouSunkMyBattleshipCommon

struct MainMenuView: View {
    let gameViewModel: GameViewModel

    let mainMenuViewModel: MainMenuViewModel

    init(mainMenuViewModel: MainMenuViewModel, gameViewModel: GameViewModel, ) {
        self.gameViewModel = gameViewModel
        self.mainMenuViewModel = mainMenuViewModel
    }

    func stringValueFor(_ game: SavedGame) -> String {
        var result = game.gameID
        if game.canJoin {
            result += " (joinable)"
        }
        return result
    }
    
    var body: some View {
        VStack {
            Text(player.id)
            if mainMenuViewModel.shouldShowRefreshMessage {
                Button("Could not retrieve games. Try again") {
                    mainMenuViewModel.refreshGames()
                }
            } else {
                NavigationStack {
                    List(mainMenuViewModel.games) { game in
                        NavigationLink(stringValueFor(game)) {
                            GameView(viewModel: gameViewModel, savedGame: game)
                        }
                    }
                    NavigationLink("New game") {
                        GameView(viewModel: gameViewModel, savedGame: nil)
                    }
                    .navigationTitle("Main Menu")
                }
            }
        }
    }
}

#Preview {
    MainMenuView(
        mainMenuViewModel: ClientMainMenuViewModel(dataProvider: DummyDataProvider()),
        gameViewModel: ClientViewModel(dataProvider: DummyDataProvider())
    )
}

protocol MainMenuViewModel {
    var games: [SavedGame] { get }
    var shouldShowRefreshMessage: Bool { get }

    func refreshGames()
}

@Observable
final class ClientMainMenuViewModel: MainMenuViewModel {
    var games: [SavedGame] = []
    var shouldShowRefreshMessage = false
    let dataProvider: DataProvider

    init(dataProvider: DataProvider) {
        self.dataProvider = dataProvider
        refreshGames()
    }

    func refreshGames() {
        do {
            let data = try dataProvider.syncGet(url: httpURL)
            let games = (try? JSONDecoder().decode([SavedGame].self, from: data ?? Data())) ?? []
            shouldShowRefreshMessage = false
            
            self.games = games.filter { game in
                game.players.contains(player.id) || game.canJoin
            }
            
        } catch {
            shouldShowRefreshMessage = true
        }
    }
}

extension SavedGame: @retroactive Identifiable {
    public var id: String { gameID }
}
