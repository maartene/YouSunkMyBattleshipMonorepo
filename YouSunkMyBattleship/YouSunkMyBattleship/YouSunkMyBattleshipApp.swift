//
//  YouSunkMyBattleshipApp.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 27/11/2025.
//

import SwiftUI
import WSDataProvider
import Foundation
import YouSunkMyBattleshipCommon

let player = {
   if let playerID = UserDefaults.standard.string(forKey: "playerID") {
        return Player(id: playerID)
   } else {
       let playerID = "player_\(Int.random(in: 0 ... 1_000_000))"
       UserDefaults.standard.set(playerID, forKey: "playerID")
       return Player(id: playerID)
   }
}()

#if targetEnvironment(simulator)
let wsURL = URL(string: "ws://localhost:8080/game/\(player.id)")!
let httpURL = URL(string: "http://localhost:8080/games")!
#else
let wsURL = URL(string: "wss://service-ykxo8.ondigitalocean.app/game/\(player.id)")!
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
