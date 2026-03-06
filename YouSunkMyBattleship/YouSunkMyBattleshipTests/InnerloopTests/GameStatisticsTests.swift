//
//  GameStatisticsTests.swift
//  YouSunkMyBattleship
//
//  Created by Maarten Engels on 05/03/2026.
//

import Testing
import YouSunkMyBattleshipCommon
import WSDataProvider
import ViewInspector
import Foundation

@testable import YouSunkMyBattleship


@Suite(.tags(.`Unit tests`)) struct GameStatisticsTests {
    @MainActor
    @Suite struct `View should show correct values` {
        let playerStatistics = PlayerStats(cpuWins: 4, totalNumberOfCPUGames: 5, pvpWins: 3, totalNumberOfPvPGames: 7)
        let view: PlayerStatisticsView
        var inspectedView: InspectableView<ViewType.ClassifiedView>!
        
        init() {
            let dataProvider = MockDataProvider()
            dataProvider.dataToReturnOnGet = try? JSONEncoder().encode(playerStatistics)
            
            self.view = PlayerStatisticsView(dataProvider: dataProvider)
            do {
                inspectedView = try view.inspect()
            } catch {
                Issue.record("Failed to inspect view: \(error)")
            }
        }
        
        @Test func `total number of games played should be 12`() async throws {
            let totalGamesView = try inspectedView.find(viewWithTag: "totalGames")
            let totalNumberOfGames = try totalGamesView.text().string()
            #expect(totalNumberOfGames == "12")
        }
        
        @Test func `vs CPU progressbar should be filled at 80%`() throws {
            let totalGamesView = try inspectedView.find(viewWithTag: "vsCPUWinRate")
            let vsCPU = try totalGamesView.progressView()
            let fractionCompleted = try vsCPU.fractionCompleted()
            #expect(fractionCompleted == 0.8)
        }
        
        @Test func `vs CPU progressbar should show win-loss as 4-1`() throws {
            let totalGamesView = try inspectedView.find(viewWithTag: "vsCPUWinRate")
            let vsCPU = try totalGamesView.progressView()
            let fractionLabel = try vsCPU.labelView()
            #expect(try fractionLabel.text().string() == "4-1")
        }
    }
    
    @MainActor
    @Test func `View tries to retrieve statistics`() async throws {
        let dataProvider = DataProviderSpy()
        _ = PlayerStatisticsView(dataProvider: dataProvider)
        
        #expect(dataProvider.getWasCalled(with: URL(string: "http://localhost:8081/statistics/\(player.id)")!))
    }
    
    @MainActor
    @Test func `Should be reachable from the main menu`() async throws {
        let mainMenu = MainMenuView(mainMenuViewModel: MockMainMenuViewModel(), gameViewModel: DummyGameViewModel())
        
        let inspectedView = try mainMenu.inspect()
        let link = try inspectedView.find(navigationLink: "📈 Statistics")

        _ = try link.view(PlayerStatisticsView.self)
    }
}
