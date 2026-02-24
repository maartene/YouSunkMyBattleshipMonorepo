//
//  GameStateView.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 22/12/2025.
//

import SwiftUI
import YouSunkMyBattleshipCommon

struct GameStateView: View {
    private let viewModel: any GameViewModel

    private var shipsToPlace: String {
        viewModel.shipsToPlace.joined(separator: "\t")
    }

    init(viewModel: any GameViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        if viewModel.state == .play {
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
            }
        } else {
            VStack {
                Text(viewModel.lastMessage)
                    .font(.headline)
                Text("Place ships: \(shipsToPlace)")
                    .padding()
            }
        }
    }
}
