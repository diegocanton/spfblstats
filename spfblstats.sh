#!/bin/bash
### CONFIGURACOES ###
IP_SERVIDOR="spfbl.ensite.com.br"
PORTA_SERVIDOR="9877"
PORTA_ADMIN="9875"
OTP_SECRET=""
DUMP_PATH="/tmp"
QUERY_TIMEOUT="10"
MAX_TIMEOUT="100"

export PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin
version="2.10"

function head(){

    echo "SPFBL v$version - by Leandro Rodrigues - leandro@spfbl.net"
}

case $1 in
'stats')
	#
	# gera estatistica diaria
	# saida em linha de comando
	#
	# Formato: spfbl.sh stats AAAA-MM-DD
	# Exemplo: spfbl.sh stats 2017-01-31
	#
	# apenas "spfbl.sh stats" mostra o resultado do dia
	#

	if [[ $2 =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
	    TODAY=$2
	else
	    TODAY=`date +%Y-%m-%d`
	fi
	
	LOGPATH=/var/log/spfbl/

	BLOCKED=$(grep BLOCKED "$LOGPATH"spfbl."$TODAY".log | egrep -c " SPFTCP[0-9]+ SPFBL ")
	FAIL=$(grep ' FAIL' "$LOGPATH"spfbl."$TODAY".log | egrep -c " SPFTCP[0-9]+ SPFBL ")
	FLAG=$(grep FLAG "$LOGPATH"spfbl."$TODAY".log | egrep -c " SPFTCP[0-9]+ SPFBL ")
	HOLD=$(grep HOLD "$LOGPATH"spfbl."$TODAY".log | egrep -c " SPFTCP[0-9]+ SPFBL ")
	INTERRUPTED=$(grep INTERRUPTED "$LOGPATH"spfbl."$TODAY".log | egrep -c " SPFTCP[0-9]+ SPFBL ")
	INVALID=$(grep INVALID "$LOGPATH"spfbl."$TODAY".log | egrep -c " SPFTCP[0-9]+ SPFBL ")
	NEUTRAL=$(grep NEUTRAL "$LOGPATH"spfbl."$TODAY".log | egrep -c " SPFTCP[0-9]+ SPFBL ")
	NONE=$(grep NONE "$LOGPATH"spfbl."$TODAY".log | egrep -c " SPFTCP[0-9]+ SPFBL ")
	NXDOMAIN=$(grep NXDOMAIN "$LOGPATH"spfbl."$TODAY".log | egrep -c " SPFTCP[0-9]+ SPFBL ")
	NXSENDER=$(grep NXSENDER "$LOGPATH"spfbl."$TODAY".log | egrep -c " SPFTCP[0-9]+ SPFBL ")
	PASS=$(grep PASS "$LOGPATH"spfbl."$TODAY".log | egrep -c " SPFTCP[0-9]+ SPFBL ")
	WHITE=$(grep WHITE "$LOGPATH"spfbl."$TODAY".log | egrep -c " SPFTCP[0-9]+ SPFBL ")
	SOFTFAIL=$(grep SOFTFAIL "$LOGPATH"spfbl."$TODAY".log | egrep -c " SPFTCP[0-9]+ SPFBL ")
	SPAMTRAP=$(grep SPAMTRAP "$LOGPATH"spfbl."$TODAY".log | egrep -c " SPFTCP[0-9]+ SPFBL ")
	INEXISTENT=$(grep INEXISTENT "$LOGPATH"spfbl."$TODAY".log | egrep -c " SPFTCP[0-9]+ SPFBL ")
	TIMEOUT=$(grep TIMEOUT "$LOGPATH"spfbl."$TODAY".log | egrep -c " SPFTCP[0-9]+ SPFBL ")

	TOTALES=$(echo $WHITE + $BLOCKED + $FLAG + $HOLD + $NXDOMAIN + $NXSENDER + $PASS + $TIMEOUT + $NONE + $SOFTFAIL + $NEUTRAL + $INTERRUPTED + $SPAMTRAP + $INEXISTENT + $INVALID + $FAIL | bc)

	GREYLIST=$(grep GREYLIST "$LOGPATH"spfbl."$TODAY".log | egrep -c " SPFTCP[0-9]+ SPFBL ")
	LISTED=$(grep LISTED "$LOGPATH"spfbl."$TODAY".log | egrep -c " SPFTCP[0-9]+ SPFBL ")
	TOTALEST=$(echo $LISTED + $GREYLIST | bc)

	clear

	echo '=========================='
	echo '= SPFBL Daily Statistics ='
	echo '=      '"$TODAY"'        ='
	echo '=========================='
	echo '=    Permanent actions   ='
	echo '=========================='
	echo '     WHITE:' $(echo "scale=0;($WHITE*100) / $TOTALES" | bc)'% - '"$WHITE"
	echo '      PASS:' $(echo "scale=0;($PASS*100) / $TOTALES" | bc)'% - '"$PASS"
	echo '   BLOCKED:' $(echo "scale=0;($BLOCKED*100) / $TOTALES" | bc)'% - '"$BLOCKED"
	echo '      FAIL:' $(echo "scale=0;($FAIL*100) / $TOTALES" | bc)'% - '"$FAIL"
	echo '      FLAG:' $(echo "scale=0;($FLAG*100) / $TOTALES" | bc)'% - '"$FLAG"
	echo '      HOLD:' $(echo "scale=0;($HOLD*100) / $TOTALES" | bc)'% - '"$HOLD"
	echo '  INTRRPTD:' $(echo "scale=0;($INTERRUPTED*100) / $TOTALES" | bc)'% - '"$INTERRUPTED"
	echo '   INVALID:' $(echo "scale=0;($INVALID*100) / $TOTALES" | bc)'% - '"$INVALID"
	echo '   NEUTRAL:' $(echo "scale=0;($NEUTRAL*100) / $TOTALES" | bc)'% - '"$NEUTRAL"
	echo '      NONE:' $(echo "scale=0;($NONE*100) / $TOTALES" | bc)'% - '"$NONE"
	echo '  NXDOMAIN:' $(echo "scale=0;($NXDOMAIN*100) / $TOTALES" | bc)'% - '"$NXDOMAIN"
	echo '  NXSENDER:' $(echo "scale=0;($NXSENDER*100) / $TOTALES" | bc)'% - '"$NXSENDER"
	echo '  SOFTFAIL:' $(echo "scale=0;($SOFTFAIL*100) / $TOTALES" | bc)'% - '"$SOFTFAIL"
	echo '  SPAMTRAP:' $(echo "scale=0;($SPAMTRAP*100) / $TOTALES" | bc)'% - '"$SPAMTRAP"
	echo 'INEXISTENT:' $(echo "scale=0;($INEXISTENT*100) / $TOTALES" | bc)'% - '"$INEXISTENT"
	echo '   TIMEOUT:' $(echo "scale=0;($TIMEOUT*100) / $TOTALES" | bc)'% - '"$TIMEOUT"
	echo '  ----------------------'
	echo '     TOTAL:' $(echo "scale=0;($TOTALES*100) / $TOTALES" | bc)'% - '"$TOTALES"
	echo '=========================='
	echo ''
	echo '=========================='
	echo '=   Temporary actions    ='
	echo '=========================='
	echo '  GREYLIST:' $(echo "scale=0;($GREYLIST*100) / $TOTALEST" | bc)'% - '"$GREYLIST"
	echo '    LISTED:' $(echo "scale=0;($LISTED*100) / $TOTALEST" | bc)'% - '"$LISTED"
	echo '  ----------------------'
	echo '     TOTAL:' $(echo "scale=0;($TOTALEST*100) / $TOTALEST" | bc)'% - '"$TOTALEST"
	echo '=========================='

	echo ''
	echo '=========================='
	echo ' Permanent: ' $(echo "scale=0; ($TOTALES*100) / ($TOTALES + $TOTALEST)" | bc)'% - '"$TOTALES"
	echo ' Temporary: ' $(echo "scale=0; ($TOTALEST*100) / ($TOTALES + $TOTALEST)" | bc)'% - '"$TOTALEST"
	echo '    TOTAL:' $(echo "scale=0;(($TOTALEST + $TOTALES)*100) / ($TOTALEST + $TOTALES)" | bc)'% - ' $( echo "$TOTALEST + $TOTALES" | bc)
	echo '=========================='
    ;;
*)
	head
	printf "    $0 stats\n"
    ;;
esac