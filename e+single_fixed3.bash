#!/bin/bash

### updated to use new dctimestep April 29, 2013
### updated to use Year 2009 for Title 24 TDV calculation on August 1, 2013


p01=$1
# window name

p02=$2
# Chicago Houston Burbank Oakland

p06=$3
#wwr60 wwr45 wwr30 wwr15

p07=$4
# NDC DC




smname=${p01}_${p02}_${p06}_${p07}

#### Generate Lighting Power Schedule ###############################################



for ori in N S E W ; do

if [ ! -e ./lightscheds/${smname}_${ori}.elc -a ! "${p07}" == 'NDC' ] ; then 

	for zone in 1 2 3 4; do

		dctimestep -n 8760 \
			./models/${p06}/${p06}_zone${zone}_GlDay.vmx \
			./bsdf/${p01}_vis.xml  \
			./models/${p06}/${p06}_GlDay_${ori}.dmx \
			./skyvecs/${p02}.skm | \
			rgb2lum > tmp/tmp_${smname}_zone${zone}_glDay.ill
		./transpose.py tmp/tmp_${smname}_zone${zone}_glDay.ill > tmp/tmp_${smname}_zone${zone}_glDay_t.ill

		dctimestep -n 8760 \
			./models/${p06}/${p06}_zone${zone}_GlView.vmx \
			./bsdf/${p01}_vis.xml  \
			./models/${p06}/${p06}_GlView_${ori}.dmx \
			./skyvecs/${p02}.skm |\
			rgb2lum > tmp/tmp_${smname}_zone${zone}_glView.ill
		./transpose.py tmp/tmp_${smname}_zone${zone}_glView.ill > tmp/tmp_${smname}_zone${zone}_glView_t.ill
			
		rlam tmp/tmp_${smname}_zone${zone}_glDay_t.ill tmp/tmp_${smname}_zone${zone}_glView_t.ill | \
			awk '{min=5000; cum=0 ; j=NF/2+1; \
				for(i=1;i<=NF/2;i++){ cum+= $i+$(i+j); \
				    if($i+$(j+i)<min) min=$i+$(i+j) }; \
				printf("%02f\n",cum/NF*2)}' > tmp/tmp_${smname}_zone${zone}.ill

		rlam tmp/tmp_${smname}_zone${zone}_glDay_t.ill tmp/tmp_${smname}_zone${zone}_glView_t.ill | \
                awk '{cum=0; \
                        for(i=1;i<=NF;i++){ cum+=$i }; \
                        print cum/NF*2}' > tmp/tmp_${smname}_zone${zone}.avg

	done
	
	
	
	rlam tmp/tmp_${smname}_zone1.avg tmp/tmp_${smname}_zone2.avg tmp/tmp_${smname}_zone3.avg tmp/tmp_${smname}_zone4.avg | \
		awk 'BEGIN{setp=500} \
			{$1>setp ? z1=0.03 : $1>setp*.9 ? z1=0.20 : z1=(setp-$1)/setp*0.8889+.1111;\
			 $2>setp ? z2=0.03 : $2>setp*.9 ? z2=0.20 : z2=(setp-$2)/setp*0.8889+.1111;\
			 $3>setp ? z3=0.03 : $3>setp*.9 ? z3=0.20 : z3=(setp-$3)/setp*0.8889+.1111;\
			 $4>setp ? z4=0.03 : $4>setp*.9 ? z4=0.20 : z4=(setp-$4)/setp*0.8889+.1111;\
			 light_p=(z1+z2/2)/1.5;\
			 light_c=(z2/2+z3+z4)/2.5; \
			 jd=int(NR/24);\
			  	hour=(NR+1)%24; \
			 	day=int(NR/24)%7; \
			 if(day==3 || jd==0 || jd==18 || jd==46 || jd==144 || jd==182 || jd==242 || \
			 	jd==284 || jd==312 || jd==329 || jd==356 ){occ=0.05} \
			 else if(day==2){ hour<6 ? occ=0.05 : hour<8 ? occ=0.1 : hour<12 ? occ=0.3 : \
			 				 hour<17 ? occ=0.15 : hour<24 ? occ=0.05 : occ=0.05 } \
			 else { hour<5 ? occ=0.05 : hour<7 ? occ=0.1 : hour<8 ? occ=0.3 : \
			 				hour<17 ? occ=0.9 : hour<18 ? occ=0.5 : hour<22 ? occ=0.2 : hour<23 ? 0.1 : \
			 				hour<24 ? occ=0.05 : occ=0.05 } \
			printf("%f,\t%f\n",light_p*occ,light_c*occ) }' > ./lightscheds/${smname}_${ori}.elc

	rm tmp/tmp_${smname}_zone*.ill

	fi


	if [ "${p07}" == 'NDC' -a ! -e ./lightscheds/NDC_${ori}.elc ]
	then
	cnt 8760 | awk '{jd=int(NR/24);\
			  	hour=(NR+1)%24; \
			 	day=int(NR/24)%7; \
			 	}\
			 if(day==3 || jd==0 || jd==18 || jd==46 || jd==144 || jd==182 || jd==242 || \
			 	jd==284 || jd==312 || jd==329 || jd==356 ){occ=0.05} \
			 else if(day==2){ hour<6 ? occ=0.05 : hour<8 ? occ=0.1 : hour<12 ? occ=0.3 : \
			 				 hour<17 ? occ=0.15 : hour<24 ? occ=0.05 : occ=0.05 } \
			 else { hour<5 ? occ=0.05 : hour<7 ? occ=0.1 : hour<8 ? occ=0.3 : \
			 				hour<17 ? occ=0.9 : hour<18 ? occ=0.5 : hour<22 ? occ=0.2 : hour<23 ? 0.1 : \
			 				hour<24 ? occ=0.05 : occ=0.05 } \
			printf("%f,\t%f\n",occ,occ) }' > ./lightscheds/NDC_${ori}.elc
	fi

