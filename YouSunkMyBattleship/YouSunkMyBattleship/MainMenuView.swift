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
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    List(games, id: \.self) { game in
                        NavigationLink(game) {
                            GameView(viewModel: ClientViewModel(dataProvider: dataProvider), gameID: game)
                        }
                    }
                    NavigationLink("New game") {
                        GameView(viewModel: ClientViewModel(dataProvider: dataProvider))
                    }
                }
                .navigationTitle("Main Menu")
            }
        }
    }
}

#Preview {
    MainMenuView(dataProvider: DummyDataProvider())
}
