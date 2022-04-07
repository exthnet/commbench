#!/bin/bash -x

function rewrite1n () {
	for m in accA accB accC
	do
		for k in reduce allreduce reducescatter allgather broadcast
		do
			sed -e "s/BIN/${m}_${k}/g" ./job_type2_1n4p_template.tmp.sh > ./job_type2_1n4p_${m}_${k}.sh
		done
	done
}

function rewrite2n () {
	for m in accA accB accC
	do
		for k in reduce allreduce reducescatter allgather broadcast
		do
			sed -e "s/BIN/${m}_${k}/g" ./job_type2_2n4p_template.tmp.sh > ./job_type2_2n4p_${m}_${k}.sh
		done
	done
}

function rewrite4n () {
	for m in accA accB accC
	do
		for k in reduce allreduce reducescatter allgather broadcast
		do
			sed -e "s/BIN/${m}_${k}/g" ./job_type2_4n4p_template.tmp.sh > ./job_type2_4n4p_${m}_${k}.sh
		done
	done
}

function generate1n () {
# 1 node
if [ ! -e ./job_type2_1n4p_template.sh ];then
	sed -e "s/MODULES/${modules}/" ../job_openmpi_base/job_type2_1n4p_template.sh > ./job_type2_1n4p_template.tmp.sh
	# call rewrite
	rewrite1n
else
	sed -e "s/MODULES/${modules}/" ./job_type2_1n4p_template.sh > ./job_type2_1n4p_template.tmp.sh
	# call rewrite
	rewrite1n
fi
}

function generate2n () {
# 2 nodes
if [ ! -e ./job_type2_2n4p_template.sh ];then
	sed -e "s/MODULES/${modules}/" ../job_openmpi_base/job_type2_2n4p_template.sh > ./job_type2_2n4p_template.tmp.sh
	# call rewrite
	rewrite2n
else
	sed -e "s/MODULES/${modules}/" ./job_type2_2n4p_template.sh > ./job_type2_2n4p_template.tmp.sh
	# call rewrite
	rewrite2n
fi
}

function generate4n () {
# 4 nodes
if [ ! -e ./job_type2_4n4p_template.sh ];then
	sed -e "s/MODULES/${modules}/" ../job_openmpi_base/job_type2_4n4p_template.sh > ./job_type2_4n4p_template.tmp.sh
	# call rewrite
	rewrite4n
else
	sed -e "s/MODULES/${modules}/" ./job_type2_4n4p_template.sh > ./job_type2_4n4p_template.tmp.sh
	# call rewrite
	rewrite4n
fi
}

function etc () {
	# etc.
	/bin/cp ../job_openmpi_base/job_type2_4p_2.sh .
}

# main
if [ $# -eq 0 ]; then
	modules=""
	generate1n
	generate2n
	generate4n
	etc
elif [ $# -eq 1 ]; then
	# ./generate_4p.sh 1
	# ./generate_4p.sh 2
	# ./generate_4p.sh 4
	# ./generate_4p.sh modulefile
	if [ $1 = "1" ]; then
		generate1n
		etc
	elif [ $1 = "2" ]; then
		generate2n
		etc
	elif [ $1 = "4" ]; then
		generate4n
		etc
	else
		if [ -f $1 ]; then
			modules=`cat $1`
			echo $modules
			generate1n
			generate2n
			generate4n
			etc
		else
			echo "can't open $1"
		fi
	fi
elif [ $# -eq 2 ]; then
	# ./generate_4p.sh modulefile 1
	# ./generate_4p.sh modulefile 2
	# ./generate_4p.sh modulefile 4
	if [ -f $1 ]; then
		modules=`cat $1`
		echo $modules
		if [ $2 = "1" ]; then
			generate1n
			etc
		elif [ $2 = "2" ]; then
			generate2n
			etc
		elif [ $2 = "4" ]; then
			generate4n
			etc
		fi
	else
		echo "can't open $1"
	fi
fi
