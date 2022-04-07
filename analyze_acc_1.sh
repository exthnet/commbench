#!/bin/bash
for d in dir1 dir2
do
	if [ ! -d ${d} ]; then mkdir ${d}; fi
	for x in 1 2 4
	do
		cd ${d}_${x}p
		../flow_type2_base/analyze_acc_${x}p.sh
		/bin/cp result_1n${x}p_all.png ../${d}
		/bin/cp result_2n${x}p_all.png ../${d}
		/bin/cp result_4n${x}p_all.png ../${d}
		/bin/cp result_latency_1n2p.png ../${d}
		/bin/cp result_latency_2n1p.png ../${d}
		cd ..
	done
done
