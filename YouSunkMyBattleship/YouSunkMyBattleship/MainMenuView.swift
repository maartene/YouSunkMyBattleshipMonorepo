//
//  MainMenuView.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 09/02/2026.
//

import SwiftUI
import WSDataProvider

struct MainMenuView: View {
    struct SavedGame: Identifiable {
        let id: String
    }
    
    let games: [String]
    
    let dataProvider: DataProvider
    let gameViewModel: GameViewModel
    
    init(dataProvider: DataProvider, gameViewModel: GameViewModel) {
        self.dataProvider = dataProvider
        self.gameViewModel = gameViewModel
        if let data = try? dataProvider.syncGet(url: httpURL) {
            self.games = (try? JSONDecoder().decode([String].self, from: data)) ?? []
        } else {
            self.games = []
        }
    }
    
    var body: some View {
        VStack {
            NavigationStack {
                List(games, id: \.self) { game in
                    NavigationLink(game) {
                        GameView(viewModel: gameViewModel, gameID: game)
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

#Preview {
    MainMenuView(dataProvider: DummyDataProvider(), gameViewModel: ClientViewModel(dataProvider: DummyDataProvider()))
}
