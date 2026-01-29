//
//  GameBoardView.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 22/12/2025.
//

import SwiftUI
import YouSunkMyBattleshipCommon

struct GameBoardView: View {
    let viewModel: any ViewModel
    let owner: Player
    let isDraggable: Bool
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
            ForEach(viewModel.cells[owner]!.enumerated(), id: \.offset) { row in
                GridRow(alignment: .bottom) {
                    BoardRowView(viewModel: viewModel, columns: row.element, rowIndex: row.offset, owner: owner, isDraggable: isDraggable)
                }
            }
        }.gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged { dragData in
                    viewModel.startDrag(at: dragData.location)
                }
                .onEnded {
                    viewModel.endDrag(at: $0.location)
                }
        )
    }
}

struct BoardRowView: View {
    let viewModel: ViewModel
    let columns: [String]
    let rowIndex: Int
    let owner: Player
    let isDraggable: Bool
    
    var body: some View {
        Text(Board.rows[rowIndex])
            .font(.headline)
        ForEach(columns.enumerated(), id: \.offset) { cell in
            CellView(content: cell.element, coordinate: Coordinate(x: cell.offset, y: rowIndex), owner: owner, isDraggable: isDraggable, viewModel: viewModel)
        }
    }
}

struct CellView: View {
    let content: String
    let viewModel: ViewModel?
    let coordinate: Coordinate
    let owner: Player
    let isDraggable: Bool
    
    init(content: String, coordinate: Coordinate, owner: Player, isDraggable: Bool, viewModel: ViewModel? = nil) {
        self.content = content
        self.coordinate = coordinate
        self.owner = owner
        self.viewModel = viewModel
        self.isDraggable = isDraggable
    }
    
    var body: some View {
        GeometryReader { reader in
            Text(content)
                .onAppear {
                    if isDraggable {
                        viewModel?.addCell(coordinate: coordinate, rectangle: reader.frame(in: .global), player: owner)
                    }
                }
                .onTapGesture {
                    Task {
                        await viewModel?.tap(coordinate, boardForPlayer: owner)
                    }
                }
        }
        .font(.system(size: 28))
        .frame(width: 28, height: 28)
    }
}
