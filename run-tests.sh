#!/bin/bash

source env-common.sh

export MIX_ENV=test
export TEST_DATABASE_URL=postgresql://postgres:postgres@db:5432/test
export CHAIN_ID=42161
export TEST_TIMEOUT=50000

# mix ecto.drop
# mix do ecto.create --quiet, ecto.migrate
# cd apps/indexer
# mix do compile, test test/indexer/block/catchup/fetcher_test.exs --no-start --timeout ${TEST_TIMEOUT}

# Initialize variables
DROP_DB=true
TEST_FILE="" #"./test/explorer/chain/smart_contract/proxy/models/implementation_test.exs"

# Parse command-line arguments
while getopts "d" opt; do
  case ${opt} in
    d)
      DROP_DB=true
      ;;
    \?)
      echo "Usage: $0 [-d] [test_file]"
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

# Check if a test file argument is provided
if [ $# -gt 0 ]; then
  TEST_FILE="$1"
fi

# Drop the database if -d option is provided
if [ "${DROP_DB}" == "true" ]; then
  mix ecto.drop
fi

# Run the database setup
mix do ecto.create --quiet, ecto.migrate
# cd apps/indexer
# cd apps/explorer
# cd apps/ethereum_jsonrpc

# Run the tests
if [ -z "${TEST_FILE}" ]; then
  # Run the entire test suite if no test file is provided
  mix do compile, test --no-start --exclude no_nethermind --timeout ${TEST_TIMEOUT}
else
  # Run the specified test file
  mix do compile, test "${TEST_FILE}" --no-start --exclude no_nethermind --timeout ${TEST_TIMEOUT}
fi