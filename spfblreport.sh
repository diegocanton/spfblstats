#!/bin/bash
# -*- coding: utf-8 -*-
export PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin
version="2.11 alfa - 2017-02-09_01:12"

function head(){

	echo "SPFBL v$version - by Leandro Rodrigues - leandro@spfbl.net"
}

case $1 in
'report')
	
	if [[ $2 =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
		TODAY=$2
	else
		TODAY=`date +%Y-%m-%d`
	fi

	LOGFILE=/var/log/spfbl/spfbl."$TODAY".log
	LOGTEMP=/tmp/spfblreport
	LOGTEMPDNS=/tmp/spfblreportdns

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

	executaReportIp(){
		#Gera Report
		egrep "SPFTCP[0-9]+ SPFBL" /var/log/spfbl/$LOGTEMP | grep $4 | awk -F" " '{print $9}' | sort | uniq -c | sort -n
	}
	
	executaReportSender(){
		#Gera Report
		egrep "SPFTCP[0-9]+ SPFBL" /var/log/spfbl/$LOGTEMP | grep $4 | awk -F" " '{print $10}' | sort | uniq -c | sort -n
	}
	
	executaReportHelo(){
		#Gera Report
		egrep "SPFTCP[0-9]+ SPFBL" /var/log/spfbl/$LOGTEMP | grep $4 | awk -F" " '{print $11}' | sort | uniq -c | sort -n
	}

	executaReportDest(){
		#Gera Report
		egrep "SPFTCP[0-9]+ SPFBL" /var/log/spfbl/$LOGTEMP | grep $4 | awk -F" " '{print $12}' | sort | uniq -c | sort -n
	}
	
	executaReportServer(){
		#Gera Report
		egrep "SPFTCP[0-9]+ SPFBL" /var/log/spfbl/$LOGTEMP | grep $4 | awk -F" " '{print $5  $6}' | sort | uniq -c | sort -n
	}
	
	executaReportUser(){
		#Gera Report
		egrep "SPFTCP[0-9]+ SPFBL" /var/log/spfbl/$LOGTEMP | grep $4 | awk -F" " '{print $7}' | sort | uniq -c | sort -n
	}
	
	executaReportDNSBL(){
		#Calcula a quantidade de consultas DNSBL por tipo de resposta
		#127.0.0.2 - Rejeitada por má reputação
		#127.0.0.3 - Rejeitada por suspeita/problemas na identificação
		#NXDOMAIN - Aceita por não estar listada

	}

	# Executa processos
	verificaLogFile
	verificaLogTemp      # apaga temporarios
	verificaLogTempDns   # apaga temporarios
	criaLogTemp
	
	#EXEMPLO LOG
	#2017-02-10T21:44:06.994-0200 00020 SPFTCP002 SPFBL <SERVER_IP> <SERVER_NAME> <MAIL_USER>: SPF <SENDER_IP> <SENDER_MAIL> <SENDER_HELO> <DEST_MAIL> => <ERROR> <TICKET>
	#2017-02-10T20:25:48.431-0200 00001 DNSUDP002 DNSBL <DNS_SERVER_REQUESTER> NXDOMAIN: <QUERY_TYPE> aaa.bbb.ccc.ddd.dnsbl.domain.tld. => 86400 <result>

	
	case $3 in
	'ip')
		# EXEC $9
		executaReportIp
		;;
	'sender')
		#EXEC $10
		executaReportSender
		;;
	'helo')
		#EXEC $11
		executaReportHelo
		;;
	'dest')
		#EXEC $12
		executaReportDest
		;;
	'server')
		#EXEC $5 $6
		executaReportServer
		;;
	'user')
		#EXEC $7
		executaReportUser
		;;
	*)
		printf "ERRO DE SINTAXE"
		;;
	esac

	verificaLogTemp      # apaga temporarios
	verificaLogTempDns   # apaga temporarios
	exit 0

	# Fim processos

	;;
*)
	head
	printf " Sintaxe: $0 report YYYY-MM-DD ip (error|domainSender)\n"
	printf " Sintaxe: $0 report YYYY-MM-DD sender (error|domainSender)\n"
	printf " Sintaxe: $0 report YYYY-MM-DD helo (error|domainSender)\n"
	printf " Sintaxe: $0 report YYYY-MM-DD dest (error|domainSender)\n"
	printf " Sintaxe: $0 report YYYY-MM-DD server (error|domainSender)\n"
	printf " Sintaxe: $0 report YYYY-MM-DD user (error|domainSender)\n"
	;;
esac