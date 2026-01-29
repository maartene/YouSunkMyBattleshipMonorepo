# Git History
Keep history from before start of mono-repo

## YouSunkMyBattleship
commit 584587812ddf868dab974e43c6ed2d7ce988af64
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 20:14:38 2026 +0100

    D: update TECHDEBT.md with found bug

commit 37eaef7b18946b3cff283a46a4eb2a703b9717e7
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 20:10:30 2026 +0100

    T: only show two boards when in play

commit 968324480550e10797570c73f8e45296529d6766
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 19:34:06 2026 +0100

    Update number of destroyed ships

commit 7d3cba781aaa9d4543caecc9f8e44d070cec2eb9
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 15:29:30 2026 +0100

    R: async tap

commit 43bcd46933d59ceff8cbff6ededb3f11d83ba1d5
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 08:54:13 2026 +0100

    R: Confirm placement asynchronous

commit 31bc2fd3e5be3a819a4af7d205e7537d6781921a
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 08:18:55 2026 +0100

    Fix: URL request requires a content-type

commit e76eb59a482c25aa7576ee563e10e5c5fee34bc7
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 07:52:38 2026 +0100

    R: project organization

commit 333bde77f10ca51b1d066226f2a46fec74339950
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 07:37:51 2026 +0100

    R: extract DTOs into Common

commit dddf7cca0876c5e47d0f9c63418bac40fab27613
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 07:32:48 2026 +0100

    Add actual data provider that submits boards

commit fc62ca76b31b50255c04d531a4f07f98f2e3226f
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 07:11:44 2026 +0100

    T: given all ships have been placed, when the player confirms placement and an error is occurred, the state does not change

commit 2db5a7ae14b408fd22d9ab55d6a2c14598ade945
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Tue Jan 27 16:09:49 2026 +0100

    Connect to local API

commit 60445495953463ff7e9770b88356b825984c0548
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Tue Jan 27 15:47:06 2026 +0100

    R: Extract common types into Common library

commit 9bb2275be2a559d1a2138ab83441844a2fd9c0b7
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 16:55:23 2026 +0100

    R: cellsForPlayer can also show remote board

commit 99d4cea81e20b76bce103087b473440113473a65
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 16:40:31 2026 +0100

    R: can retrieve cells for player2 from the remote service

commit f9a143d29385d8f9f03e04bbc1990458e9c360db
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 11:32:53 2026 +0100

    T: add a remote data provider

commit 2ee6ae9bc6a1c5330c94a9a7b1911786a1b00a32
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 10:54:51 2026 +0100

    R: depend on common

commit 1083e9394fe95e5e84256523ce6c182beca3eefb
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 09:30:33 2026 +0100

    R: safe delete Game

commit c5e0d400c636e010c15c6c47f5f443f74f766420
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 09:29:24 2026 +0100

    R: safe delete GameViewModel

commit 04aac723deeaad65418b22fcacb50aba1f5b8c93
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 09:27:13 2026 +0100

    T: given all ships have been placed, when the player confirms placement, the game services setBoard should be called

commit 4b00c62b1e0c4828155ba2cbe3303c6ca9649dea
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 09:18:29 2026 +0100

    R: tests no longer depend on GameViewModel

commit c7c91dd92a6ca99f12dfc57a82b2dc63169f7d52
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 08:42:07 2026 +0100

    R: Fire shot tests now depend on ClientViewModel

commit 65587b8ef061fae18631785df4db0363968e0d15
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 07:36:59 2026 +0100

    R: - getting row and column labels is not dependent on player

commit ac37dae29c3fbdafcfd9b78d99de6bca48ae1d3d
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 07:31:29 2026 +0100

    R: Project organization

commit fea6b761deb43d82a9780e603e3aa0e50125e44a
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 07:26:10 2026 +0100

    T: outerloop tests for placing ships pass

commit e6a1904568aa2a9b19f98f2a0810ddcface54809
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 07:24:32 2026 +0100

    R: innerloop tests for placing ships pass

commit a00a4de38ac20b5d5caaaf236aee0ff3228e181b
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 07:06:27 2026 +0100

    R: Game Initialization Tests use the ClientViewModel

commit 38e6a2ca8d69807f2ad0b21fafa064865ec93f00
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 06:55:22 2026 +0100

    R: add ClientViewModel

commit c56c0dc9c711fd7e075d03653b8d3d873e757d83
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 19 12:34:15 2026 +0100

    D: update requirements.md

