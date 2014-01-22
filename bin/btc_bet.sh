#!/bin/bash

BETS[1]="1bonesUhqtbLAGKWZuawCzsYqmYWEgPwH"; # 75%
BETS[2]="1bones5gF1HJeiexQus6UtvhU4EUD4qfj"; # 62.5%
BETS[3]="1bonesF1NYidcd5veLqy1RZgF4mpYJWXZ"; # 50%
BETS[4]="1bonesF1NYidcd5veLqy1RZgF4mpYJWXZ"; # 50%
BETS[5]="1bonesF1NYidcd5veLqy1RZgF4mpYJWXZ"; # 50%
BETS[6]="1bonesF1NYidcd5veLqy1RZgF4mpYJWXZ"; # 50%
BETS[7]="1bonesF1NYidcd5veLqy1RZgF4mpYJWXZ"; # 50%
BETS[8]="1bonesF1NYidcd5veLqy1RZgF4mpYJWXZ"; # 50%
BETS[9]="1bonesF1NYidcd5veLqy1RZgF4mpYJWXZ"; # 50%

# BETS[5]="1bones2foMuSFG5dr4x6N8k5hDyPTs8fu"; # 87.5%
# BETS[6]="1bonesPdRYS91Mq9arbiUratHy2J5gDut"; # 93.75%
# BETS[7]="1bonesPdRYS91Mq9arbiUratHy2J5gDut"; # 93.75%

# FIFTY="1bones5gF1HJeiexQus6UtvhU4EUD4qfj";

BASE_BET="$1";
if [ -z "$BASE_BET" ]; then
    BASE_BET="0.0010";
fi;

ROUND="$2";
if [ -z "$ROUND" ]; then
    ROUND="1";
fi;
FIFTY=${BETS[$ROUND]};
EXP=$(echo "$ROUND-1" | bc);

BET=$(echo "($BASE_BET*(2^$EXP))" | bc | sed 's/^\./0./g');
if [[ "$ROUND" == "2" && "$FIFTY" == "1bones5gF1HJeiexQus6UtvhU4EUD4qfj" ]]; then
    SUM=$(echo "$BASE_BET*0.5" | bc);
    BET=$(echo "$BET+$SUM" | bc | sed 's/^\./0./g');
fi;

TXID=$(bitcoind sendfrom "" "$FIFTY" "$BET");

if [ -z "$TXID" ]; then 
    exit 1;
fi;

echo "$TXID";
exit 0;
