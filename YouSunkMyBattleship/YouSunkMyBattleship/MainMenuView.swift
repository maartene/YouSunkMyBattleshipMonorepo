//
//  MainMenuView.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 09/02/2026.
//

import SwiftUI
import WSDataProvider

struct MainMenuView: View {
    @State var games: [String] = [
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
        .onAppear() {
            self.games = [
            "game1",
            "game2",
            "game3",
            ]
            
            do {
                guard let data = try dataProvider.syncGet(url: httpURL) else {
                    NSLog("Did not receive a response")
                    return
                }
                let games = try JSONDecoder().decode([String].self, from: data)
                
            } catch {
                NSLog("Failed to load games: \(error)")
            }
        }
    }
}

#Preview {
    MainMenuView(dataProvider: DummyDataProvider(), gameViewModel: ClientViewModel(dataProvider: DummyDataProvider()))
}
