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
#else
let wsURL = URL(string: "wss://service-ykxo8.ondigitalocean.app/game")!
#endif

@main
struct YouSunkMyBattleshipApp: App {
    let dataProvider: DataProvider
    
    init() {
        dataProvider = URLSessionDataProvider()
    }

    var body: some Scene {
        WindowGroup {
            MainMenuView(dataProvider: dataProvider)
        }
    }
}
