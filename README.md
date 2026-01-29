[![CI](https://github.com/maartene/YouSunkMyBattleship/actions/workflows/ci.yml/badge.svg)](https://github.com/maartene/YouSunkMyBattleship/actions/workflows/ci.yml)

# YouSunkMyBattleship

Minimal, testable Battleship game used as the Blue Belt graduation project for the Dojo. The project emphasizes:

- Hexagonal architecture (ports & adapters)
- Outside-in development (feature-first, acceptance-driven)
- Test doubles (mocks, stubs, fakes where appropriate)
- Lean UX (fast feedback on core interactions)

## Goals
- Deliver a small, well-tested application that demonstrates architectural discipline.
- Iterate from user-facing behavior to inner layers.
- Keep design simple and replaceable.

## Key Principles
- Hexagonal architecture: core domain is independent from UI, persistence, and external services.
- Outside-in: acceptance tests drive requirements and guide implementation.
- Test doubles: isolate layers with fakes / mocks for fast, deterministic tests.
- Lean UX: prefer simple, testable interactions over heavy design.

## Quickstart
1. Prerequisites
    - Install Xcode (use the latest stable or at least a recent release).
    - Command line tools are useful for CI/local test runs.

2. Clone and open
    - Clone the repo and change into the project directory:
      ```
      git clone <repo-url>
      cd YouSunkMyBattleship
      ```
    - Open the Xcode project or workspace:
      - If a workspace exists: `open YouSunkMyBattleship.xcworkspace`
      - Otherwise: `open YouSunkMyBattleship.xcodeproj`

3. Build & run in Simulator
    - In Xcode: choose the "YouSunkMyBattleship" scheme, pick a simulator (e.g., iPhone 14), then press Cmd+R.
    - From terminal (example):
      ```
      xcodebuild -scheme "YouSunkMyBattleship" -destination 'platform=iOS Simulator,name=iPhone 14' build
      ```

4. Run tests
    - In Xcode: Product → Test (Cmd+U) to run unit and UI tests.
    - From terminal (example):
      ```
      xcodebuild -scheme "YouSunkMyBattleship" -destination 'platform=iOS Simulator,name=iPhone 14' test
      ```

5. Run on a physical device
    - Connect the device, select it as the run destination in Xcode.
    - Ensure a valid signing team is set under the target's Signing & Capabilities.

6. Dependencies
    - Swift Package Manager packages are resolved automatically by Xcode; use File → Packages → Resolve Package Versions if needed.
    - If other dependency managers are used, follow the project README or run the appropriate install command.

7. Troubleshooting
    - Clean build: Product → Clean Build Folder (Shift+Cmd+K).
    - Reset simulator content: Simulator → Erase All Content and Settings.
    - Use Xcode’s Report navigator for build/test logs.

These steps should get the app running locally and tests executing in Xcode or CI.

CI
--

- The repository includes a GitHub Actions workflow that runs unit (and UI) tests on `macos-latest` using `xcodebuild`.
- The workflow file is `.github/workflows/ci.yml` and runs the same `xcodebuild -scheme "YouSunkMyBattleship" -destination 'platform=iOS Simulator,name=iPhone 14' test` command shown above.

## License
See LICENSE file for details.
