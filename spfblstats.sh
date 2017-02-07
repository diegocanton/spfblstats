#!/bin/bash
# -*- coding: utf-8 -*-
export PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin
version="2.11 alfa - 2017-02-07_22:33"

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

	LOGFILE=/var/log/spfbl/spfbl."$TODAY".log
	LOGTEMP=/tmp/spfblstats
	LOGTEMPDNS=/tmp/spfblstatsdns

	verificaLogFile(){
		if [[ ! -f "$LOGFILE" ]]; then
			echo "";
			echo -e "\e[41m The file $LOGFILE was not found in your system! \e[0m";
			echo "";
			exit 1
		fi
	}

	verificaLogTemp(){
		if [[ -f "$LOGTEMP" ]]; then
			rm "$LOGTEMP"
		fi
	}

	verificaLogTempDns(){
		if [[ -f "$LOGTEMPDNS" ]]; then
			rm "$LOGTEMPDNS"
		fi
	}

	criaLogTemp(){
		egrep " SPFTCP[0-9]+ SPFBL " $LOGFILE > $LOGTEMP
		egrep " DNSUDP[0-9]+ DNSBL " $LOGFILE > $LOGTEMPDNS
	}

	executaStats(){
		BLOCKED=$(grep -c BLOCKED "$LOGTEMP")
		FAIL=$(grep -c ' FAIL' "$LOGTEMP")
		FLAG=$(grep -c FLAG "$LOGTEMP")
		HOLD=$(grep -c HOLD "$LOGTEMP")
		INTERRUPTED=$(grep -c INTERRUPTED "$LOGTEMP")
		INVALID=$(grep -c INVALID "$LOGTEMP")
		NEUTRAL=$(grep -c NEUTRAL "$LOGTEMP")
		NONE=$(grep -c NONE "$LOGTEMP")
		NXDOMAIN=$(grep -c NXDOMAIN "$LOGTEMP")
		NXSENDER=$(grep -c NXSENDER "$LOGTEMP")
		PASS=$(grep -c PASS "$LOGTEMP")
		WHITE=$(grep -c WHITE "$LOGTEMP")
		SOFTFAIL=$(grep -c SOFTFAIL "$LOGTEMP")
		SPAMTRAP=$(grep -c SPAMTRAP "$LOGTEMP")
		INEXISTENT=$(grep -c INEXISTENT "$LOGTEMP")
		TIMEOUT=$(grep -c TIMEOUT "$LOGTEMP")

		TOTALES=$(echo $WHITE + $BLOCKED + $FLAG + $HOLD + $NXDOMAIN + $NXSENDER + $PASS + $TIMEOUT + $NONE + $SOFTFAIL + $NEUTRAL + $INTERRUPTED + $SPAMTRAP + $INEXISTENT + $INVALID + $FAIL | bc)
		BLOCKTOTAL=$( echo $BLOCKED + $FLAG + $HOLD + $NXDOMAIN + $NXSENDER + $TIMEOUT + $NONE + $SOFTFAIL + $NEUTRAL + $INTERRUPTED + $SPAMTRAP + $INEXISTENT + $INVALID + $FAIL | bc)
		PASSTOTAL=$( echo $WHITE + $PASS | bc)

		GREYLIST=$(grep -c GREYLIST "$LOGTEMP")
		LISTED=$(grep -c LISTED "$LOGTEMP")
		TOTALEST=$(echo $LISTED + $GREYLIST | bc)

		DNSBLBLOCK=$(egrep -c "TXT .* => 86400 http://" "$LOGFILE")
		DNSBLOK=$(egrep -c "A .* => 3600 NXDOMAIN" "$LOGFILE")
		TOTALESDNSBL=$(echo $DNSBLBLOCK + $DNSBLOK | bc)

		clear

		echo '=========================='
		echo '= SPFBL Daily Statistics ='
		echo '=      '"$TODAY"'        ='
		echo '=========================='
		echo '=    Permanent actions   ='
		echo '=========================='

		if [[ $WHITE != 0 ]]; then
			echo '     WHITE:' $(echo "scale=0;($WHITE*100) / $TOTALES" | bc)'% - '"$WHITE"
		fi

		if [[ $PASS != 0 ]]; then
			echo '      PASS:' $(echo "scale=0;($PASS*100) / $TOTALES" | bc)'% - '"$PASS"
		fi

		if [[ $BLOCKED != 0 ]]; then
			echo '   BLOCKED:' $(echo "scale=0;($BLOCKED*100) / $TOTALES" | bc)'% - '"$BLOCKED"
		fi

		if [[ $FAIL != 0 ]]; then
			echo '      FAIL:' $(echo "scale=0;($FAIL*100) / $TOTALES" | bc)'% - '"$FAIL"
		fi

		if [[ $FLAG != 0 ]]; then
			echo '      FLAG:' $(echo "scale=0;($FLAG*100) / $TOTALES" | bc)'% - '"$FLAG"
		fi

		if [[ $HOLD != 0 ]]; then
			echo '      HOLD:' $(echo "scale=0;($HOLD*100) / $TOTALES" | bc)'% - '"$HOLD"
		fi

		if [[ $INTERRUPTED != 0 ]]; then
			echo '  INTRRPTD:' $(echo "scale=0;($INTERRUPTED*100) / $TOTALES" | bc)'% - '"$INTERRUPTED"
		fi

		if [[ $INVALID != 0 ]]; then
			echo '   INVALID:' $(echo "scale=0;($INVALID*100) / $TOTALES" | bc)'% - '"$INVALID"
		fi

		if [[ $NEUTRAL != 0 ]]; then
			echo '   NEUTRAL:' $(echo "scale=0;($NEUTRAL*100) / $TOTALES" | bc)'% - '"$NEUTRAL"
		fi

		if [[ $NONE != 0 ]]; then
			echo '      NONE:' $(echo "scale=0;($NONE*100) / $TOTALES" | bc)'% - '"$NONE"
		fi

		if [[ $NXDOMAIN != 0 ]]; then
			echo '  NXDOMAIN:' $(echo "scale=0;($NXDOMAIN*100) / $TOTALES" | bc)'% - '"$NXDOMAIN"
		fi

		if [[ $NXSENDER != 0 ]]; then
			echo '  NXSENDER:' $(echo "scale=0;($NXSENDER*100) / $TOTALES" | bc)'% - '"$NXSENDER"
		fi

		if [[ $SOFTFAIL != 0 ]]; then
			echo '  SOFTFAIL:' $(echo "scale=0;($SOFTFAIL*100) / $TOTALES" | bc)'% - '"$SOFTFAIL"
		fi

		if [[ $SPAMTRAP != 0 ]]; then
			echo '  SPAMTRAP:' $(echo "scale=0;($SPAMTRAP*100) / $TOTALES" | bc)'% - '"$SPAMTRAP"
		fi

		if [[ $INEXISTENT != 0 ]]; then
			echo 'INEXISTENT:' $(echo "scale=0;($INEXISTENT*100) / $TOTALES" | bc)'% - '"$INEXISTENT"
		fi

		if [[ $TIMEOUT != 0 ]]; then
			echo '   TIMEOUT:' $(echo "scale=0;($TIMEOUT*100) / $TOTALES" | bc)'% - '"$TIMEOUT"
		fi

		echo '  ----------------------'
		echo '   ALL BLOCKED :' $(echo "scale=0;($BLOCKTOTAL*100) / $TOTALES" | bc)'% - '"$BLOCKTOTAL"
		echo '   ALL ACCEPTED:' $(echo "scale=0;($PASSTOTAL*100) / $TOTALES" | bc)'% - '"$PASSTOTAL"
		echo '   ALL =TOTAL= :' $(echo "scale=0;($TOTALES*100) / $TOTALES" | bc)'% - '"$TOTALES"
		echo '=========================='
	}

	executaStatsExtra(){
		if [[ $TOTALEST != 0 ]]; then
			echo ''
			echo '=========================='
			echo '=   Temporary actions    ='
			echo '=========================='
			echo '  GREYLIST: ' $(echo "scale=0;($GREYLIST*100) / $TOTALEST" | bc)'% - '"$GREYLIST"
			echo '    LISTED: ' $(echo "scale=0;($LISTED*100) / $TOTALEST" | bc)'% - '"$LISTED"
			echo '  ----------------------'
			echo '     TOTAL: ' $(echo "scale=0;($TOTALEST*100) / $TOTALEST" | bc)'% - '"$TOTALEST"
			echo '=========================='
			echo ''
			echo '=========================='
			echo ' Permanent: ' $(echo "scale=0; ($TOTALES*100) / ($TOTALES + $TOTALEST)" | bc)'% - '"$TOTALES"
			echo ' Temporary: ' $(echo "scale=0; ($TOTALEST*100) / ($TOTALES + $TOTALEST)" | bc)'% - '"$TOTALEST"
			echo '  =TOTAL= : ' $(echo "scale=0;(($TOTALEST + $TOTALES)*100) / ($TOTALEST + $TOTALES)" | bc)'% - ' $( echo "$TOTALEST + $TOTALES" | bc)
			echo '=========================='
			echo ''
			echo '=========================='
			echo '=      DNSBL BLOCKs      ='
			echo '=========================='
			echo '        OK: ' $(echo "scale=0; ($DNSBLOK*100) / $TOTALESDNSBL" | bc)'% - '"$DNSBLOK"
			echo '     BLOCK: ' $(echo "scale=0; ($DNSBLBLOCK*100) / $TOTALESDNSBL" | bc)'% - '"$DNSBLBLOCK"
			echo '     TOTAL: ' $(echo "scale=0;($TOTALESDNSBL*100) / $TOTALESDNSBL" | bc)'% - '"$TOTALESDNSBL"
			echo '=========================='
		else
			echo ''
			echo -e "\e[41m Variabile TOTALEST returned zero as value! \e[0m";
			echo ''
		fi
	}

	# Executa processos

	verificaLogFile
	verificaLogTemp      # apaga temporarios
	verificaLogTempDns   # apaga temporarios
	criaLogTemp
	executaStats
	executaStatsExtra
	verificaLogTemp      # apaga temporarios
	verificaLogTempDns   # apaga temporarios
	exit 0

	# Fim processos

	;;
*)
	head
	printf " Sintaxe: $0 stats YYYY-MM-DD\n"
	;;
esac
