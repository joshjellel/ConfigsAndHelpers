#! /usr/bin/bash
#Wrapper script for Pulse Audio
#Increase/Decrease Volume
#Toggle Mute
#Read Current Volume Level

#Global Variables
CURR_VOL=
MUTE_STATUS=
SINK=

#Helper to get sink number
get_active_sink_number(){
	SINK=`pacmd list-sinks | grep -n '*' | awk 'BEGIN {FS=":"} {print $3}' | sed 's/ //'`
}

#Helper to get status of mute
get_mute_status(){
	TEMP_LINE=`pacmd list-sinks | grep -n "index: $SINK" | awk 'BEGIN {FS=":"} {print $1}'`
	TEMP_LINE=`expr $TEMP_LINE + 11`
	MUTE_STATUS=`pacmd list-sinks | head -n $TEMP_LINE | tail -1 | awk 'BEGIN {FS=" "} {print $2}'`
	if [ $MUTE_STATUS == "yes" ]
	then
		MUTE_STATUS="M"
	fi
}

#VOL
get_volume_level(){
	get_mute_status
	if [ $MUTE_STATUS == "M" ]
	then
		CURR_VOL="M"
		echo $CURR_VOL
		return
	fi
	TEMP_LINE=`pacmd list-sinks | grep -n "index: $SINK" | awk 'BEGIN {FS=":"} {print $1}'`
	TEMP_LINE=`expr $TEMP_LINE + 7`
	CURR_VOL=`pacmd list-sinks | head -n $TEMP_LINE | tail -1 | awk 'BEGIN {FS=" "} {print $5}'`
	echo $CURR_VOL
}

#CARD NAME
get_card_name(){
	TEMP_LINE=`pacmd list-sinks | grep -n '*' | awk 'BEGIN {FS=":"} {print $1}'`
	TEMP_LINE=`expr $TEMP_LINE + 36`
	CARD_NAME=`pacmd list-sinks | head -n $TEMP_LINE | tail -1 | awk 'BEGIN {FS="="} {print $2}' | sed 's/"//g'`
	echo $CARD_NAME
}

#INC
increase_volume(){
	get_volume_level
	VOL_NUM=`echo $CURR_VOL | sed 's/%//'`
	NEW_VOL=`expr $VOL_NUM + $1`
	if [ $NEW_VOL -gt 100 ]
	then
		NEW_VOL=100
	fi
	pactl set-sink-mute $SINK false ; pactl -- set-sink-volume $SINK $NEW_VOL%
	echo $NEW_VOL
}	

#DEC
decrease_volume(){
	get_volume_level
	VOL_NUM=`echo $CURR_VOL | sed 's/%//'`
	NEW_VOL=`expr $VOL_NUM - $1`
	if [ $NEW_VOL -gt 100 ]
	then
		NEW_VOL=100
	fi
	pactl set-sink-mute $SINK false ; pactl -- set-sink-volume $SINK $NEW_VOL%
	echo $NEW_VOL
}	

#TOGGLE
toggle_volume_mute(){
	pactl set-sink-mute $SINK toggle
	get_mute_status
	if [ $MUTE_STATUS == "M" ]
	then
		echo $MUTE_STATUS
	else
		get_volume_level
	fi
}

if [ ! -n "$1" ]
then
	echo "Usage: `basename $0` VOL|INC|DEC|MUTE_TOG [INCR %AGE|DEC %AGE]"
	exit 1
fi  
get_active_sink_number
case $1 in
	VOL) get_volume_level ;;
	INC) increase_volume $2;;
	DEC) decrease_volume $2;;
	MUTE_TOG) toggle_volume_mute;;
	CARD) get_card_name;;
esac
exit 0
