#!/bin/bash

TXOUT="$1";
if [ -z "$TXOUT" ]; then
    read TXOUT;
fi;

TXOUT_AMOUNT="$(bitcoind gettransaction $TXOUT | grep -oE '\"amount\" : \-(.*),' | head -n 1 | awk '{ print $3 }' | sed 's/,$//g')";
TXOUT_FEE="$(bitcoind gettransaction $TXOUT | grep -oE '\"fee\" : \-(.*),' | head -n 1 | awk '{ print $3 }' | sed 's/,$//g')";
TXOUT_TIME="$(bitcoind gettransaction $TXOUT | grep -oE '\"time\" : (.*),' | head -n 1 | awk '{ print $3 }' | sed 's/,$//g')";

echo "bet ${TXOUT_AMOUNT#"-"} + ${TXOUT_FEE#"-"} (fee)" >&2;

is_winner () {
    echo $1 $2 | awk '{if ($1 > $2) print "LOOSER"; else print "WINNER"}';
}

TXIN="";
while [ -z "$TXIN" ]; do
    
    TXIN_TIME=$(bitcoind listtransactions "" 1 | grep -oE '"time" : (.*),' | head -n 1 | awk '{ print $3 }' | sed 's/,$//g');
    
    if [ $TXOUT_TIME -lt $TXIN_TIME ]; then
        TXIN="$(bitcoind listtransactions "" 1 | grep -oE '"txid" : "(.*)",' | awk '{ print $3 }' | sed 's/,$//g')";
        TXIN_AMOUNT="$(bitcoind listtransactions "" 1 | grep -oE '"amount" : (.*),' | head -n 1 | awk '{ print $3 }' | sed 's/,$//g')";
        
        RESULT=$(is_winner ${TXOUT_AMOUNT#"-"} ${TXIN_AMOUNT});
        echo $RESULT;
        
        break;
    fi;
    
    sleep 1;
done;

exit 0;
