#!/bin/bash
DbHost_cloud="192.168.41.1"
DbUser_cloud="cloud_user"
DbPasswd_cloud="Cloud_User@123"
DbName_cloud="mamcdb_cloud"
DbPort_cloud=3306
DbHost_star="192.168.101.192"
DbUser_star="hduser"
DbPasswd_star="hduser"
DbName_star="mamcdb"
DbPort_star=3306
log_star=$(date +%d_%m_%H_%M)
newtime=$(date +%T)

while true

do
for t  in {1800..0}; do

sleep 1
#printf "getting asianet domain missing list......."
printf "\r\e[1;32mgetting star domain missing list............\e[0m \e[1;33m$t\e[0m \e[1;32min seconds\e[0m"

done


#list=$(echo "SELECT clipid FROM webplaylistviewer WHERE playlistdate >= CURDATE() and  clipid NOT IN (SELECT clipid FROM mamdatalist WHERE deviceuid IN ('4b576a44-eeda-11eb-98ed-0cc47aaa5f96','4b593031-eeda-11eb-98ed-0cc47aaa5f96','4b599274-eeda-11eb-98ed-0cc47aaa5f96')) AND eventtype = 'PRI'  AND channelid IN (SELECT uid FROM channels WHERE uid IN ('63b51ca2-c01d-4725-a8c6-e49353092bbd','681378d5-e11f-4384-843a-cb8ea50c61bf','c27f7403-a53f-468b-abe4-23240e5a1879','dd5d5e4a-d09b-48e4-afb6-dab2e5058fea')) group by clipid" | mysql -h $DbHost_cloud -P $DbPort_cloud -u $DbUser_cloud -p$DbPasswd_cloud ${DbName_cloud}) 2> /dev/null


list=$(echo "select clipid from webfixlistviewer where clipid NOT IN (SELECT clipid FROM mamdatalist WHERE deviceuid IN ('4b5a09cf-eeda-11eb-98ed-0cc47aaa5f96','4b576a44-eeda-11eb-98ed-0cc47aaa5f96','4b593031-eeda-11eb-98ed-0cc47aaa5f96','4b599274-eeda-11eb-98ed-0cc47aaa5f96','596be1c3-41da-45ab-b7a7-4e5db0910ca5')) union SELECT * FROM (SELECT clipid FROM webplaylistviewer  WHERE playlistdate >= CURDATE() AND clipid NOT IN (SELECT clipid FROM mamdatalist WHERE deviceuid IN ('4b576a44-eeda-11eb-98ed-0cc47aaa5f96','4b593031-eeda-11eb-98ed-0cc47aaa5f96','4b599274-eeda-11eb-98ed-0cc47aaa5f96')) AND eventtype = 'PRI'  AND channelid IN (SELECT uid FROM channels ) group by clipid) AS T" | mysql -h $DbHost_cloud -P $DbPort_cloud -u $DbUser_cloud -p$DbPasswd_cloud ${DbName_cloud}) 2> /dev/null

for i in $list

do

path=$(echo "select concat(d.ftpdirectory,m.clipid,m.ext) from devicemaster d join mamdatalist m on d.deviceid = m.deviceid where  m.clipid = '$i' and devicename like '%NAS%' and m.ext in ('.mxf','.MXF') limit 1" | mysql -h $DbHost_star -P $DbPort_star -u $DbUser_star -p$DbPasswd_star ${DbName_star})  2> /dev/null

user=$(echo "select concat(d.ftpuser,',',d.ftppassword) from devicemaster d join mamdatalist m on d.deviceid = m.deviceid where  m.clipid = '$i' and devicename like '%NAS%' and m.ext in ('.mxf','.MXF')  limit 1"  | mysql -h $DbHost_star -P $DbPort_star -u $DbUser_star -p$DbPasswd_star ${DbName_star})  2> /dev/null


ip=$(echo "select d.ftpip from devicemaster d join mamdatalist m on d.deviceid = m.deviceid where  m.clipid = '$i' and devicename like '%NAS%' and m.ext in ('.mxf','.MXF') limit 1" |  mysql -h $DbHost_star -P $DbPort_star -u $DbUser_star -p$DbPasswd_star ${DbName_star})  2> /dev/null


_path=$(echo $path | awk '{print $2}')
_user=$(echo $user | awk '{print $2}')
_ip=$(echo $ip | awk '{print $2}')
if [[ $_ip == "172.29.220.197" ]]

then

_ip='172.16.223.115'

elif [[ $_ip == "172.29.220.187" ]]

then

_ip='172.16.223.101'

elif [[ $_ip == "172.29.220.192" ]]

then

_ip='172.16.223.104'

elif [[ $_ip == "172.29.220.145" ]]

then

_ip='172.16.223.105'

elif [[ $_ip == "172.29.220.144" ]]

then
_ip='172.16.223.107'

elif [[ $_ip == "172.29.220.139" ]]

then

_ip='172.16.223.108'

elif [[ $_ip == "172.29.220.253" ]]

then

_ip='172.16.223.109'

elif [[ $_ip == "172.29.220.194" ]]
then
_ip='172.16.223.110'

elif [[ $_ip == "172.29.220.195" ]]
then
_ip='172.16.223.112'

elif [[ $_ip == "172.29.220.196" ]]
then
_ip='172.16.223.116'

elif [[ $_ip == "172.29.220.193" ]]
then
_ip='172.16.223.117'

elif [[ $_ip == "172.29.220.200" ]]
then
_ip='172.16.223.120'

elif [[ $_ip == "172.29.220.150" ]]
then
_ip='172.16.223.150'

elif [[ $_ip == "172.29.220.189" ]]
then
_ip='172.16.223.102'

elif [[ $_ip == "172.29.220.188" ]]
then
_ip='172.16.223.103'

else [[ $_ip == "172.29.220.191" ]]
_ip='172.16.223.113'



fi

unbuffer lftp -e 'set ftp:ssl-allow true; set ssl:verify-certificate no;set net:timeout 30; set net:max_retries 3 ;  set net:reconnect_interval_base 30; set net:connection_limit 1;set net:limit-rate 0:31457280;
get -O  '/Video/star/input/video_input/' '$_path' ;
bye' -u  $_user  $_ip:21



if [[ $? -eq 0 ]]
then
echo "$i successfull tranfer at $newtime" | tee -a /home/mamgroup/trans_log_star/${log_star}.txt
else
echo "$i Tranfer Failed" | tee -a /home/mamgroup/trans_log_star/${log_star}.txt
fi

sleep 2
done

clear 
done

