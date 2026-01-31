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
    let viewModel = ClientViewModel(
        gameService: RemoteGameService(
            dataProvider: WSDataProvider(
                url: URL(string: "ws://localhost:8080")!
            )
        )
    )
    
    var body: some Scene {
        WindowGroup {
            GameView(viewModel: viewModel)
        }
    }
}
