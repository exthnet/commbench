#!/bin/bash
for d in dir1 dir2
do
	cd $d
	convert +append \
			result_1n2p_all.png result_1n4p_all.png \
			result_2n1p_all.png result_2n2p_all.png result_2n4p_all.png \
			result_4n1p_all.png result_4n2p_all.png result_4n4p_all.png \
			result_all_all.png
	cd ../
done