commit fca4f106272d598251ca49940b70173b4bb371e9
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 19 12:13:57 2026 +0100

    T: Scenario: Player restarts the game

commit 624047c122eab711422c0ed5b3d2c5b074ae5619
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 19 11:51:56 2026 +0100

    T: Scenario: Player wins the game

commit aa050a079056efa1b13017bd6e6467a9a82fae2a
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 19 10:45:28 2026 +0100

    T: when all ships have been hit, the game is in finished state

commit 608de9034e2fd3c744e659130e22fab4e05cd61d
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 19 10:03:06 2026 +0100

    Move stuff to other computer

commit 3c6dd487ae4782c1e458f46ac18aa0ceccbe7e75
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Jan 16 11:58:59 2026 +0100

    R: rename test tags

commit c09653dfbbfa5221bd2075b5aa33514adcb65492
Merge: 5521be3 00be153
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Jan 16 10:11:07 2026 +0100

    Merge branch 'main' of github.com:maartene/YouSunkMyBattleship

commit 00be15358cbada00ecdb7b704b69c01d1adbdbf0
Author: Maarten Engels <maartene@mac.com>
Date:   Thu Jan 15 16:00:38 2026 +0100

    R: exclude DS_Store from git

commit e2c701c344fd6deb1bc503bf9675b5c6a0f0e0aa
Author: Maarten Engels <maartene@mac.com>
Date:   Thu Jan 15 15:57:59 2026 +0100

    D: add new requirement

commit 5521be3e22ca43c96229b00003362ddce3354d09
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Jan 9 09:14:25 2026 +0100

    R: wrap placed ships in their own data type

commit b1d9c772b5fe7ef911251126d6fc8597b8f93def
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Thu Jan 8 12:27:00 2026 +0100

    R: improved test performance by populating board using viewmodel instead of using drag gestures.

commit 35ec26cd77a81eb14ceb7a91ad42b487f64499ab
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Thu Jan 8 10:16:08 2026 +0100

    R: extract post processing drag and drop

commit b4f953e79c4014d13e768f8c0fd9337fb14e0548
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Thu Jan 8 10:08:52 2026 +0100

    R: use smarter Cell enum to set lastMessage in ViewModel

commit c745f681dbb27d63d2b8befe8967e68b89e289af
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Thu Jan 8 10:06:11 2026 +0100

    R: improve feature envy from ViewModel on Board

commit 5415f45363d980a0fd4b9cf11a67660c294a0e60
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 5 15:05:16 2026 +0100

    R: add traits to tests

commit c1553c7695c9f35ca22efc323341e65fc1a06ad6
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 5 13:28:49 2026 +0100

    R: make tests less reliant on view hierarchy (where possible)

commit 48e81e5ab08b09ab9976a4b0b53286b19f5e0180
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 5 13:22:42 2026 +0100

    T: Show remaining enemy ships count

commit cb68f43ac0761c24944a9163b831e84e064b0758
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 5 13:08:34 2026 +0100

    R: fix DRY for determining ships to place

commit 46cb9c2f659fabf89fcb558eec1f77d85465747b
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 5 12:59:24 2026 +0100

    D: update techdebt

commit df1ecc506deecd62a465266850eef7170fd43571
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 5 12:51:46 2026 +0100

    Fix: updating ships to place

commit abb1b11b1cf1fa34b3fc03e9a0aebb1dd05534dd
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 5 12:45:22 2026 +0100

    Fix: force update now works correctly

commit a2a554d231137fadb41298394bb3dd1c5147edde
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 5 11:23:30 2026 +0100

    R: make sunk message dependent on ship

commit 4cadc1684ee9c75ac125ae5a776ecb35fe293534
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 5 11:19:46 2026 +0100

    T: Scenario: Player sinks enemy destroyer

commit 9df81109bfa587ca60b5c1b53a744b336f3215eb
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 5 11:09:54 2026 +0100

    R: get cells from event sourcing

commit 07ec1972e9399f0ed4ecfc7ad0d19f59e8631144
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 5 11:05:08 2026 +0100

    T: when all coordinates from a ship have been hit, it gets marked as destroyed

commit 3f58382c5b1ad778fb94ded4834b9e643f0a0857
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 5 09:29:20 2026 +0100

    T: Feature: Ship Sinking Detection acceptance tests fails for right reason

commit 796c3b219b6c746f800395d204f0acb08bc7eeb5
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 5 09:24:16 2026 +0100

    R: extract drag and gesture helpers

