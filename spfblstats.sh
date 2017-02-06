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

	BLOCKED=$(egrep" SPFTCP[0-9]+ SPFBL " | grep -c BLOCKED "$LOGPATH"spfbl."$TODAY".log)
	FAIL=$(egrep" SPFTCP[0-9]+ SPFBL " | grep -c ' FAIL' "$LOGPATH"spfbl."$TODAY".log)
	FLAG=$(egrep" SPFTCP[0-9]+ SPFBL " | grep -c FLAG "$LOGPATH"spfbl."$TODAY".log)
	HOLD=$(egrep" SPFTCP[0-9]+ SPFBL " | grep -c HOLD "$LOGPATH"spfbl."$TODAY".log)
	INTERRUPTED=$(egrep" SPFTCP[0-9]+ SPFBL " | grep -c INTERRUPTED "$LOGPATH"spfbl."$TODAY".log)
	INVALID=$(egrep" SPFTCP[0-9]+ SPFBL " | grep -c INVALID "$LOGPATH"spfbl."$TODAY".log)
	NEUTRAL=$(egrep" SPFTCP[0-9]+ SPFBL " | grep -c NEUTRAL "$LOGPATH"spfbl."$TODAY".log)
	NONE=$(egrep" SPFTCP[0-9]+ SPFBL " | grep -c NONE "$LOGPATH"spfbl."$TODAY".log)
	NXDOMAIN=$(egrep" SPFTCP[0-9]+ SPFBL " | grep -c NXDOMAIN "$LOGPATH"spfbl."$TODAY".log)
	NXSENDER=$(egrep" SPFTCP[0-9]+ SPFBL " | grep -c NXSENDER "$LOGPATH"spfbl."$TODAY".log)
	PASS=$(egrep" SPFTCP[0-9]+ SPFBL " | grep -c PASS "$LOGPATH"spfbl."$TODAY".log)
	WHITE=$(egrep" SPFTCP[0-9]+ SPFBL " | grep -c WHITE "$LOGPATH"spfbl."$TODAY".log)
	SOFTFAIL=$(egrep" SPFTCP[0-9]+ SPFBL " | grep -c SOFTFAIL "$LOGPATH"spfbl."$TODAY".log)
	SPAMTRAP=$(egrep" SPFTCP[0-9]+ SPFBL " | grep -c SPAMTRAP "$LOGPATH"spfbl."$TODAY".log)
	INEXISTENT=$(egrep" SPFTCP[0-9]+ SPFBL " | grep -c INEXISTENT "$LOGPATH"spfbl."$TODAY".log)
	TIMEOUT=$(egrep" SPFTCP[0-9]+ SPFBL " | grep -c TIMEOUT "$LOGPATH"spfbl."$TODAY".log)

	TOTALES=$(echo $WHITE + $BLOCKED + $FLAG + $HOLD + $NXDOMAIN + $NXSENDER + $PASS + $TIMEOUT + $NONE + $SOFTFAIL + $NEUTRAL + $INTERRUPTED + $SPAMTRAP + $INEXISTENT + $INVALID + $FAIL | bc)

	GREYLIST=$(egrep" SPFTCP[0-9]+ SPFBL " | grep -c GREYLIST "$LOGPATH"spfbl."$TODAY".log)
	LISTED=$(egrep" SPFTCP[0-9]+ SPFBL " | grep -c LISTED "$LOGPATH"spfbl."$TODAY".log)
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
