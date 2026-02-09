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
    
    @State var shouldShowBoard = false
    
    var body: some View {
        if shouldShowBoard {
            GameView(viewModel: ClientViewModel(dataProvider: dataProvider), gameID: nil)
        } else {
            Button("New game") {
                shouldShowBoard = true
            }
        }
    }
}

#Preview {
    MainMenuView(dataProvider: DummyDataProvider())
}
