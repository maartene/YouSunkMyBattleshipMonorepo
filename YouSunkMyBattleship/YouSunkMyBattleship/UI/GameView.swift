//
//  GameBoardView.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 27/11/2025.
//

import SwiftUI
import Combine
import YouSunkMyBattleshipCommon

struct GameView: View {
    let viewModel: any ViewModel
    internal let publisher = PassthroughSubject<Void, Never>()
    
    var body: some View {
        GameStateView(viewModel: viewModel)
        GameBoardView(viewModel: viewModel, owner: .player1, isDraggable: true)
            .padding()
            .border(Color.green, width: 4)
        if viewModel.state == .play || viewModel.state == .finished {
            GameBoardView(viewModel: viewModel, owner: .player2, isDraggable: false)
                .padding()
                .border(Color.red, width: 4)
        }        
    }
}

#Preview {
    GameView(viewModel: ClientViewModel(gameService: DummyGameService()))
}
