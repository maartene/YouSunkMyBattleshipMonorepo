//
//  MainMenuView.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 09/02/2026.
//

import SwiftUI
import WSDataProvider

struct MainMenuView: View {
    let dataProvider: DataProvider
    let gameViewModel: GameViewModel
    
    @State private var shouldShowRefreshMessage = false
    
    let mainMenuViewModel: MainMenuViewModel
    
    init(dataProvider: DataProvider, gameViewModel: GameViewModel, mainMenuViewModel: MainMenuViewModel? = nil) {
        self.dataProvider = dataProvider
        self.gameViewModel = gameViewModel
        self.mainMenuViewModel = mainMenuViewModel ?? ClientMainMenuViewModel(dataProvider: dataProvider)
    }
    
    var body: some View {
        VStack {
            if mainMenuViewModel.shouldShowRefreshMessage {
                Button("Could not retrieve games. Try again") {
                    mainMenuViewModel.refreshGames()
                }
            } else {
                NavigationStack {
                    List(mainMenuViewModel.games) { game in
                        NavigationLink(game.id) {
                            GameView(viewModel: gameViewModel, gameID: game.id)
                        }
                    }
                    NavigationLink("New game") {
                        GameView(viewModel: gameViewModel, gameID: nil)
                    }
                    .navigationTitle("Main Menu")
                }
            }
        }
    }
}

#Preview {
    MainMenuView(dataProvider: DummyDataProvider(), gameViewModel: ClientViewModel(dataProvider: DummyDataProvider()))
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
            let gameNames = (try? JSONDecoder().decode([String].self, from: data ?? Data())) ?? []
            self.games = gameNames.map { SavedGame(id: $0) }
            shouldShowRefreshMessage = false
        } catch {
            shouldShowRefreshMessage = true
        }
    }
}

struct SavedGame: Identifiable {
    let id: String
}
