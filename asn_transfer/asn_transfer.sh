#!/bin/bash
DbHost_cloud="192.168.41.1"
DbUser_cloud="cloud_user"
DbPasswd_cloud="Cloud_User@123"
DbName_cloud="mamcdb_cloud"
DbPort_cloud=3306
DbHost_asn="172.29.220.78"
DbUser_asn="user_asn"
DbPasswd_asn="escl@asn"
DbName_asn="mamcdbasn"
DbPort_asn=3306
log_asn=$(date +%d_%m_%H_%M)
newtime=$(date +%T)

while true

do
for t  in {1800..0}; do

sleep 1
printf "\r\e[1;32mgetting asianet domain missing list.......\e[0m \e[1;33m$t\e[0m \e[1;32min seconds\e[0m"

done
#list=$(echo "SELECT clipid FROM webplaylistviewer WHERE clipid NOT IN (SELECT clipid FROM mamdatalist WHERE deviceuid IN ('4b576a44-eeda-11eb-98ed-0cc47aaa5f96','4b593031-eeda-11eb-98ed-0cc47aaa5f96','4b599274-eeda-11eb-98ed-0cc47aaa5f96','4b5a09cf-eeda-11eb-98ed-0cc47aaa5f96','596be1c3-41da-45ab-b7a7-4e5db0910ca5')) AND eventtype = 'PRI'  AND channelid IN (SELECT uid FROM channels WHERE uid in ('dd5d5e4a-d09b-48e4-afb6-dab2e505asme','dd5d5e4a-d09b-48e4-afb6-dab2e505macl','dd5d5e4a-d09b-48e4-afb6-dab2e505svml','dd5d5e4a-d09b-48e4-afb6-dab2e505vtnt') ) group by clipid" | mysql -h $DbHost_cloud -P $DbPort_cloud -u $DbUser_cloud -p$DbPasswd_cloud ${DbName_cloud}) 2> /dev/null

list=$(echo "select clipid from webfixlistviewer where clipid NOT IN (SELECT clipid FROM mamdatalist WHERE deviceuid IN ('4b5a09cf-eeda-11eb-98ed-0cc47aaa5f96','4b576a44-eeda-11eb-98ed-0cc47aaa5f96','4b593031-eeda-11eb-98ed-0cc47aaa5f96','4b599274-eeda-11eb-98ed-0cc47aaa5f96','596be1c3-41da-45ab-b7a7-4e5db0910ca5')) union SELECT * FROM (SELECT clipid FROM webplaylistviewer  WHERE playlistdate >= CURDATE() AND clipid NOT IN (SELECT clipid FROM mamdatalist WHERE deviceuid IN ('4b576a44-eeda-11eb-98ed-0cc47aaa5f96','4b593031-eeda-11eb-98ed-0cc47aaa5f96','4b599274-eeda-11eb-98ed-0cc47aaa5f96')) AND eventtype = 'PRI'  AND channelid IN (SELECT uid FROM channels ) group by clipid) AS T" | mysql -h $DbHost_cloud -P $DbPort_cloud -u $DbUser_cloud -p$DbPasswd_cloud ${DbName_cloud}) 2> /dev/null


for i in $list

do

path=$(echo "select concat(d.ftpdirectory,m.clipid,m.ext) from devicemaster d join mamdatalist m on d.deviceid = m.deviceid where  m.clipid = '$i' and (devicename like '%NAS%' or devicename like '%ASIANET_M%' or devicename like '%FTP%')  and m.ext in ('.mxf','.MXF') limit 1" | mysql -h $DbHost_asn -P $DbPort_asn -u $DbUser_asn -p$DbPasswd_asn ${DbName_asn})  2> /dev/null

user=$(echo "select concat(d.ftpuser,',',d.ftppassword) from devicemaster d join mamdatalist m on d.deviceid = m.deviceid where  m.clipid = '$i' and (devicename like '%NAS%' or devicename like '%ASIANET_M%' or devicename like '%FTP%') and m.ext in ('.mxf','.MXF') limit 1"  | mysql -h $DbHost_asn -P $DbPort_asn -u $DbUser_asn -p$DbPasswd_asn ${DbName_asn})  2> /dev/null


ip=$(echo "select d.ftpip from devicemaster d join mamdatalist m on d.deviceid = m.deviceid where  m.clipid = '$i' and (devicename like '%NAS%' or devicename like '%ASIANET_M%' or devicename like '%FTP%' ) and m.ext in ('.mxf','.MXF') limit 1" |  mysql -h $DbHost_asn -P $DbPort_asn -u $DbUser_asn -p$DbPasswd_asn ${DbName_asn})  2> /dev/null


_path=$(echo $path | awk '{print $2}')
_user=$(echo $user | awk '{print $2}')
_ip=$(echo $ip | awk '{print $2}')

unbuffer lftp -e 'set ftp:ssl-allow true; set ssl:verify-certificate no;set net:timeout 30; set net:max_retries 3 ;  set net:reconnect_interval_base 30; set net:connection_limit 1;set net:limit-rate 0:31457280;
get -O  '/Video/star/input/video_input/' '$_path' ;
bye' -u  $_user  $_ip:21



if [[ $? -eq 0 ]]
then
echo "$i successfull tranfer at $newtime" | tee -a /home/mamgroup/trans_log_asn/${log_asn}.txt
else
echo "$i Tranfer Failed" | tee -a /home/mamgroup/trans_log_asn/${log_asn}.txt
fi

sleep 2
done 

clear
done

