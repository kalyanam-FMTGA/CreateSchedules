#!/bin/bash

cd /scratch/UG/FMTGA/extshd/CreateSchedules
cp ./CurrentlyUnusedInputs/E1-geo1* ./
cd ./absmatrix
rm E1-geo1* 
cd ../bsdf
rm E1-geo1* 
cd ../winabs
rm E1-geo1* 
cd ../intSurfSched
rm E1-geo1* 
cd ../lightscheds
rm E1-geo1* 
cd ..
./run_batchcreateschedules311.sh
