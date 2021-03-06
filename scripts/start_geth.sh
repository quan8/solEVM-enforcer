#!/usr/bin/env bash

# Exit script as soon as a command fails.
set -o errexit

geth_port=8222
geth=$(which geth)

geth_running() {
  nc -z localhost "$geth_port"
}

start_geth() {
  rm -rf /tmp/geth

  args=(
  "--datadir=/tmp/geth"
  "--networkid=99"
  "--maxpeers=0"
  "--nodiscover"
  "--nousb"
  "--targetgaslimit=0xfffffffffffff"
  "--gasprice=0x01"
  "--rpc"
  "--rpcport="$geth_port""
  "--rpcapi=eth,net,web3,debug"
  )
  $geth "${args[@]}" init scripts/genesis.json
  $geth "${args[@]}" js scripts/geth.js
  $geth "${args[@]}" --mine &> /dev/null &

  geth_pid=$!

  while true; do
    echo 'waiting for geth'
    if [ -e /tmp/geth/geth.ipc ]; then
      break
    fi
    sleep 1
  done
  $geth "${args[@]}" --exec 'loadScript("scripts/geth.js")' attach
}

if geth_running; then
  echo "Using existing instance"
else
  echo "Starting new instance"
  start_geth
fi
