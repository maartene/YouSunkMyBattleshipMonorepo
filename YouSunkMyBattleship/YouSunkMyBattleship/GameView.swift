//
//  GameBoardView.swift
//  YouSunkMyBattleship
//
//  Created by Engels, Maarten MAK on 27/11/2025.
//

import Combine
import SwiftUI
import WSDataProvider
import YouSunkMyBattleshipCommon

struct GameView: View {
    let viewModel: any GameViewModel
    let gameID: String?
    
    internal let publisher = PassthroughSubject<Void, Never>()

    init(viewModel: any GameViewModel, gameID: String? = nil) {
        self.viewModel = viewModel
        self.gameID = gameID
    }
    
    var body: some View {
        VStack(spacing: 12) {
            GameStateView(viewModel: viewModel)
            GameBoardView(viewModel: viewModel, owner: .player1)
                .padding()
                .border(Color.green, width: 4)
            if viewModel.state == .play || viewModel.state == .finished {
                GameBoardView(viewModel: viewModel, owner: .player2)
                    .padding()
                    .border(Color.red, width: 4)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.state)
    }
}

#Preview {
    GameView(viewModel: ClientViewModel(dataProvider: DummyDataProvider()))
}
