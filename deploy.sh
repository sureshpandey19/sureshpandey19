#!/bin/bash

while [[ "$#" -gt 0 ]]; do
      case $1 in
		-H|--host) host="$2"; shift ;;
	        -u|--username) username="$2"; shift ;;
                -p|--password) password="$2"; shift;;
                -P|--port) Port="$2"; shift;;
                -D|--destinationpath) d_path="$2"; shift;;
		-S|--sourcepath) s_path="$2"; shift;;
		-c|--clipname) clip=$2; shift;;
		-e|--extension) ext=$2; shift;;
                -h|--help) help="Help"; ;;
		-v|--version) version="Version"; ;;
	                  *) echo "Unknown parameter passed: $1"; exit 1 ;;
      esac
shift
done

#echo ""
if [[ $version == "Version" ]]
then
    echo "Component_Deploy_Create Ver. 20.21.12.1 Copy Right@2020 - Planetcast media Services limited,NOIDA,IND"
fi

if [[ $help == "Help" ]]
then
	#echo ""
	echo ""
	echo "Usage: Component_Deploy_Create [-Options...]"
	echo ""
	echo "---------------------------------------------------------"
	echo "-H,--host                   Inspector Host IP Address or Name"
	echo "-u,--username               Host Root User Name"
	echo "-p,--password               Host Root User Password"
	echo "-P,--port                   Host SSH Connection Port"
	echo "-D,--destinationpath        Binary Destination Path"
	echo "-S,--sourcepath        	  Binary Source Path"
	echo "-c,--clipname		  Clip Name"
	echo "-e,--extension		  Extension Name of Clip"
	echo "-v,--version                Application Version"
	echo "-h,--help                   Application Help" 
	echo "---------------------------------------------------------"
fi	

if [[ $clip !=  "" && $ext != ""  &&  $s_path != "" && $d_path != "" ]] 
then

    /home/skp/testcode/MD_CORRECTION_SCRIPT_new.sh $clip  $ext $s_path $d_path
	STATUS=`echo $?`
	if [ $STATUS -eq 0 ]
	then
        	echo "Process Success"
	elif [ $STATUS -eq 2 ]
	then
		echo "Provided File or Path Doest Not exists"
	elif [ $STATUS -eq 1 ]
        then
		echo "Process Failed"
	fi	

else
	echo "Error in Provided Parameter, please check help(-h/--help) option"
	echo ""
	echo ""
	exit 1
fi


