#!/usr/bin/env bash

# Creates the deployable Lambda zip

set -e
echo "Checking Aws installed or not...."
if ! type aws > /dev/null; then
  echo "Aws does not exists...."
  echo "Installing...."
  pip3 install awscli
  aws configure set aws_access_key_id $ACCESS_KEY
  aws configure set aws_secret_access_key $SECRET_KEY
  aws configure set region_name us-east-1
else 
  echo "Aws already installed..."
fi 

script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# cd "$script_dir/.."
cd ..
echo "> Removing target folder..."
rm -rf target
echo "> Creating target folder..."
mkdir -p target

declare -a arr=("get-offers" "clickstream" "offer-accepted")
# prod env means just empty string
# ENV=""
ENV="-stage"
TARGET_DIR=target
## now loop through the above array
for i in "${arr[@]}"
do
   echo "> $i"
   dir_path=$TARGET_DIR"/$i"
   # or do whatever with individual element of the array
	mkdir -p $dir_path
	#git clone https://github.com/pbegle/aws-lambda-py3.6-pandas-numpy.git ./$dir_path
	unzip $script_dir/lambda.zip -d ./$dir_path
	echo "> Creating folder - $i"
	cp -r skills/$i/src/lambda_function.py skills/$i/src/setup.cfg skills/$i/src/requirements_lambda.txt offers ./$dir_path

	pushd $dir_path
	pip3 install -r requirements_lambda.txt -t ./
    find ./ -name "*.pyc" -type f -delete
    find ./ -name "*.log" -type f -delete
	# npm install --production
	zip -ru $i-lambda.zip ./
	popd
done
echo "> Done zipping lambda functions..."
echo "> Starting to upload..."
for i in "${arr[@]}"
do
   echo "> Looking for $i"
   function_name="$i$ENV"
   if [ "$i" == "offer-accepted" ]; then
        function_name="offers-accepted$ENV"
   fi
   dir_path=$TARGET_DIR"/$i"
   file_path=$dir_path/$i"-lambda.zip"
   echo "> $file_path"
	if [ -e "$file_path" ]; then
		aws lambda update-function-code --function-name $function_name --zip-file fileb://$file_path --region us-east-1
	    echo "> File exists"
	    echo "> $file_path - Upload Done"
	else 
	    echo "> File does not exist"
	fi 
done


