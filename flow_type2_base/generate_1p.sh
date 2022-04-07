#!/bin/bash -x

function rewrite2n () {
	for m in cpu mpi ca nccl
	do
		for k in reduce allreduce reducescatter allgather broadcast latency
		do
			sed -e "s/BIN/${m}_${k}/g" ./job_type2_2n1p_template.tmp.sh > ./job_type2_2n1p_${m}_${k}.sh
		done
	done
}

function rewrite4n () {
	for m in cpu mpi ca nccl
	do
		for k in reduce allreduce reducescatter allgather broadcast
		do
			sed -e "s/BIN/${m}_${k}/g" ./job_type2_4n1p_template.tmp.sh > ./job_type2_4n1p_${m}_${k}.sh
		done
	done
}

function generate2n () {
# 2 nodes
if [ ! -e ./job_type2_2n1p_template.sh ];then
	sed -e "s/MODULES/${modules}/" ../job_openmpi_base/job_type2_2n1p_template.sh > ./job_type2_2n1p_template.tmp.sh
	# call rewrite
	rewrite2n
else
	sed -e "s/MODULES/${modules}/" ./job_type2_2n1p_template.sh > ./job_type2_2n1p_template.tmp.sh
	# call rewrite
	rewrite2n
fi
}

function generate4n () {
# 4 nodes
if [ ! -e ./job_type2_4n1p_template.sh ];then
	sed -e "s/MODULES/${modules}/" ../job_openmpi_base/job_type2_4n1p_template.sh > ./job_type2_4n1p_template.tmp.sh
	# call rewrite
	rewrite4n
else
	sed -e "s/MODULES/${modules}/" ./job_type2_4n1p_template.sh > ./job_type2_4n1p_template.tmp.sh
	# call rewrite
	rewrite4n
fi
}

function etc () {
	# etc.
	/bin/cp ../job_openmpi_base/job_type2_1p_2.sh .
}

# main
if [ $# -eq 0 ]; then
	modules=""
	generate2n
	generate4n
	etc
elif [ $# -eq 1 ]; then
	# ./generate_1p.sh 2
	# ./generate_1p.sh 4
	# ./generate_1p.sh modulefile
	if [ $1 = "2" ]; then
		generate2n
		etc
	elif [ $1 = "4" ]; then
		generate4n
		etc
	else
		if [ -f $1 ]; then
			modules=`cat $1`
			echo $modules
			generate2n
			generate4n
			etc
		else
			echo "can't open $1"
		fi
	fi
elif [ $# -eq 2 ]; then
	# ./generate_1p.sh modulefile 2
	# ./generate_1p.sh modulefile 4
	if [ -f $1 ]; then
		modules=`cat $1`
		echo $modules
		if [ $2 = "2" ]; then
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
