#!/bin/bash

source env-common.sh

export ETHEREUM_JSONRPC_VARIANT=geth
export ETHEREUM_JSONRPC_TRACE_URL=""

export API_RATE_LIMIT=100
export HEART_BEAT_TIMEOUT=30
export TXS_STATS_DAYS_TO_COMPILE_AT_INIT=2
export INDEXER_MEMORY_LIMIT=6

export POOL_SIZE=15
export POOL_SIZE_API=15
export ACCOUNT_POOL_SIZE=10

export INDEXER_DISABLE_EMPTY_BLOCKS_SANITIZER='true'
export INDEXER_DISABLE_PENDING_TRANSACTIONS_FETCHER='true'
export INDEXER_DISABLE_INTERNAL_TRANSACTIONS_FETCHER='true'
export INDEXER_DISABLE_BLOCK_REWARD_FETCHER='true'
export INDEXER_DISABLE_ADDRESS_COIN_BALANCE_FETCHER='false'
export INDEXER_DISABLE_CATALOGED_TOKEN_UPDATER_FETCHER='true'
export ETHEREUM_JSONRPC_DISABLE_ARCHIVE_BALANCES='true'
export INDEXER_DISABLE_TOKEN_INSTANCE_RETRY_FETCHER='true'
export INDEXER_DISABLE_TOKEN_INSTANCE_REALTIME_FETCHER='true'
export INDEXER_DISABLE_TOKEN_INSTANCE_SANITIZE_FETCHER='true'
export INDEXER_DISABLE_WITHDRAWALS_FETCHER='true'
export INDEXER_DISABLE_TOKEN_INSTANCE_LEGACY_SANITIZE_FETCHER='true'
export INDEXER_DISABLE_BEACON_BLOB_FETCHER='true'

export DISABLE_CATCHUP_INDEXER='false'

export INDEXER_CATCHUP_BLOCKS_BATCH_SIZE=5
export INDEXER_COIN_BALANCES_BATCH_SIZE=1
export TOKEN_ID_MIGRATION_BATCH_SIZE=1
export TOKEN_INSTANCE_OWNER_MIGRATION_BATCH_SIZE=1
export INDEXER_EMPTY_BLOCKS_SANITIZER_BATCH_SIZE=1
export INDEXER_BLOCK_REWARD_BATCH_SIZE=1
export INDEXER_RECEIPTS_BATCH_SIZE=10
export INDEXER_COIN_BALANCES_BATCH_SIZE=1
export INDEXER_TOKEN_BALANCES_BATCH_SIZE=1

export INDEXER_CATCHUP_BLOCKS_CONCURRENCY=1
export TOKEN_INSTANCE_OWNER_MIGRATION_CONCURRENCY=1
export INDEXER_BLOCK_REWARD_CONCURRENCY=1
export INDEXER_RECEIPTS_CONCURRENCY=1
export INDEXER_COIN_BALANCES_CONCURRENCY=1
export INDEXER_TOKEN_CONCURRENCY=1
export INDEXER_TOKEN_BALANCES_CONCURRENCY=1
export INDEXER_TOKEN_INSTANCE_RETRY_CONCURRENCY=1
export INDEXER_TOKEN_INSTANCE_REALTIME_CONCURRENCY=1
export INDEXER_TOKEN_INSTANCE_SANITIZE_CONCURRENCY=1
export INDEXER_TOKEN_INSTANCE_LEGACY_SANITIZE_CONCURRENCY=1
export INDEXER_TOKEN_INSTANCE_RETRY_BATCH_SIZE=1
export INDEXER_TOKEN_INSTANCE_REALTIME_BATCH_SIZE=1
export INDEXER_TOKEN_INSTANCE_SANITIZE_BATCH_SIZE=1
export INDEXER_TOKEN_INSTANCE_LEGACY_SANITIZE_BATCH_SIZE=1

export INDEXER_TOKEN_BALANCES_FETCHER_INIT_QUERY_LIMIT=2
export INDEXER_COIN_BALANCES_FETCHER_INIT_QUERY_LIMIT=2

export DISABLE_EXCHANGE_RATES='true'
export DISABLE_TOKEN_EXCHANGE_RATE='true'

export SOURCIFY_INTEGRATION_ENABLED=false
export SOURCIFY_SERVER_URL="https://sourcify.dev/server"
export SOURCIFY_REPO_URL="https://repo.sourcify.dev/select-contract/"

export MICROSERVICE_SC_VERIFIER_ENABLED='true'
export MICROSERVICE_SC_VERIFIER_URL="https://eth-bytecode-db.services.blockscout.com/"
export MICROSERVICE_SC_VERIFIER_TYPE="eth_bytecode_db"

export API_V2_ENABLED=true

export ETHEREUM_JSONRPC_HTTP_URL="https://rpc.pectra-devnet-3.ethpandaops.io"
# export FIRST_BLOCK=5490
# export LAST_BLOCK=5510
export INDEXER_CATCHUP_BLOCKS_BATCH_SIZE=10
export INDEXER_CATCHUP_BLOCKS_CONCURRENCY=2


# Function to check server availability
check_server_availability() {
    local url=$1

    curl --connect-timeout 3 --silent ${url} 1>/dev/null
    if [ $? -ne 0 ]; then
        echo "VPN must be enabled to connect to ${url}"
        exit 1
    fi
}

# Function to check server accessibility with a POST request
check_server_accessibility() {
    local url=$1
    local payload='[{"id":0,"params":["latest",false],"method":"eth_getBlockByNumber","jsonrpc":"2.0"}]'

    http_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST ${url} -H "Content-Type: application/json" -d "${payload}")
    if [ "$http_code" -ne 200 ]; then
        echo "VPN must be enabled to access ${url} (HTTP status code: ${http_code})"
        exit 1
    fi
}

check_server_availability ${ETHEREUM_JSONRPC_HTTP_URL}
check_server_accessibility ${ETHEREUM_JSONRPC_HTTP_URL}

if [ -e .indexed ]; then
    echo Run with indexer disabled
    export DISABLE_INDEXER=true
else
    touch .indexed
    echo Run with indexer enabled
fi

mix phx.server
