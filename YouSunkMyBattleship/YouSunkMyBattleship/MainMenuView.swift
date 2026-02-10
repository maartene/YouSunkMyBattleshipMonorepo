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
    @State var shouldShowBoard = false
    
    init(dataProvider: DataProvider, gameViewModel: GameViewModel) {
        self.dataProvider = dataProvider
        self.gameViewModel = gameViewModel
    }
    
    var body: some View {
        if shouldShowBoard {
            GameView(viewModel: gameViewModel, gameID: nil)
        } else {
            Button("New game") {
                shouldShowBoard = true
            }
        }
    }
}

#Preview {
    MainMenuView(dataProvider: DummyDataProvider(), gameViewModel: ClientViewModel(dataProvider: DummyDataProvider()))
}
