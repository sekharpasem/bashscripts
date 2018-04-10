#!/bin/bash
taskId=$1
default_job_name=$2
if [ "$taskId" == "" ]
	then
		default_job_name="ascension-ap-ml"
		printf "Job name [$default_job_name]: "
		read job_name

		printf "Task Id : "
		read taskId
fi
if [ "$job_name" == "" ]
	then
	job_name=$default_job_name
fi

echo "> Searching the logs with $job_name $taskId ...."
for i in {1..100};
	do 
		logs=$(cortex tasks logs --json $job_name $taskId); 
		echo "logs > $logs";
		logsArr=$(echo "$logs" | jq ".logs")
		#echo "logsArr > $logsArr"
		if [ "$logsArr" != "[]" ]
			then
				echo "Found logs, stopping..."; 
				break 
		else 
			echo "Logs are empty, trying $i time...";
		fi; 
		if [ "$i" == "10" ]
		then 
			echo "stopping...";
			echo "Exceeded number of calls ..."; 
			break 
		fi; 
		sleep 5; 
done