commit 54887b53a1e42d50b775705e3948021f2dc8f47d
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 5 09:02:59 2026 +0100

    R: Coordinates can now also be defined as a letter and digit

commit fb6f8f95fedbd671864aca73e64c4fda50f8c285
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Jan 2 16:22:07 2026 +0100

    T: Scenario: Player fires and hits

commit 750098017ae3600f43ebb5059a80c9cf334d6f6c
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Jan 2 16:19:35 2026 +0100

    T: when the player taps the tracking board at a location where a ship is, the cell shows 💥

commit 1bd8edd4b93d41c2b9a31f8d6dec2bb83d0696d6
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Jan 2 16:04:25 2026 +0100

    R: split up acceptance test

commit 521f34d8f66317494e63c83a8faad5c18e7249bc
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Jan 2 16:01:07 2026 +0100

    R: split up acceptance test

commit 0330df68a4642c378a056dd6528f93295299fb56
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Jan 2 15:56:30 2026 +0100

    R: move Player into Model

commit b8f01df9f36b3b5cf645a58a12662d230220dcb1
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Jan 2 15:53:19 2026 +0100

    R: move Game logic into seperate class

commit 558ce0246448dbe9e8386bcacb7525dbb5852fd8
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Jan 2 11:23:12 2026 +0100

    T: Scenario: Player fires and misses

commit 9a517805a44b81ea619b99bc502c47bf3f141e1c
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Jan 2 10:55:45 2026 +0100

    T: a cell that has not been tapped, should show as 🌊

commit 4170f29cdea7ffdfb2c61e5984bc2704ca10c507
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Jan 2 10:35:53 2026 +0100

    T: when coordinate 4,1 is tapped, then it shows as ❌

commit 3270dbc1f274aaddc67def3b760441a1ecbcdc0c
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Jan 2 10:32:54 2026 +0100

    T: the boards for both player are independent of eachother

commit 4503462726e5d415da5859694cba309bd014c6ce
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Jan 2 10:27:00 2026 +0100

    T: when a player taps the board, the viewmodel is notified

commit 75d62f6f975fab58d143d08e62b9a592b786cda0
Author: Maarten Engels <maartene@mac.com>
Date:   Tue Dec 30 09:16:14 2025 +0100

    R: extract test helpers

commit ecf0af1dea37dce7d043d317a525fd7cf1af2567
Author: Maarten Engels <maartene@mac.com>
Date:   Tue Dec 30 09:00:01 2025 +0100

    R: viewmodel knows about players

commit 6d36172e5e507368d902fbfeaf07f2cae411f777
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Dec 29 11:07:41 2025 +0100

    Add acceptance test for story 3, first scenario (RED)

commit 71db3a8a8127c0fef00b3089c2ea468b86c6319c
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Dec 29 10:55:40 2025 +0100

    Test fails for correct reason

commit 23e00064c813ff0074e519e00b3f954a255bdedf
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Dec 29 10:48:44 2025 +0100

    Add acceptance test for story 3, first scenario (RED)

commit 40da9c3aa2931bf583ad307fab5aa3b8e6029484
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Dec 29 10:41:58 2025 +0100

    SPIKE: experiment with multiple boards: improve readability

commit f82dd7563867820cedd50fc1658018538da29bfa
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Dec 22 13:04:35 2025 +0100

    R: safe delete unused ship coordinate creators

commit 3efbaa1ef9912cf4cf29918b679eb2b86f033bbe
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Dec 22 13:00:57 2025 +0100

    R: extra GameStateView

commit add4370080fbd830e3cacbbe2af2a3275b9b81c6
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Dec 22 12:54:13 2025 +0100

    R: extract gestures for ViewInspector

commit 5a4d04ffeb5ad110348546bc68d90aef9b08d9b3
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Dec 22 12:49:20 2025 +0100

    R: extract gestures for ViewInspector

commit 85f0d301ffd007af63ceea95fd2893b112d0a1b6
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Dec 22 08:35:39 2025 +0100

    R: update TECHDEBT.md

commit beaa3dbae9584b0db791066d81241813f908077a
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Dec 22 08:34:24 2025 +0100

    R: wrap GameBoardView in its own View

commit 6a963a960aeeb91219f00bf4f7773ff4f6d7aee6
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Dec 22 08:23:10 2025 +0100

    R: file organization

commit 671cd9d94d8ef83692dfa328a7adbf6aaa3c02f0
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Dec 22 08:19:06 2025 +0100

    T: given a drag already started, when a drag ends outside of the board, the drag is reset

