//
//  YouSunkMyBattleshipApp.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 27/11/2025.
//

import SwiftUI
import WSDataProvider
import Foundation

@main
struct YouSunkMyBattleshipApp: App {
    let viewModel: ViewModel
    
    init() {
        #if targetEnvironment(simulator)
        let wsURL = URL(string: "ws://localhost:8080/game")!
        #else
        let wsURL = URL(string: "wss://service-ykxo8.ondigitalocean.app/game")!
        #endif

        viewModel = ClientViewModel(dataProvider: WSDataProvider(url: wsURL))
    }

    var body: some Scene {
        WindowGroup {
            GameView(viewModel: viewModel)
        }
    }
}
