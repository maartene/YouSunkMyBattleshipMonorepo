
FROM swift:6.2 

WORKDIR /app

# Copy the full package into the container
COPY . . 

WORKDIR /app/YouSunkMyBattleshipBE
RUN swift package resolve

EXPOSE 8080

RUN swift build
RUN swift test

# Default command: run tests, and if they succeed, run the executable defined in Package.swift
# Exit with non-zero status if tests fail, so CI can detect failures.
CMD ["./.build/debug/YouSunkMyBattleshipBE"]

