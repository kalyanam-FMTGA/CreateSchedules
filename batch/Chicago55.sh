#!/bin/bash 

cd ..

for filename in `ls *_0_AngularData.csv` ; do
cp $filename ./absmatrix
done



for filename in `ls *.csv` ; do

			ftest=`echo ${filename##*_}` # part of filename after last '_'
			if [ ! $ftest == AngularData.csv ] ; then
				mv $filename ./bsdf
			fi
done

		

for filename in `ls *.xml` ; do
mv $filename ./bsdf
done

cd bsdf
./mk_xml.bsh
cd ../absmatrix

for filename in `ls *_0_AngularData.csv` ; do

#!!!!!!  This line has to be changed for different systems !!!!!
./make_absorb_VMX.bsh 5 $filename 5 > ${filename%%_0_AngularData.csv}.vmx

done

cd ../



#######################


for filename in `ls *_0_AngularData.csv` ; do
window=${filename%%_0_AngularData.csv}

for clim in Chicago ; do
climate=$clim

for ww in wwr15 wwr30 wwr45 wwr60 ;  do
wwr=$ww

for control in DC ; do
DLC=$control


./e+single_fixed3.bash $window $climate $wwr $DLC

done
done
done
done

