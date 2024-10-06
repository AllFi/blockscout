#!/bin/bash

# Source the common environment variables
source env-common.sh

# Initialize variables
NO_SYNC=false
INIT=false
RECOMPILE=false
SPELLCHECK=false
DIALYZER=false
CREDO=false
FORMAT=false
DOCS=false

# Parse command line arguments
for arg in "$@"
do
    case $arg in
        --no-sync)
        NO_SYNC=true
        shift # Remove --no-sync from processing
        ;;
        --init)
        INIT=true
        shift # Remove --init from processing
        ;;
        --recompile)
        RECOMPILE=true
        shift # Remove --recompile from processing
        ;;
        --spellcheck)
        SPELLCHECK=true
        shift # Remove --spellcheck from processing
        ;;
        --dialyzer)
        DIALYZER=true
        shift # Remove --dialyzer from processing
        ;;
        --credo)
        CREDO=true
        shift # Remove --credo from processing
        ;;
        --format)
        FORMAT=true
        shift # Remove --format from processing
        ;;
        --docs)
        DOCS=true
        shift # Remove --docs from processing
        ;;
    esac
done

# Define the initialization subroutine
initialize_db() {
    rm -f .indexed
    mix ecto.drop && mix do ecto.create, ecto.migrate | grep Runn
}

# Define the recompile subroutine
recompile() {
    mix deps.clean block_scout_web
    mix deps.clean explorer
    mix deps.clean indexer
    mix deps.get
    mix deps.compile --force
}

# Define the spellcheck subroutine
spellcheck() {
    cspell --config cspell.json "**/*.ex*" "**/*.eex" "**/*.js" --gitignore | less
}

# Define the dialyzer subroutine
dialyzer() {
    mix dialyzer
}

# Define the credo subroutine
credo() {
    mix credo
}

# Define the format subroutine
format() {
    mix format
}

# Define the format subroutine
generate_docs() {
    mix docs
}

# If --init argument is passed, run the initialization subroutine and exit
if [ "$INIT" = true ]; then
    initialize_db
    exit 0
fi

# If --recompile argument is passed, run the recompile subroutine and exit
if [ "$RECOMPILE" = true ]; then
    recompile
    exit 0
fi

# If --spellcheck argument is passed, run the spellcheck subroutine and exit
if [ "$SPELLCHECK" = true ]; then
    spellcheck
    exit 0
fi

# If --dialyzer argument is passed, run the dialyzer subroutine and exit
if [ "$DIALYZER" = true ]; then
    dialyzer
    exit 0
fi

# If --credo argument is passed, run the credo subroutine and exit
if [ "$CREDO" = true ]; then
    credo
    exit 0
fi

# If --format argument is passed, run the format subroutine and exit
if [ "$FORMAT" = true ]; then
    format
    exit 0
fi

# If --doc argument is passed, run the format subroutine and exit
if [ "$DOCS" = true ]; then
    generate_docs
    exit 0
fi

# Run the appropriate script based on CHAIN_TYPE
case $CHAIN_TYPE in
    "arbitrum")
    SCRIPT_TO_RUN="run-arbitrum.sh"
    ;;
    "zksync")
    SCRIPT_TO_RUN="run-zksync.sh"
    ;;
    "default")
    SCRIPT_TO_RUN="run-ethereum.sh"
    ;;
    *)
    echo "Unknown CHAIN_TYPE: $CHAIN_TYPE"
    exit 1
    ;;
esac

# If --no-sync argument is passed, keep .indexed file
if [ "$NO_SYNC" = false ]; then
    rm -f .indexed
fi

# Run the selected script
./$SCRIPT_TO_RUN