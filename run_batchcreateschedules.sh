#!/bin/bash

if [ $# -eq 3 ]; then
	
	cd batch
        ./climate.sh $1 $2 $3 &
# Here the cimate means the place name and the parameters 1 represents the climate, 2 represents no. of the layers and 3 represents the positon of the shading layer. Please refer to the manual.
else
    echo "Your command line doesn't have enough arguments"
fi


