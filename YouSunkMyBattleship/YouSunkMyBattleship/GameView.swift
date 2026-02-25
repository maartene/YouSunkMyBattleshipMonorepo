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
    let savedGame: SavedGame?
    let withCPU: Bool
    internal let publisher = PassthroughSubject<Void, Never>()

    init(viewModel: any GameViewModel, withCPU: Bool, savedGame: SavedGame? = nil) {
        self.viewModel = viewModel
        self.withCPU = withCPU
        self.savedGame = savedGame
    }

    var body: some View {
        VStack(spacing: 12) {
            GameStateView(viewModel: viewModel)
            GameBoardView(viewModel: viewModel, owner: player)
                .padding()
                .border(Color.green, width: 4)
            if let opponent = viewModel.opponent, viewModel.state == .play || viewModel.state == .finished {
                GameBoardView(viewModel: viewModel, owner: opponent)
                    .padding()
                    .border(Color.red, width: 4)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.state)
        .onAppear {
            if let savedGame {
                if savedGame.canJoin {
                    viewModel.join(savedGame.gameID)
                } else {
                    viewModel.load(savedGame.gameID)
                }
            } else {
                viewModel.createGame(withCPU: withCPU)
            }
        }
    }
}

#Preview {
    GameView(viewModel: ClientViewModel(dataProvider: DummyDataProvider()), withCPU: true)
}
