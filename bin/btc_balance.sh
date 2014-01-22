#!/bin/bash

# UNSPENT=$(/usr/local/bin/bitcoind listunspent | grep amount | awk '{ print $3 }' | tr ",n" '+' | tr "\n" ' ' | sed 's/+ /+/g' | sed 's/+$//g' | bc | sed 's/^\./0./g');

BALANCE=$(bitcoind getbalance);

echo "$BALANCE" | bc | sed 's/^\./0./g';


