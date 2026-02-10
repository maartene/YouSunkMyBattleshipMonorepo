//
//  MainMenuView.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 09/02/2026.
//

import SwiftUI
import WSDataProvider

struct MainMenuView: View {
    let games = [
        "game1",
        "game2",
        "game3",
    ]
    
    let dataProvider: DataProvider
    let gameViewModel: GameViewModel
    
    init(dataProvider: DataProvider, gameViewModel: GameViewModel) {
        self.dataProvider = dataProvider
        self.gameViewModel = gameViewModel
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
