
FROM swift:6.2

WORKDIR /app

# Copy package manifests for the main package and local path dependencies
# This lets Docker cache the dependency resolution layer when manifests don't change.
COPY YouSunkMyBattleshipBE/Package.swift YouSunkMyBattleshipBE/Package.resolved YouSunkMyBattleshipBE/
COPY YouSunkMyBattleshipCommon/Package.swift YouSunkMyBattleshipCommon/
COPY GameRepository/Package.swift GameRepository/

WORKDIR /app/YouSunkMyBattleshipBE

# Use BuildKit cache mounts to persist SwiftPM and build caches between builds.
# Requires Docker BuildKit: set DOCKER_BUILDKIT=1 when building.
# Cache ids are explicit so different cache areas can be reused independently.
RUN --mount=type=cache,id=swiftpm,target=/root/.swiftpm \
	--mount=type=cache,id=swiftpm-cache,target=/root/.cache/swiftpm \
	swift package resolve

# Now copy the full repository (sources). This happens after resolution so the
# resolve layer can be cached when manifests are unchanged.
WORKDIR /app
COPY . .


WORKDIR /app/YouSunkMyBattleshipBE
EXPOSE 8080

# Build into a BuildKit cache, then copy the build output into the image
# so the compiled executable exists in the final filesystem while still
# reusing the cache across builds. Uses `--build-path` to direct SwiftPM
# to write into the cache mount.
RUN --mount=type=cache,id=swift-build,target=/cache/swift-build \
	--mount=type=cache,id=swiftpm,target=/root/.swiftpm \
	--mount=type=cache,id=swiftpm-cache,target=/root/.cache/swiftpm \
	swift build --build-path /cache/swift-build && \
	cp -a /cache/swift-build/debug/YouSunkMyBattleshipBE ./YouSunkMyBattleshipBE

# Run tests using the same cache build path (no need to copy again).
RUN --mount=type=cache,id=swift-build,target=/cache/swift-build \
	--mount=type=cache,id=swiftpm,target=/root/.swiftpm \
	--mount=type=cache,id=swiftpm-cache,target=/root/.cache/swiftpm \
	swift test --build-path /cache/swift-build

CMD ["./YouSunkMyBattleshipBE"]