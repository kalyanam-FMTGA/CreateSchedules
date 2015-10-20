#!/bin/bash

if [ $# -eq 3 ]; then
	
	cd batch
        ./climate.sh $1 $2 $3 &
else
    echo "Your command line doesn't have enough arguments"
fi


