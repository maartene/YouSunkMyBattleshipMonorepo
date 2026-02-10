//
//  GameBoardView.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 22/12/2025.
//

import SwiftUI
import YouSunkMyBattleshipCommon

struct GameBoardView: View {
    let viewModel: any GameViewModel
    let owner: Player
    let columnLabels = {
        Board.columns.map { String($0) }
    }()

    var body: some View {
        Grid(alignment: .center, horizontalSpacing: 1, verticalSpacing: 1) {
            GridRow {
                Text("")
                ForEach(columnLabels, id: \.self) { columnLabel in
                    Text(columnLabel)
                        .font(.headline)
                }
            }
            ForEach(viewModel.cells[owner, default: []].enumerated(), id: \.offset) { row in
                GridRow(alignment: .bottom) {
                    BoardRowView(
                        viewModel: viewModel, columns: row.element, rowIndex: row.offset,
                        owner: owner)
                }
            }
        }
    }
}

struct BoardRowView: View {
    let viewModel: GameViewModel
    let columns: [String]
    let rowIndex: Int
    let owner: Player

    var body: some View {
        Text(Board.rows[rowIndex])
            .font(.headline)
        ForEach(columns.enumerated(), id: \.offset) { cell in
            CellView(
                content: cell.element, coordinate: Coordinate(x: cell.offset, y: rowIndex),
                owner: owner, viewModel: viewModel)
        }
    }
}

struct CellView: View {
    let content: String
    let viewModel: GameViewModel?
    let coordinate: Coordinate
    let owner: Player

    init(
        content: String, coordinate: Coordinate, owner: Player,
        viewModel: GameViewModel? = nil
    ) {
        self.content = content
        self.coordinate = coordinate
        self.owner = owner
        self.viewModel = viewModel
    }

    var body: some View {
        Text(content)
            .onTapGesture {
                Task {
                    await viewModel?.tap(coordinate, boardForPlayer: owner)
                }
            }
            .animation(.easeInOut(duration: 0.18), value: content)
            .transition(.scale.combined(with: .opacity))
            .font(.system(size: 28))
            .frame(width: 28, height: 28)
    }
}
