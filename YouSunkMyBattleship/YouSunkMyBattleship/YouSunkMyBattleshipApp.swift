//
//  YouSunkMyBattleshipApp.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 27/11/2025.
//

import SwiftUI
import WSDataProvider
import Foundation

#if targetEnvironment(simulator)
let wsURL = URL(string: "ws://localhost:8080/game")!
let httpURL = URL(string: "http://localhost:8080/games")!
#else
let wsURL = URL(string: "wss://service-ykxo8.ondigitalocean.app/game")!
let httpURL = URL(string: "https://service-ykxo8.ondigitalocean.app/games")!
#endif

@main
struct YouSunkMyBattleshipApp: App {
    let dataProvider: DataProvider
    let gameViewModel: GameViewModel
    let mainMenuViewModel: ClientMainMenuViewModel
    
    init() {
        dataProvider = URLSessionDataProvider()
        gameViewModel = ClientViewModel(dataProvider: dataProvider)
        mainMenuViewModel = ClientMainMenuViewModel(dataProvider: dataProvider)
    }

    var body: some Scene {
        WindowGroup {
            MainMenuView(
                mainMenuViewModel: mainMenuViewModel,
                gameViewModel: gameViewModel
            )
        }
    }
}