commit 9f10543aa6b170de904ba281eb129756ddc5521f
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Sun Dec 21 17:54:44 2025 +0100

    R: extract creation of vertical and horizontal ships

commit a3e897a90e06eceec1e0893671c4b1c73a5252bd
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Sun Dec 21 10:19:41 2025 +0100

    R: extract processing vertical ships

commit 0f5829e7e47052b300e273b706688bd53b8690cc
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Sat Dec 20 14:13:58 2025 +0100

    T: Scenario: Player wants to replace ships

commit db1e6c01ec7b0908b36a152ec317b4f992456682
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Sat Dec 20 14:08:09 2025 +0100

    T: given all ships have been placed, when the player confirms placement, the board is reset

commit 9d0b7f8229f2de7d0222493eddc586a6651924c8
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Sat Dec 20 14:03:23 2025 +0100

    T: Scenario: Player confirms being done with placing ships

commit cbf84556fa0fb5de084e6109a1e9bb7c0eebc5a8
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Sat Dec 20 13:55:17 2025 +0100

    T: given all ships have been placed, when the player confirms placement, the viewmodels state should move to play

commit fbced2d1e4f255e9f1f7c07d74b21585c1e84e9f
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Sat Dec 20 13:46:38 2025 +0100

    T: when all ships have been placed, the viewmodel should signal to confirm placement

commit 3ab63b88ab05ee60d2a7f35336b9bdb2212d7768
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Sat Dec 20 13:29:19 2025 +0100

    T: when all ships have been placed, the viewmodel should signal to confirm placement

commit 214ba8346f554dc37838bf02d8e243b6cdc31f5a
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Sat Dec 20 11:23:30 2025 +0100

    D: update requirements.md

commit 674770e251cebeda5726ba582a3a498b04b3b77e
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Sat Dec 20 11:19:16 2025 +0100

    T: when five ships have been placed, no more ships can be placed

commit a2870e8969941f572ab82beedb3d6446e6afb150
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Sat Dec 20 10:08:58 2025 +0100

    T: when a larger ship tries to be placed than is available, it does not get placed

commit 4e783e2aa6aa8d1bdebc1acfafee2316b477dbd6
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Sat Dec 20 10:01:24 2025 +0100

    T: when a larger ship tries to be placed than is available, it does not get placed

commit 048c58871b3a55366adf0b02185589bf181deb80
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Sat Dec 20 09:57:52 2025 +0100

    T: when a ship is placed where another ship has already been placed, it does not get placed

commit c01bfdc382df9a1b748a88104c12adfe3f0f7528
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Sat Dec 20 09:51:46 2025 +0100

    T: when a ship is placed outside of bounds, it does not get placed

commit 12687ebfc2d6cae8d20ebbcbf89ff80c653caed1
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Sat Dec 20 09:42:17 2025 +0100

    T: when a valid ship has been placed, it is removed from the ships to place list

commit 330dd03c91e774938af64d093b4f3b88d74a99a3
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Dec 19 22:35:05 2025 +0100

    T: And all five ships to be placed are shown

commit 4a00c54a02c2f540c4a31b412ffa6ad3920fcc7a
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Dec 19 19:49:26 2025 +0100

    D: update requirements.md

commit 1acd2e4a09fe16609ee482770aee3a1eee5b831f
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Dec 19 19:46:46 2025 +0100

    D: update TECHDEBT

commit ec142fbaa8c5795fb12dd1d7352b536ba98d490a
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Dec 19 19:26:47 2025 +0100

    T: Scenario: Player places a ship successfully

commit 8b8dbb18aa8d9daedea8094b365c26493cf3affc
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Dec 19 19:12:41 2025 +0100

    T: given a drag has ended, a new drag can be started

commit eb3b79e5275945fce736bf289bd75a6e07e83c69
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Dec 19 19:05:12 2025 +0100

    T: given a drag already started, when a drag is outside of an ocean tile, the cells remain ships

commit ea17184f6f496c0987dae643cf5b85f934013f3b
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Dec 19 18:57:55 2025 +0100

    T: given a drag already started, when a drag moves to  195,301 then the cells A5, B5 and C5 becomes a ship

commit d847e113cbc0755599f2555ae64cd421457d8e9e
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Dec 19 18:53:19 2025 +0100

    T: given a drag already started, when a drag moves to  195,301 then the cell at C5 becomes a ship

commit 8a2dce278afc7b68cbdde34a5d0ff74dd2597118
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Dec 19 18:47:40 2025 +0100

    T: when a drag starts at 195,301 then the cell at A5 becomes a ship

