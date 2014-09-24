#!/bin/bash

#Dimitris Misdanitis
#Dec 2013

#A bash script to raise notifications (notify-osd), about the proceses that consume too much cpu time
#This script has Urgency levels. The urgency level is calculated by the cpu usage of a process.
#Then, based on the urgency level,it sets the frequency of notifications.

#e.g Let's say we have a 4 cores cpu, that means my total power is 100%*4=400%.  The process Y cpu usage is 1.00 (100%), that means  25% of the machines CPU
#What is the check_limit: If a process reach the check limit, it worths to raise a notify. (I set the check_limit to 1/4 of the total CPU. in my case 4.0/4 =1.0 --->25%
#What is the urgency level? If the Y process uses 100% , then the urgency level is calculated: 25/check_limit (check limit=25)  so the urgency level is 25/25= 1 
#So you will get a notification every 900 seconds

#example 2: Let's say a process cpu usage is 300%.    75/25 =3.2 == 3     so theurgency level is 3 , you will get notifications every 2 minutes!

#level of spamming in seconds
notify_interval[1]=900 
notify_interval[2]=450
notify_interval[3]=120
notify_interval[4]=60


getLoad () {
	avg_load=( $(cat /proc/loadavg|cut -d' ' -f 1-3) )
}

cpus=$(grep 'model name' /proc/cpuinfo | wc -l)
max=$((100 * $cpus))
last_time_notified=0
last_notification_interval=0

#When we have 100% on one core then it will check check. 4 cores ---> 100/4 = 25 , 8 cores 100/8 ....
check_limit=$(printf "%.0f" $(echo 100/$cpus|bc))
#echo $check_limit

human_readable_load () {
#if for example the load is 1.00 on a 4core cpu then it will return 25   (when load is 4.00 then all cores are loaded to 100%)
	value=$1
	echo $(printf "%.0f" $(echo 100*$value/$cpus|bc))
}


notify () {
	time=$1
	interval=$2
	msg=$3
#	echo $msg
#	echo "interval:$interval,last_notification_interval:$last_notification_interval"
	#if the urgency level was raised, then last_time_notified=0 to notify asap
	if [ "$interval" -lt "$last_notification_interval" ]; then
		last_time_notified=0
	fi

	if [ "$interval" -gt "0" ]; then
		if [ "$(echo $time-$last_time_notified|bc)" -gt "$interval" ]; then
			notify-send --icon face-angry  "Warning" "$msg"
			last_time_notified=$time
			last_notification_interval=$interval
		fi
	fi
}

checkProcess () {
	output=$(ps -eo pid,pcpu,comm|sort -rn -k 2|head|awk '{sum[$3]+= $2;}END{for (app in sum){print sum[app],app;}}'|sort -rn -k1|head -n 1)
	procs=( $output )
	notify $(date +%s) ${notify_interval[$bother_level]}
}



while true
do
	getLoad
	value=$(human_readable_load ${avg_load[0]})
#	echo $value
	#Urgency level of notification    
	bother_level=$(printf "%.0f" $(echo $value / $check_limit|bc))
#echo "level:$bother_level"
	if [ "$value" -ge "$check_limit" ]; then
		output=$(ps -eo pid,pcpu,comm|sort -rn -k 2|awk '{sum[$3]+= $2;}END{for (app in sum){print sum[app],app;}}'|sort -rn -k1|head -n 1)
		procs=( $output )
		cpu=$(printf "%.0f" "${procs[0]}")
		if [ "$cpu" -ge "98" ] ;then 
			notify $(date +%s) ${notify_interval[$bother_level]} "\"${procs[1]}\" cpu usage is $cpu%"
		fi
		
	fi
	sleep 5
done
