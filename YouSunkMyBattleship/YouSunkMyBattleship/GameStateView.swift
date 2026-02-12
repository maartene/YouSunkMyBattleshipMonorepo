//
//  GameStateView.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 22/12/2025.
//

import SwiftUI

struct GameStateView: View {
    private let viewModel: any GameViewModel

    private var shipsToPlace: String {
        viewModel.shipsToPlace.joined(separator: "\t")
    }

    init(viewModel: any GameViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        if viewModel.state == .awaitingConfirmation {
            VStack {
                Text("Done placing?")
                    .font(.headline)
                HStack {
                    Button("Done!") {
                        Task { await viewModel.confirmPlacement() }
                    }.buttonStyle(.borderedProminent)
                    Button("Clear board") {
                        viewModel.reset()
                    }.buttonStyle(.bordered)
                }
            }
        } else if viewModel.state == .play {
            VStack {
                Text(viewModel.lastMessage)
                    .font(.headline)
                Text("Remaining ships: \(viewModel.numberOfShipsToBeDestroyed)")
                    .font(.default)
            }.padding()
        } else if viewModel.state == .finished {
            VStack {
                Text(viewModel.lastMessage)
                    .font(.headline)
                Button("New Game") {
                    viewModel.reset()
                }.buttonStyle(.borderedProminent)
            }
        } else {
            Text("Place ships: \(shipsToPlace)")
                .padding()
        }
    }
}