commit db3a7265000f4ce4e75a159735adff103148e7b0
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Dec 19 09:55:11 2025 +0100

    T: when a drag ends, the viewmodel is notified

commit cd3fc13abc4471d6051a3effb504896a2e7fecc7
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Dec 19 09:50:12 2025 +0100

    T: when a drag starts, the viewmodel is notified

commit 414dcdde107bdae56133309d90d6d0a33504e342
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Dec 19 08:29:05 2025 +0100

    R: change acceptance test naming convention

commit d59209f07d0e8dac94172f7b8593b208adbdf0e1
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Dec 19 08:24:09 2025 +0100

    R: change acceptance test naming convention

commit 5c8fc1403793d33865070ac050adf6ef1dfc67db
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Thu Dec 18 16:10:45 2025 +0100

    D: update docs

commit 91284bb862a7028302c48ee605402c89dbd059dc
Author: Maarten Engels <maartene@mac.com>
Date:   Thu Dec 11 17:08:09 2025 +0100

    D: add story 3 to requirements

commit 8c2a1c1d2311111bde45d7e9e33006749998058b
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Dec 5 11:36:36 2025 +0100

    D: update docs

commit b494da3dd0abf81be663a43859d30e4bceef0574
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Dec 5 11:34:09 2025 +0100

    Spike: drag and drag UI for placing ships

commit 71318ace10ac629ab237fb4af726466a33f5cea7
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Thu Dec 4 16:40:32 2025 +0100

    D: update docs and icon

commit f8e1598fa6dcfc627197733bfdf7cc0086409051
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Fri Nov 28 16:03:16 2025 +0100

    R: move stuff around to improve readability

commit 7acee2cfaf6f83dc72f41e73e278155a9a8de850
Author: Maarten Engels <maartene@mac.com>
Date:   Thu Nov 27 21:07:53 2025 +0100

    R: dynamically show the Board

commit f384d6988247b398b385f9e8bc3598354a829e36
Author: Maarten Engels <maartene@mac.com>
Date:   Thu Nov 27 21:07:37 2025 +0100

    R: dynamically show the Board

commit 653788fd17591e970411affa9f88f7f9057a7740
Author: Maarten Engels <maartene@mac.com>
Date:   Thu Nov 27 20:46:28 2025 +0100

    R: dynamically show the Board

commit c61dc44ae54eaa6144ced5a197426f415b3e4903
Author: Maarten Engels <maartene@mac.com>
Date:   Thu Nov 27 20:22:51 2025 +0100

    R: dynamically show the Board

commit 9eae59d459de6887ec8421d56898f3750fc5e515
Author: Maarten Engels <maartene@mac.com>
Date:   Thu Nov 27 20:10:55 2025 +0100

    T: Then I see a 10x10 grid filled with 🌊 emojis

commit db4860468c9e6ec159fc10b4a9d563742d0d966a
Author: Maarten Engels <maartene@mac.com>
Date:   Thu Nov 27 19:50:24 2025 +0100

    T: Then I see a 100 cells

commit ad0378ce1e59b3840f6bf5a3efa1d33426a5e807
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Thu Nov 27 19:05:42 2025 +0100

    Repair intentionally failing test

commit fbd022522c75248c16d259b9c145d6a3a6a6bf83
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Thu Nov 27 18:57:53 2025 +0100

    intentionally fail test

commit 448d6d56b7ac1d41714a79e4e1d597981ca96024
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Thu Nov 27 17:38:47 2025 +0100

    Chore: CI setup

commit 7b04e84e4ea6be8d2de3d12bbed0f6485db66a53
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Thu Nov 27 17:36:49 2025 +0100

    D: Add Swift Badge Of Honor

commit 3b23892b16cfa640c78c14c6cbe8b63c42e8b38f
Author: Maarten Engels <maartene@mac.com>
Date:   Thu Nov 27 17:32:00 2025 +0100

    Add LICENSE

commit c8a130e31a38ce468c3ce9adb8a5fcdb5af2ce67
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Thu Nov 27 17:31:10 2025 +0100

    Chore: add documentation

commit 0d1943055197daf2d57c7ed05149bf761bbb3060
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Thu Nov 27 17:24:36 2025 +0100

    Chore: initial project setup

commit c0a9ff84f2c9ccb23098ab02c011456cf013f04a
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Thu Nov 27 17:19:07 2025 +0100

    Initial Commit


