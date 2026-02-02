
FROM swift:6.2 

WORKDIR /app

# Copy the full package into the container
COPY . . 

WORKDIR /app/api/contract/ContractTest
RUN swift package resolve

RUN swift build
CMD ["swift", "test"]