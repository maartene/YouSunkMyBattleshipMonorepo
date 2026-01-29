//
//  YouSunkMyBattleshipApp.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 27/11/2025.
//

import SwiftUI

@main
struct YouSunkMyBattleshipApp: App {
    let viewModel = ClientViewModel(gameService: RemoteGameService(dataProvider: RemoteDataProvider(baseURL: "http://localhost:8080")))
    
    var body: some Scene {
        WindowGroup {
            GameView(viewModel: viewModel)
        }
    }
}
