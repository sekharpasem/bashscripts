#!/bin/bash
default_job_name="ascension-ap-ml"
printf "Job name [$default_job_name]: "
read job_name
if [ "$job_name" == "" ]
	then
	job_name=$default_job_name
fi
tasks_list=$(cortex tasks list --json $job_name); 
#echo $tasks_list
tasksArr=$(echo "$tasks_list" | jq ".tasks")
tasksArrInternal=()

tasksArrLength=$(echo "$tasksArr" | jq '. | length')
for (( i=0; i<${tasksArrLength}; i++ ));
do
logsArrStr=$(echo "$tasksArr" | jq -r ".[$i]")
tasksArrInternal[$i]=$logsArrStr
done


printf "\n Recent task ids, last one will be latest	\n"
for (( i=0; i<${#tasksArrInternal[@]}; i++ ));
do
	no=`expr $i + 1`
echo $no". ${tasksArrInternal[$i]}"
done

printf "Please select task number: "
read taskNo

selected_task_index=`expr $taskNo - 1`

./get_task_logs.sh ${tasksArrInternal[$selected_task_index]} $job_name

