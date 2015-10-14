#!/bin/bash


for climate in Burbank Chicago Houston Oakland; do

clim=$climate
	
for ww in wwr15 wwr30 wwr45 wwr60 ;  do

wwr=$ww

for control in DC NDC; do
DLC=$control

for shd in  E N S W; do

shade=$shd

run=${clim}_${wwr}_${DLC}_${shade}

cd ./winabs

cp E1-geo8-45deg_$run.irrad E1-geo8_$run.irrad
cp E2-geo8-45deg_$run.irrad E2-geo8_$run.irrad

cd ../intSurfSched

cp E1-geo8-45deg_$run.irrad E1-geo8_$run.irrad
cp E2-geo8-45deg_$run.irrad E2-geo8_$run.irrad

cd ../lightscheds

cp E1-geo8-45deg_$run.elc E1-geo8_$run.elc
cp E2-geo8-45deg_$run.elc E2-geo8_$run.elc

cd ..


done
done
done
done

	


