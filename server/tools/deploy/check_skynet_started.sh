# bin/bash

node_name=$1

while [ -f "status/"$1".starting" ]
do
    echo $1" starting"
    sleep 1
done
