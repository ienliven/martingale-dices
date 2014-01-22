#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )";

ROUND="0";

MAX_ROUND="6";

BET="0.0015";

STATUS="LOOSER";

MIN_BAL=$( echo "2^$MAX_ROUND * $BET" | bc | sed 's/^\./0./g'); 
BALANCE=$(btc_balance.sh);

shout_lost () {
    if [ -x /usr/bin/afplay ]; then
        /usr/bin/afplay ./sounds/lost.wav;
    fi;
}

shout_win () {
    echo "You won!";
    echo;
    if [ -x /usr/bin/afplay ]; then
        /usr/bin/afplay ./sounds/coin.wav;
    fi;
}

is_gt () {
    echo $1 $2 | awk '{if ($1 > $2) print "true"; else print "false"}';
}

check_balance () {
    BALANCE=$(btc_balance.sh);
    CONTINUE=$(is_gt $BALANCE $MIN_BAL);
    if [ $CONTINUE == "true" ]; then 
        return 0;
    else
        return 1;
    fi;
}

lock () {
    bitcoind walletlock 2>/dev/null;
}

unlock () {
    bitcoind walletpassphrase thereisnoplacelike127.0.0.1 5 2>/dev/null;
}

wait_if_needed () {
    HAVECASH=1;
    while [ $HAVECASH -eq 1 ]; do
        check_balance;
        HAVECASH=$?;
        
        echo "sleeping until we get some more coins.";
        sleep 30;
    done;
}

echo "Starting bets at `date`."
echo;
echo "Balance: $BALANCE."
echo;
echo "Min. round: ${MIN_BAL}, max. rounds: $MAX_ROUND, bet base $BET.";
echo;

CONTINUE=$(check_balance);
if [ "$CONTINUE" == "0" ]; then
    echo "You have no money to continue, exiting.";
    exit 0;
fi;

while true; do
    
    if [ $STATUS == "WINNER" ]; then
        shout_win;
        
        ROUND="0";
        STATUS="LOOSER";
        
        BALANCE=$(btc_balance.sh);
        echo;
        echo "balance: $BALANCE";
        echo;
        # wait_if_needed;
    else
        if [ "$ROUND" != "0" ]; then
            shout_lost;
        fi;
    fi;

    SLEEP=$(( ( RANDOM % 85 ) + 5 ));
    sleep $SLEEP;
    
    ROUND="$( echo "$ROUND+1" | bc )";
    if [ "$ROUND" -gt "$MAX_ROUND" ]; then
        # echo "Max. round reached, exiting.";
        # exit 1;

        echo "Max. round reached, restarting.";
        
        ROUND="0";
        STATUS="LOOSER";
    fi;
    
    ROUND_LESS_ONE=$(echo "$MAX_ROUND-1" | bc);
    if [ "$ROUND" -gt "$ROUND_LESS_ONE" ]; then
        read -p "Continue? Round $ROUND " -n 1 -r
        echo;
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "More days will come.";
            exit 1;
        fi;
    fi;
    
    CAN_RUN="false";
    while [ $CAN_RUN == "false" ]; do
        
        AMOUNT=$( echo "(2^($ROUND-1))*$BET" | bc | sed 's/^\./0./g' );
        BALANCE=$(btc_balance.sh);
        
        CAN_RUN=$(is_gt "$BALANCE" "$AMOUNT");
        sleep 5;
    done;
    
    unlock;
    TXID=$(btc_bet.sh $BET $ROUND);
    lock;
    
    if [[ $? != 0 || -z "$TXID" ]]; then 
        SLEEP=$(( ( RANDOM % 60 ) + 10 ));
        echo "Something went sideways on round $ROUND, lets give it $SLEEP seconds and try again.";
        sleep $SLEEP;
        
        ROUND=$( echo "$ROUND-1" | bc );
        continue;
    else
        STATUS=$(btc_watch.sh $TXID);
    fi;
done;
