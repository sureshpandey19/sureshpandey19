#!/bin/bash

#####################written by suresh at 15102021 for star conversion process if metadata error in content###########################
#####################written by suresh at 16102021 for star conversion process if metadata error in content resolution and audio bitrate handled with listing case###########################
QC_FAIL=$3
FINAL_PATH=$4
LOG='/Video/star/tc_log'
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOGNAME=$(date '+%Y-%m-%d')
FFMPEG=$(which ffmpeg)
MEDIAINFO=$(which mediainfo)
FFPROBE=$(which ffprobe)
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
ERROR='descriptor|TemporalOffset'
id=${1}.${2}

if [[ ! -f $FINAL_PATH/$id ]] && [[ -f $QC_FAIL/$id ]]; then


sleep 1



rm -rf .error

sleep 1

$FFPROBE -v error -select_streams v:0 $QC_FAIL/$id 2> .error

if grep -RE $ERROR .error; then




TRACK=$($MEDIAINFO $QC_FAIL/$id | grep 'Audio' | wc -l)
TYPE=$($MEDIAINFO $QC_FAIL/$id | grep 'Scan type' | awk -F ':' '{print $2}')
SOM=$($MEDIAINFO $QC_FAIL/$id | grep 'Time code of first frame' | head -2 | tail -1 | awk '{print $7}')
BIT_RATE=$($MEDIAINFO $QC_FAIL/$id | grep -i 'mbps' |grep -i 'bit rate' | head -2 | tail -1 | awk -F ':' '{print $2}' | awk '{print $1}')
AUDIO_BIT_RATE=$($MEDIAINFO $QC_FAIL/$id | grep -i 'kbps' |grep -i 'bit rate' | head -2 | tail -1 | awk -F ':' '{print $2}' | awk '{print $1}')
CONVERTED_BITRATE=$(echo $BIT_RATE*1000 | bc)
VIDEO_TRACK_1=$($FFPROBE -i $QC_FAIL/$id -show_streams 2>&1 | grep 'Stream #0:1' | awk -F ':' '{print $3}')
VIDEO_TRACK_0=$($FFPROBE -i $QC_FAIL/$id -show_streams 2>&1 | grep 'Stream #0:0' | awk -F ':' '{print $3}')
CHANNEL_8=$($MEDIAINFO $QC_FAIL/$id  | grep 'Channel' | wc -l)
CHANNEL_2=$($MEDIAINFO $QC_FAIL/$id  | grep 'Channel' | wc -l)
CLIP_ID=$(echo $id | awk -F . '{print $1}')
CLIP_EXT=$(echo $id | awk -F . '{print $2}')
VIDEO_WIDTH=$($MEDIAINFO $QC_FAIL/$id | grep -i 'width' | awk -F ':' {'print $2'} | awk -F pixels '{print $1}' | sed 's/ //g')
VIDEO_HEIGHT=$($MEDIAINFO $QC_FAIL/$id | grep -i 'height' | awk -F ':' {'print $2'} | awk -F pixels '{print $1}' | sed 's/ //g')
ASPECT=$($MEDIAINFO $QC_FAIL/$id | grep -i 'aspect' | awk '{print $5}')
if [[ $TRACK -eq '8' ]] && [[ $TYPE == *Interlaced* ]] && [[ $VIDEO_TRACK_1 == *Video* ]] && [[ ! -f $FINAL_PATH/$id ]] ; then

	 echo 'content is: ' $id \n 'Its total track are: ' $TRACK \n 'Its SOM and bit rate is: ' $SOM $BIT_RATE | tee -a $LOG/${LOGNAME}.txt

        sleep 1

        echo 'Starting conversion process...'
        rm -rf $QC_FAIL/RawFiles/*
        #rm -rvf $QC_FAIL/RawFiles/*
        mkdir -p $QC_FAIL/RawFiles

	$FFMPEG -y -i  $QC_FAIL/$id  -map 0:1 -top 1 -flags:v +ilme+ildct -vcodec mpeg2video -acodec pcm_s24le -b:v ${CONVERTED_BITRATE}k $QC_FAIL/RawFiles/abc.m2v -map_channel 0.2.0  -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc1.wav -map_channel 0.3.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc2.wav -map_channel 0.4.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc3.wav -map_channel 0.5.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc4.wav -map_channel 0.6.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc5.wav -map_channel 0.7.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc6.wav -map_channel 0.8.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc7.wav -map_channel 0.9.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc8.wav ##2>> $LOG/${LOGNAME}.txt

			if [[ $? -eq 0 ]]; then
$FFMPEG -y -i $QC_FAIL/RawFiles/abc.m2v -i $QC_FAIL/RawFiles/abc1.wav -i $QC_FAIL/RawFiles/abc2.wav -i $QC_FAIL/RawFiles/abc3.wav -i $QC_FAIL/RawFiles/abc4.wav -i $QC_FAIL/RawFiles/abc5.wav -i $QC_FAIL/RawFiles/abc6.wav -i $QC_FAIL/RawFiles/abc7.wav -i $QC_FAIL/RawFiles/abc8.wav  -vcodec mpeg2video -acodec pcm_s24le -b:v ${CONVERTED_BITRATE}k -bufsize ${CONVERTED_BITRATE}k -minrate ${CONVERTED_BITRATE}k -maxrate ${CONVERTED_BITRATE}k -b:a ${AUDIO_BIT_RATE}k -timecode $SOM -map 0:0  -map 1:0  -map 2:0 -map 3:0 -map 4:0 -map 5:0 -map 6:0 -map 7:0 -map 8:0 -s ${VIDEO_WIDTH}x${VIDEO_HEIGHT} -aspect $ASPECT  -top 1 -flags:v +ilme+ildct $FINAL_PATH/${CLIP_ID}_WR.${CLIP_EXT} ##2>> $LOG/${LOGNAME}.txt 
				if [[ $? -eq 0 ]]; then
				echo 'FILE SUCCESSFULLY CONVERTED!' $id "at" $TIMESTAMP | tee -a $LOG/${LOGNAME}.txt
					echo '========================================================' | tee -a $LOG/${LOGNAME}.txt
					exit 0
					else 
					echo "PROCESS FAILED" $id "at" $TIMESTAMP | tee -a $LOG/${LOGNAME}.txt
					echo '========================================================' | tee -a $LOG/${LOGNAME}.txt
					exit 1
				fi
			sleep 2
				echo $id >> $LOG/.temp
			rm -rvf $QC_FAIL/RawFiles/*
			fi
elif [[ $TRACK -eq '8' ]] && [[ $TYPE == *Interlaced* ]] && [[ $VIDEO_TRACK_0 == *Video* ]] && [[ ! -f $FINAL_PATH/$id ]] ; then

         echo 'content is: ' $id \n 'Its total track are: ' $TRACK \n 'Its SOM and bit rate is: ' $SOM $BIT_RATE | tee -a $LOG/${LOGNAME}.txt

        sleep 1

        echo 'Starting conversion process...'
        rm -rf $QC_FAIL/RawFiles/*
        #rm -rvf $QC_FAIL/RawFiles/*
        mkdir -p $QC_FAIL/RawFiles

        $FFMPEG -y -i  $QC_FAIL/$id  -map 0:0 -top 1 -flags:v +ilme+ildct -vcodec mpeg2video -acodec pcm_s24le -b:v ${CONVERTED_BITRATE}k $QC_FAIL/RawFiles/abc.m2v -map_channel 0.1.0  -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc1.wav -map_channel 0.2.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc2.wav -map_channel 0.3.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc3.wav -map_channel 0.4.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc4.wav -map_channel 0.5.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc5.wav -map_channel 0.6.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc6.wav -map_channel 0.7.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc7.wav -map_channel 0.8.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc8.wav ##2>> $LOG/${LOGNAME}.txt

                        if [[ $? -eq 0 ]]; then
$FFMPEG -y -i $QC_FAIL/RawFiles/abc.m2v -i $QC_FAIL/RawFiles/abc1.wav -i $QC_FAIL/RawFiles/abc2.wav -i $QC_FAIL/RawFiles/abc3.wav -i $QC_FAIL/RawFiles/abc4.wav -i $QC_FAIL/RawFiles/abc5.wav -i $QC_FAIL/RawFiles/abc6.wav -i $QC_FAIL/RawFiles/abc7.wav -i $QC_FAIL/RawFiles/abc8.wav  -vcodec mpeg2video -acodec pcm_s24le -b:v ${CONVERTED_BITRATE}k -bufsize ${CONVERTED_BITRATE}k -minrate ${CONVERTED_BITRATE}k -maxrate ${CONVERTED_BITRATE}k -b:a ${AUDIO_BIT_RATE}k -timecode $SOM -map 0:0  -map 1:0  -map 2:0 -map 3:0 -map 4:0 -map 5:0 -map 6:0 -map 7:0 -map 8:0 -s ${VIDEO_WIDTH}x${VIDEO_HEIGHT} -aspect $ASPECT  -top 1 -flags:v +ilme+ildct $FINAL_PATH/${CLIP_ID}_WR.${CLIP_EXT} ##2>> $LOG/${LOGNAME}.txt
                                if [[ $? -eq 0 ]]; then
                                echo 'FILE SUCCESSFULLY CONVERTED!' $id "at" $TIMESTAMP | tee -a $LOG/${LOGNAME}.txt
                                        echo '========================================================' | tee -a $LOG/${LOGNAME}.txt
					exit 0
                                        else
                                        echo "PROCESS FAILED" $id "at" $TIMESTAMP | tee -a $LOG/${LOGNAME}.txt
                                        echo '========================================================' | tee -a $LOG/${LOGNAME}.txt
					exit 1
                                fi
                        sleep 2
                                echo $id >> $LOG/.temp
                        rm -rvf $QC_FAIL/RawFiles/*
                        fi
elif [[ $TRACK -eq '16' ]] && [[ $TYPE == *Interlaced* ]] && [[ $VIDEO_TRACK_0 == *Video* ]] && [[ ! -f $FINAL_PATH/$id ]] ; then

         echo 'content is: ' $id \n 'Its total track are: ' $TRACK \n 'Its SOM and bit rate is: ' $SOM $BIT_RATE | tee -a $LOG/${LOGNAME}.txt

        sleep 1

        echo 'Starting conversion process...'
        rm -rf $QC_FAIL/RawFiles/*
        #rm -rvf $QC_FAIL/RawFiles/*
        mkdir -p $QC_FAIL/RawFiles

        $FFMPEG -y -i  $QC_FAIL/$id  -map 0:0 -top 1 -flags:v +ilme+ildct -vcodec mpeg2video -acodec pcm_s24le -b:v ${CONVERTED_BITRATE}k $QC_FAIL/RawFiles/abc.m2v -map_channel 0.1.0  -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc1.wav -map_channel 0.2.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc2.wav -map_channel 0.3.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc3.wav -map_channel 0.4.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc4.wav -map_channel 0.5.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc5.wav -map_channel 0.6.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc6.wav -map_channel 0.7.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc7.wav -map_channel 0.8.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc8.wav  -map_channel 0.9.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc9.wav  -map_channel 0.10.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc10.wav  -map_channel 0.11.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc11.wav  -map_channel 0.12.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc12.wav  -map_channel 0.13.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc13.wav  -map_channel 0.14.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc14.wav  -map_channel 0.15.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc15.wav  -map_channel 0.16.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc16.wav  ##2>> $LOG/${LOGNAME}.txt

                        if [[ $? -eq 0 ]]; then
$FFMPEG -y -i $QC_FAIL/RawFiles/abc.m2v -i $QC_FAIL/RawFiles/abc1.wav -i $QC_FAIL/RawFiles/abc2.wav -i $QC_FAIL/RawFiles/abc3.wav -i $QC_FAIL/RawFiles/abc4.wav -i $QC_FAIL/RawFiles/abc5.wav -i $QC_FAIL/RawFiles/abc6.wav -i $QC_FAIL/RawFiles/abc7.wav -i $QC_FAIL/RawFiles/abc8.wav -i $QC_FAIL/RawFiles/abc9.wav -i $QC_FAIL/RawFiles/abc10.wav -i $QC_FAIL/RawFiles/abc11.wav -i $QC_FAIL/RawFiles/abc12.wav -i $QC_FAIL/RawFiles/abc13.wav -i $QC_FAIL/RawFiles/abc14.wav -i $QC_FAIL/RawFiles/abc15.wav -i $QC_FAIL/RawFiles/abc16.wav  -vcodec mpeg2video -acodec pcm_s24le -b:v ${CONVERTED_BITRATE}k -bufsize ${CONVERTED_BITRATE}k -minrate ${CONVERTED_BITRATE}k -maxrate ${CONVERTED_BITRATE}k -b:a ${AUDIO_BIT_RATE}k -timecode $SOM -map 0:0  -map 1:0  -map 2:0 -map 3:0 -map 4:0 -map 5:0 -map 6:0 -map 7:0 -map 8:0 -map 9:0 -map 10:0 -map 11:0 -map 12:0 -map 13:0 -map 14:0 -map 16:0 -s ${VIDEO_WIDTH}x${VIDEO_HEIGHT} -aspect $ASPECT  -top 1 -flags:v +ilme+ildct $FINAL_PATH/${CLIP_ID}_WR.${CLIP_EXT} ##2>> $LOG/${LOGNAME}.txt
                                if [[ $? -eq 0 ]]; then
                                echo 'FILE SUCCESSFULLY CONVERTED!' $id "at" $TIMESTAMP | tee -a $LOG/${LOGNAME}.txt
                                        echo '========================================================' | tee -a $LOG/${LOGNAME}.txt
					exit 0
                                        else
                                        echo "PROCESS FAILED" $id "at" $TIMESTAMP | tee -a $LOG/${LOGNAME}.txt
                                        echo '========================================================' | tee -a $LOG/${LOGNAME}.txt
					exit 1
                                fi
                        sleep 2
                                echo $id >> $LOG/.temp
#                        rm -rvf $QC_FAIL/RawFiles/*
                        fi


		elif [[ $TRACK -eq '4' ]] || [[ $TRACK -eq '5' ]] && [[ $TYPE == *Interlaced* ]] && [[ $VIDEO_TRACK_1 == *Video* ]] && [[ ! -f $FINAL_PATH/$id ]]; then
			echo 'content is: ' $id \n 'Its total track are: ' $TRACK \n 'Its SOM and bit rate is: ' $SOM $BIT_RATE | tee -a $LOG/${LOGNAME}.txt
                          sleep 1
                        echo 'Starting conversion process...'
                        rm -rf $QC_FAIL/RawFiles/*
                        rm -rvf $QC_FAIL/RawFiles/*
                        mkdir -p $QC_FAIL/RawFiles

			$FFMPEG -y -i $QC_FAIL/$id   -map 0:1 -top 1 -flags:v +ilme+ildct -vcodec mpeg2video -acodec pcm_s24le -b:v ${CONVERTED_BITRATE}k $QC_FAIL/RawFiles/abc.m2v -map_channel 0.2.0  -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc1.wav -map_channel 0.3.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc2.wav -map_channel 0.4.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc3.wav -map_channel 0.5.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc4.wav ##2>> $LOG/${LOGNAME}.txt

			if [[ $? -eq 0 ]]; then

$FFMPEG -y -i $QC_FAIL/RawFiles/abc.m2v -i $QC_FAIL/RawFiles/abc1.wav -i $QC_FAIL/RawFiles/abc2.wav  -i $QC_FAIL/RawFiles/abc3.wav  -i $QC_FAIL/RawFiles/abc4.wav  -vcodec mpeg2video -acodec pcm_s24le -b:v ${CONVERTED_BITRATE}k -bufsize ${CONVERTED_BITRATE}k -minrate ${CONVERTED_BITRATE}k -maxrate ${CONVERTED_BITRATE}k -b:a ${AUDIO_BIT_RATE}k -timecode $SOM -map 0:0  -map 1:0  -map 2:0 -map 3:0 -map 4:0  -s ${VIDEO_WIDTH}x${VIDEO_HEIGHT} -aspect $ASPECT  -top 1 -flags:v +ilme+ildct $FINAL_PATH/${CLIP_ID}_WR.${CLIP_EXT} ##2>> $LOG/${LOGNAME}.txt
				if [[ $? -eq 0 ]]; then
				echo 'FILE SUCCESSFULLY CONVERTED!' $id "at" $TIMESTAMP | tee -a $LOG/${LOGNAME}.txt
					echo '========================================================' | tee -a $LOG/${LOGNAME}.txt
					exit 0
					else
                                        echo "PROCESS FAILED" $id "at" $TIMESTAMP | tee -a $LOG/${LOGNAME}.txt

					echo '========================================================' | tee -a $LOG/${LOGNAME}.txt
					exit 1
				fi	
			sleep 2			
				echo $id >> $LOG/.temp
			rm -rvf $QC_FAIL/RawFiles/*
			 fi
		elif [[ $TRACK -eq '4' ]] || [[ $TRACK -eq '5' ]] && [[ $TYPE == *Interlaced* ]] && [[ $VIDEO_TRACK_0 == *Video* ]] && [[ ! -f $FINAL_PATH/$id ]]; then	
                        echo 'content is: ' $id \n 'Its total track are: ' $TRACK \n 'Its SOM and bit rate is: ' $SOM $BIT_RATE | tee -a $LOG/${LOGNAME}.txt
                          sleep 1
                        echo 'Starting conversion process...'
                        rm -rf $QC_FAIL/RawFiles/*
                        rm -rvf $QC_FAIL/RawFiles/*
                        mkdir -p $QC_FAIL/RawFiles

                        $FFMPEG -y -i $QC_FAIL/$id   -map 0:0 -top 1 -flags:v +ilme+ildct -vcodec mpeg2video -acodec pcm_s24le -b:v ${CONVERTED_BITRATE}k $QC_FAIL/RawFiles/abc.m2v -map_channel 0.1.0  -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc1.wav -map_channel 0.2.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc2.wav -map_channel 0.3.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc3.wav -map_channel 0.4.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc4.wav ##2>> $LOG/${LOGNAME}.txt

                        if [[ $? -eq 0 ]]; then

$FFMPEG -y -i $QC_FAIL/RawFiles/abc.m2v -i $QC_FAIL/RawFiles/abc1.wav -i $QC_FAIL/RawFiles/abc2.wav  -i $QC_FAIL/RawFiles/abc3.wav  -i $QC_FAIL/RawFiles/abc4.wav  -vcodec mpeg2video -acodec pcm_s24le -b:v ${CONVERTED_BITRATE}k -bufsize ${CONVERTED_BITRATE}k -minrate ${CONVERTED_BITRATE}k -maxrate ${CONVERTED_BITRATE}k -b:a ${AUDIO_BIT_RATE}k -timecode $SOM -map 0:0  -map 1:0  -map 2:0 -map 3:0 -map 4:0  -s ${VIDEO_WIDTH}x${VIDEO_HEIGHT} -aspect $ASPECT  -top 1 -flags:v +ilme+ildct $FINAL_PATH/${CLIP_ID}_WR.${CLIP_EXT} ##2>> $LOG/${LOGNAME}.txt
                                if [[ $? -eq 0 ]]; then
                                echo 'FILE SUCCESSFULLY CONVERTED!' $id "at" $TIMESTAMP | tee -a $LOG/${LOGNAME}.txt
					exit 0
                                        echo '========================================================' | tee -a $LOG/${LOGNAME}.txt
                                        else
                                        echo "PROCESS FAILED" $id "at" $TIMESTAMP | tee -a $LOG/${LOGNAME}.txt
					exit 1

                                        echo '========================================================' | tee -a $LOG/${LOGNAME}.txt
                                fi
                        sleep 2
                                echo $id >> $LOG/.temp
                        rm -rvf $QC_FAIL/RawFiles/*
                         fi

			#NEW
			 elif [[ $TRACK -eq '2' ]] && [[ $TYPE == *Interlaced* ]] && [[ $VIDEO_TRACK_0 == *Video* ]] && [[ ! -f $FINAL_PATH/$id ]]; then
                        echo 'content is: ' $id \n 'Its total track are: ' $TRACK \n 'Its SOM and bit rate is: ' $SOM $BIT_RATE | tee -a $LOG/${LOGNAME}.txt
                          sleep 1
                        echo 'Starting conversion process...'
                        rm -rf $QC_FAIL/RawFiles/*
                        #rm -rvf $QC_FAIL/RawFiles/*
                        mkdir -p $QC_FAIL/RawFiles

                        $FFMPEG -y -i $QC_FAIL/$id   -map 0:0 -top 1 -flags:v +ilme+ildct -vcodec mpeg2video -acodec pcm_s24le -b:v ${CONVERTED_BITRATE}k $QC_FAIL/RawFiles/abc.m2v -map_channel 0.1.0  -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc1.wav -map_channel 0.2.0   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc2.wav ##2>> $LOG/${LOGNAME}.txt

                        if [[ $? -eq 0 ]]; then

$FFMPEG -y -i $QC_FAIL/RawFiles/abc.m2v -i $QC_FAIL/RawFiles/abc1.wav -i $QC_FAIL/RawFiles/abc2.wav   -vcodec mpeg2video -acodec pcm_s24le -b:v ${CONVERTED_BITRATE}k -bufsize ${CONVERTED_BITRATE}k -minrate ${CONVERTED_BITRATE}k -maxrate ${CONVERTED_BITRATE}k -b:a ${AUDIO_BIT_RATE}k -timecode $SOM -map 0:0  -map 1:0  -map 2:0   -s ${VIDEO_WIDTH}x${VIDEO_HEIGHT} -aspect $ASPECT  -top 1 -flags:v +ilme+ildct $FINAL_PATH/${CLIP_ID}_WR.${CLIP_EXT} ##2>> $LOG/${LOGNAME}.txt
                                if [[ $? -eq 0 ]]; then
                                echo 'FILE SUCCESSFULLY CONVERTED!' $id "at" $TIMESTAMP | tee -a $LOG/${LOGNAME}.txt
                                        echo '========================================================' | tee -a $LOG/${LOGNAME}.txt
					exit 0
                                        else
                                        echo "PROCESS FAILED" $id "at" $TIMESTAMP | tee -a $LOG/${LOGNAME}.txt

                                        echo '========================================================' | tee -a $LOG/${LOGNAME}.txt
					exit 1
                                fi
                        sleep 2
                                echo $id >> $LOG/.temp
                        rm -rvf $QC_FAIL/RawFiles/*
                         fi

		elif [[ $TRACK -eq '1' ]] && [[ $TYPE == *Interlaced* ]] && [[ $VIDEO_TRACK_0 == *Video* ]] && [[ $CHANNEL_2 -eq '2' ]] && [[ ! -f $FINAL_PATH/$id ]]; then
			 echo 'content is: ' $id \n 'Its total track are: ' $TRACK \n 'Its SOM and bit rate is: ' $SOM $BIT_RATE | tee -a $LOG/${LOGNAME}.txt
                         sleep 1
                        echo 'Starting conversion process...'
                        rm -rf $QC_FAIL/RawFiles/*
                        mkdir -p $QC_FAIL/RawFiles

                        $FFMPEG -y -i $QC_FAIL/$id   -map 0:0 -top 1 -flags:v +ilme+ildct -vcodec mpeg2video -acodec pcm_s24le -b:v ${CONVERTED_BITRATE}k $QC_FAIL/RawFiles/abc.m2v -map_channel 0.1.0  -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc1.wav -map_channel 0.1.1   -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc2.wav  ##2>> $LOG/${LOGNAME}.txt

			if [[ $? -eq 0 ]]; then

			$FFMPEG -y -i $QC_FAIL/RawFiles/abc.m2v -i $QC_FAIL/RawFiles/abc1.wav -i $QC_FAIL/RawFiles/abc2.wav    -vcodec mpeg2video -acodec pcm_s24le -b:v ${CONVERTED_BITRATE}k -bufsize ${CONVERTED_BITRATE}k -minrate ${CONVERTED_BITRATE}k -maxrate ${CONVERTED_BITRATE}k -b:a ${AUDIO_BIT_RATE}k -timecode $SOM -map 0:0  -map 1:0  -map 2:0 -s ${VIDEO_WIDTH}x${VIDEO_HEIGHT} -aspect $ASPECT  -top 1 -flags:v +ilme+ildct $FINAL_PATH/${CLIP_ID}_WR.${CLIP_EXT} ##2>> $LOG/${LOGNAME}.txt
			if [[ $? -eq 0 ]]; then
                                echo 'FILE SUCCESSFULLY CONVERTED!' $id "at" $TIMESTAMP | tee -a $LOG/${LOGNAME}.txt
				echo '========================================================' | tee -a $LOG/${LOGNAME}.txt
				exit 0
                                        else
                                        echo "PROCESS FAILED" $id "at" $TIMESTAMP | tee -a $LOG/${LOGNAME}.txt
					echo '========================================================' | tee -a $LOG/${LOGNAME}.txt
				exit 1
                                fi
			 sleep 2
				echo $id >> $LOG/.temp
                        rm -rvf $QC_FAIL/RawFiles/*
                         fi
		 elif [[ $TRACK -eq '1' ]] && [[ $TYPE == *Interlaced* ]] && [[ $VIDEO_TRACK_0 == *Video* ]] && [[ $CHANNEL_2 -eq '8' ]] && [[ ! -f $FINAL_PATH/$id ]]; then
                         echo 'content is: ' $id \n 'Its total track are: ' $TRACK \n 'Its SOM and bit rate is: ' $SOM $BIT_RATE | tee -a $LOG/${LOGNAME}.txt
                         sleep 1
                        echo 'Starting conversion process...'
                        rm -rf $QC_FAIL/RawFiles/*
                        mkdir -p $QC_FAIL/RawFiles

                        $FFMPEG -y -i $QC_FAIL/$id   -map 0:0 -top 1 -flags:v +ilme+ildct -vcodec mpeg2video -acodec pcm_s24le -b:v ${CONVERTED_BITRATE}k $QC_FAIL/RawFiles/abc.m2v -map_channel 0.1.0  -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc1.wav -map_channel 0.1.1 -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc2.wav -map_channel 0.1.2 -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc3.wav -map_channel 0.1.3 -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc4.wav -map_channel 0.1.4 -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc5.wav -map_channel 0.1.5 -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc6.wav -map_channel 0.1.6 -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc7.wav -map_channel 0.1.7  -b:a ${AUDIO_BIT_RATE}k $QC_FAIL/RawFiles/abc2.wav  ##2>> $LOG/${LOGNAME}.txt

                        if [[ $? -eq 0 ]]; then

                        $FFMPEG -y -i $QC_FAIL/RawFiles/abc.m2v -i $QC_FAIL/RawFiles/abc1.wav -i $QC_FAIL/RawFiles/abc2.wav -i $QC_FAIL/RawFiles/abc3.wav -i $QC_FAIL/RawFiles/abc4.wav -i $QC_FAIL/RawFiles/abc5.wav -i $QC_FAIL/RawFiles/abc6.wav -i $QC_FAIL/RawFiles/abc7.wav -i $QC_FAIL/RawFiles/abc8.wav   -vcodec mpeg2video -acodec pcm_s24le -b:v ${CONVERTED_BITRATE}k -bufsize ${CONVERTED_BITRATE}k -minrate ${CONVERTED_BITRATE}k -maxrate ${CONVERTED_BITRATE}k -b:a ${AUDIO_BIT_RATE}k -timecode $SOM -map 0:0  -map 1:0  -map 2:0  -map 3:0 -map 4:0 -map 5:0 -map 6:0 -map 7:0 -map 8:0 -s ${VIDEO_WIDTH}x${VIDEO_HEIGHT} -aspect $ASPECT  -top 1 -flags:v +ilme+ildct $FINAL_PATH/${CLIP_ID}_WR.${CLIP_EXT} ##2>> $LOG/${LOGNAME}.txt
                        if [[ $? -eq 0 ]]; then
                                echo 'FILE SUCCESSFULLY CONVERTED!' $id "at" $TIMESTAMP | tee -a $LOG/${LOGNAME}.txt
                                echo '========================================================' | tee -a $LOG/${LOGNAME}.txt
				exit 0
                                        else
                                        echo "PROCESS FAILED" $id "at" $TIMESTAMP | tee -a $LOG/${LOGNAME}.txt
                                        echo '========================================================' | tee -a $LOG/${LOGNAME}.txt
				exit 1
                                fi
                         sleep 2
                                echo $id >> $LOG/.temp
                        rm -rvf $QC_FAIL/RawFiles/*
                         fi

				fi


					else

                				echo -e 'NO ANY SEPCIFIED ERROR FOUND IN:' ${GREEN}$id${NC} 'CONTENT!!'
						exit 0

					fi


	else

		exit 2

	fi