#### Generate Surface Irradiance Schedule #############################################
#	WWR		15		30		45		60
#	View	42 ft2	66 ft2	102 ft2	159.6 ft2
#	Day		14 ft2	55 ft2	85 ft2	95 ft2
#
#	View	3.90 m2	6.13 m2	9.48 m2	14.83 m2
#	Day		1.30 m2	5.11 m2	7.90 m2	8.83 m2

if [ $p06 == 'wwr15' ] ; then
	area_view=3.90
	area_day=1.30
elif [ $p06 == 'wwr30' ] ; then
	area_view=6.13
	area_day=5.11
elif [ $p06 == 'wwr45' ] ; then
	area_view=9.48
	area_day=7.90
elif [ $p06 == 'wwr60' ] ; then
	area_view=14.83
	area_day=8.83
fi



if [ ! -e ./intSurfSched/${smname}_${ori}.irrad -a ! "${p06}" == 'wwr00' ] ; then 
	
	dctimestep -n 8760 \
		./models/${p06}/${p06}_GlDay_irrad.vmx \
		./bsdf/${p01}_ir.xml  \
		./models/${p06}/${p06}_GlDay_${ori}.dmx \
		./skyvecs/${p02}_irrad.skm | \
		rgb2lum -m $area_day > tmp/tmp_${smname}_glDay.irrad 
	./transpose.py tmp/tmp_${smname}_glDay.irrad  > tmp/tmp_${smname}_glDay_t.irrad 
		
	dctimestep -n 8760 \
		./models/${p06}/${p06}_GlView_irrad.vmx \
		./bsdf/${p01}_ir.xml  \
		./models/${p06}/${p06}_GlView_${ori}.dmx \
		.//skyvecs/${p02}_irrad.skm | \
		rgb2lum -m $area_view > tmp/tmp_${smname}_glView.irrad
	./transpose.py tmp/tmp_${smname}_glView.irrad  > tmp/tmp_${smname}_glView_t.irrad

	rlam tmp/tmp_${smname}_glView_t.irrad tmp/tmp_${smname}_glDay_t.irrad | \
		awk 'BEGIN{area_view='${area_view}'; area_day='${area_day}'}\
		{ f1=($1+$13)/(4.572*12.192); f2=($7+$19)/(10.0584*12.192);\
		  c1=($2+$14)/(4.572*12.192);	c2=($8+$20)/(10.0584*12.192);\
		  wa1=($3+$15)/(4.572*2.7432);	wa2=($9+$21)/(10.0584*2.7432);\
		  wb1=($4+$16)/(2.7432*12.192);	wb2=($10+$22)/(2.7432*12.192);\
		  wc1=($5+$17)/(4.572*2.7432);	wc2=($11+$23)/(10.0584*2.7432);\
		  fur1=($6+$18)/(4.572*12.192);	fur2=($12+$24)/(10.0584*12.192);\
		printf("%f,\t%f,\t%f,\t%f,\t%f,\t%f,\t%f,\t%f,\t%f,\t%f,\t%f,\t%f,\t%f,\t%f\n",f1+fur1,c1,wa1,wb1,wc1,0,f2+fur2,c2,wa2,wb2,wc2,0,0,0)}' \
               > ./intSurfSched/${smname}_${ori}.irrad

       rm tmp/tmp_${smname}_*.irrad


elif [ ! -e ./intSurfSched/${smname}_${ori}.irrad -a "${p06}" == 'wwr00' ] ; then
	cnt 8760 | awk '{printf("0,\t0,\t0,\t0,\t0,\t0,\t0,\t0,\t0,\t0,\t0,\t0,\t0,\t0\n")}' \
               > ./intSurfSched/wwr00_${ori}.irrad


fi

####Generate window layer absorptance  ########################################################


if [ ! -e ./winabs/${smname}_${ori}.irrad -a ! "${p06}" == 'wwr00' ] ; then
	dctimestep -n 8760 \
	     ./absmatrix/${p01}.vmx \
	     ./bsdf/void.xml \
		 ./models/${p06}/${p06}_GlDay_${ori}.dmx \
		 ./skyvecs/${p02}_irrad.skm | \
		 rgb2lum -m 1 > tmp/winabs_${smname}_${ori}.irrad
		 
	./transpose.py tmp/winabs_${smname}_${ori}.irrad | awk '{printf("%f,\t%f,\t%f,\t%f,\t%f,\n",$1,$2,$3,$4,$5)}' \
		 > ./winabs/${smname}_${ori}.irrad
	
	rm tmp/winabs_${smname}_${ori}.irrad

elif [ ! -e ./intSurfSched/${smname}_${ori}.irrad -a "${p06}" == 'wwr00' ] ; then
        cnt 8760 | awk '{printf("0,\t0,\t0,\t0,\t0,\n")}' \
                > ./winabs/wwr00_${ori}.irrad

fi

done


