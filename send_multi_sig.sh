#!/bin/env bash

NETWORK=${1:-LOCAL}
DO_SWITCH=${2:-YES}
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ACTIONS_DIR="${SCRIPT_DIR}/actions"
if [ ! -d $ACTIONS_DIR ]; then
  echo "${ACTIONS_DIR} does not exist"
  exit
fi

ENDPOINT=http://127.0.0.1:8888
ACCOUNT=spaceranger1

if [ $NETWORK == "JUNGLE" ]; then
  ENDPOINT=https://jungle4.cryptolions.io:443
  ACCOUNT=hokieshokies
fi

if [ $NETWORK == "KYLIN" ]; then
  ENDPOINT=https://api.kylin.alohaeos.com
  ACCOUNT=spacerang.gm
fi

if [ $NETWORK == "MAINNET" ]; then
  ENDPOINT=https://eos.api.eosnation.io
  ACCOUNT=proposer.enf
fi

if [ $DO_SWITCH != "YES" ]; then
  if [ ! -s .eosc-vault-${ACCOUNT}.json ]; then
    eosc vault create --vault-file $HOME/eosio-wallet/.eosc-vault-${ACCOUNT}.json --import
  fi

  if [ ! -s ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.6.1.JSON ]; then
    echo "ERROR: failed to find ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.6.1.JSON EXITING"
    exit
  fi
  # Error check on JSON 
  cat ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.6.1.JSON | jq 1> /dev/null
  if [ $? != 0 ]; then
      echo "ERROR: invalid JSON for EOSIO_SYSTEM_v3.6.1.JSON EXITING"
      exit
  fi
  eosc -u $ENDPOINT multisig propose $ACCOUNT enfsys.ric \
      ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.6.1.JSON \
      --request-producers --vault-file $HOME/eosio-wallet/.eosc-vault-${ACCOUNT}.json
fi

