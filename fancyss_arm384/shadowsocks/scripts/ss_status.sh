#!/bin/sh

# shadowsocks script for koolshare merlin armv7l 384 router with kernel 2.6.36.4

source /koolshare/scripts/base.sh
LOGFILE_F=/tmp/upload/ssf_status.txt
LOGFILE_C=/tmp/upload/ssc_status.txt
LOGTIME=$(TZ=UTC-8 date -R "+%Y-%m-%d %H:%M:%S")
LOGTIME1=$(TZ=UTC-8 date -R "+%m-%d %H:%M:%S")
CURRENT=$(dbus get ssconf_basic_node)
eval $(dbus export ss_failover_enable)

get_china_status(){
	local ret=`httping www.baidu.com -s -Z -c1 -f -t 3 2>/dev/null|sed -n '2p'|sed 's/seq=0//g'|sed 's/([0-9]\+\sbytes),\s//g'`
	[ "$ss_failover_enable" == "1" ] && echo $LOGTIME1 $ret >> $LOGFILE_C
	local S1=`echo $ret|grep -Eo "200 OK"`
	if [ -n "$S1" ]; then
#		local S2=`echo $ret|sed 's/time=//g'|awk '{printf "%.0f ms\n",$(NF -3)}'`
#		log2='国内链接 【'$LOGTIME'】 ✓&nbsp;&nbsp;'$S2''
		log2='国内链接 【'$LOGTIME'】 ✓&nbsp;'
	else
		log2='国内链接 【'$LOGTIME'】 <font color='#FF0000'>X</font>'
	fi
}

get_foreign_status(){
	local ret=`httping www.google.com.tw -s -Z -c1 -f -t 3 2>/dev/null|sed -n '2p'|sed 's/seq=0//g'|sed 's/([0-9]\+\sbytes),\s//g'`
	[ "$ss_failover_enable" == "1" ] && echo $LOGTIME1 $ret "[`dbus get ssconf_basic_name_$CURRENT`]" >> $LOGFILE_F
	local S1=`echo $ret|grep -Eo "200 OK"`
	if [ -n "$S1" ]; then
#		local S2=`echo $ret|sed 's/time=//g'|awk '{printf "%.0f ms\n",$(NF -3)}'`
#		log1='国外链接 【'$LOGTIME'】 ✓&nbsp;&nbsp;'$S2''
		log1='国外链接 【'$LOGTIME'】 ✓&nbsp;'
	else
		log1='国外链接 【'$LOGTIME'】 <font color='#FF0000'>X</font>'
	fi
}

[ "`ps|grep ssconfig.sh|grep -v grep`" ] && exit
[ "`ps|grep ss_v2ray.sh|grep -v grep`" ] && exit
[ "`dbus get ss_basic_enable`" != "1" ] && exit

get_china_status
get_foreign_status
if [ "$ss_failover_enable" == "1" ];then
	echo "$log1@@$log2" > /tmp/upload/ss_status.txt
else
	http_response "$log1@@$log2"
fi
