# YouSunkMyBattleship

This repository contains a small Battleship game split into three parts:

- `YouSunkMyBattleship` — the iOS client application (UI, UI flow tests)
- `YouSunkMyBattleshipBE` — the backend service (Swift server, game logic and integration tests)
- `YouSunkMyBattleshipCommon` — shared/common library used by both
The repo also includes API contract files in `api/contract/YouSunkMyBattleship` and a Docker Compose setup to run the backend locally.

**Project Goals**
- Provide a minimal, test-driven Battleship implementation demonstrating clean architecture and good tooling.
- Keep domain logic separate from transport and UI (hexagonal architecture).
- Offer reproducible local dev environment via Docker Compose and automated smoketests.

**Repository Structure (top-level)**

- `YouSunkMyBattleship/` — iOS app (Xcode workspace, app sources, tests, UI)
- `YouSunkMyBattleshipBE/` — backend Swift package and Dockerfiles (service & infra)
- `YouSunkMyBattleshipCommon/` — shared Swift package (DTOs, model)
- `api/contract/YouSunkMyBattleship/` — contract files (bruno, schemas, examples)
- `docker-compose.yml` — Compose file to run the backend and supporting services
- `smoketest.sh` — simple script that runs quick integration checks against the running stack

**Requirements**
- macOS with Docker Desktop (or an alternative like Podman Desktop) installed (for Docker Compose)
- Xcode (for building/running the iOS app and iOS tests)
- Swift toolchain (for building/running backend and packages locally)

Getting started — quick steps

1) Start the services with Docker Compose

From the repository root run:

```bash
docker compose up --build -d
```

Notes:
- If you have an older Docker installation using `docker-compose` (hyphen), use `docker-compose up --build -d`.
- Use `docker compose logs -f` to follow logs and `docker compose down` to stop and remove containers.

2) Run the smoketest

The `smoketest.sh` script runs a set of quick checks against the running backend. Ensure the Compose stack is up before running it.

```bash
chmod +x smoketest.sh
./smoketest.sh
```

3) Run the iOS app (development)

- Open the Xcode workspace:

```bash
open YouSunkMyBattleship/YouSunkMyBattleship.xcworkspace
```

- Choose the `YouSunkMyBattleship` scheme and a simulator or device, then Run (Cmd+R).

4) Run backend locally (without Docker)

You can also build and run the backend locally using Swift Package Manager:

```bash
cd YouSunkMyBattleshipBE
swift build
swift run
```

This is useful for fast iteration; the Docker image uses the same package sources.

5) Run tests

- iOS tests: run from Xcode (Product → Test) or via `xcodebuild` using the workspace/scheme.
- Backend tests: from repository root:

```bash
cd YouSunkMyBattleshipBE
swift test

cd ../YouSunkMyBattleshipCommon
swift test
```

API contract

The API contract definitions live under `api/contract/YouSunkMyBattleship/` (bruno files and examples). Use these files as the source of truth for message formats and examples.

Troubleshooting & Tips

- If the smoketest fails, check `docker compose logs -f` to inspect backend logs.
- If Xcode fails to resolve packages, use File → Packages → Resolve Package Versions.
- For CI parity, the repo includes a GitHub Actions workflow that runs tests on macOS using `xcodebuild`.

License

See the `LICENSE` file in the repository root.