## YouSunkMyBattleshipBE
commit 1da2374e567bc70ebc84e7501a533e9ae1a7818c
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 20:09:56 2026 +0100

    T: creating a board resets player 2 board

commit 6b6cd87cd3e940d2ebef246d9d1dc00902fb5a96
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 18:29:45 2026 +0100

    T: Scenario: Player wins the game

commit 6f0dc7576d93563578f9344c859547303ce6c2ff
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 18:22:48 2026 +0100

    R: extract helper to create a nearly finished board

commit f32e7618bdc470a0a23750a2311edd440544a1eb
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 18:20:00 2026 +0100

    T: when all ships have been hit, the game is in finished state

commit bf0eb18d7571f30dad4ab7a810e88103e3a16ef3
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 18:10:23 2026 +0100

    T: Scenario: Player sinks enemy destroyer

commit 050687838c935d63d65ec6a81532d2cdfbc86b0d
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 18:05:20 2026 +0100

    T: when all coordinates from a ship have been hit, it is shown as 🔥

commit 1142040a69b5459a19e27393a221d6b2594d97b0
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 18:01:59 2026 +0100

    T: migrate unit tests for detecting ships

commit d81fecf398573e912818611adf5782cada807377
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 17:30:34 2026 +0100

    R: migrate over unit tests from front-end

commit 18352ceb7a3b83e2423094e2e3d4d5f34d707b3e
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 15:53:17 2026 +0100

    D: update requirements.md

commit 73bb4aa1fffee9f3c312b445ac1f022bfe7d73a0
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 15:51:40 2026 +0100

    T: Feature: Firing Shots

commit efed8553606f664374ec60428dc33e58561fc3ec
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 07:58:58 2026 +0100

     R: extract DTOs

commit 36f4c1a12870097ef82afe96d6825afb420fbabc
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 07:58:44 2026 +0100

     R: extract DTOs

commit 132e25bc72bfc1a870ab70c9fc59c0d465484f02
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Tue Jan 27 15:44:47 2026 +0100

    T: when a board with overlapping ships is submitted, an error is returned

commit 0542f4510d54d77c8504e69ede3842cbd41d2e40
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Tue Jan 27 13:27:50 2026 +0100

    T: Scenario: Player confirms being done with placing ships

commit 9dea552c91b0093de966d3df819fe63bde1cd3df
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Tue Jan 27 09:56:17 2026 +0100

    T: when a valid board is submitted, it returns a created message

commit b6927de9df1cb414f8264ae1455bee8be0a8792d
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Tue Jan 27 08:26:21 2026 +0100

    Add dependencies

commit 37205ec46f76f07702283446c928d3fc9bf6568c
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Mon Jan 26 22:48:18 2026 +0100

    Fix syntax error of docker compose file

commit e0ed3227cd5886a8682559278358efde07639002
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 10:25:56 2026 +0100

    Chose: add docker-compose

commit b111d5695747653ea6559d79a0f85024861dffd7
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 10:03:01 2026 +0100

    Chore: add docker

commit df0c22e23e1ce441008a814a993253ad3d122a0e
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 09:48:29 2026 +0100

    initial commit

## YouShunkMyBattleshipCommon
commit bb79526ea9467dd60f708e08d301e7bc7b564351
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 19:34:40 2026 +0100

    Add finished state

commit 7ea707a386256a38a0c8485d0e46f5e7bc81833f
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 15:52:03 2026 +0100

    R: make fireAt public

commit 07079541eb2294ac7993b0984f797459995f1ee1
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 07:59:00 2026 +0100

     R: extract DTOs

commit a2be0fc3c592f70a52877a67a43332004bae18da
Author: Maarten Engels <maartene@mac.com>
Date:   Wed Jan 28 07:49:06 2026 +0100

    R: include DTOs

commit cab3e3ba5667f5b2fed9f5a04e79f2a5be698d40
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Tue Jan 27 15:46:00 2026 +0100

    Add Sendable conformance to regular types

commit eac34f50161b7e08b4820f65f9dd65b7fb3f9c32
Author: Maarten Engels <maartene@thedreamweb.eu>
Date:   Tue Jan 27 08:18:07 2026 +0100

    T: a new board should contain only sea

commit 5b3801aa4bc4ee44d0ec9f38e26d14eb831713b5
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 10:42:54 2026 +0100

    Export GameState

commit 7b66234c11795d992026070311ac17db3f8d150c
Author: Maarten Engels <maartene@mac.com>
Date:   Mon Jan 26 10:34:29 2026 +0100

    Chore: initial commit
