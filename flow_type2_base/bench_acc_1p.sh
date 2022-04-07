#!/bin/bash -x

function exec2n () {
# 2 nodes
cmd="pjsub --step"
for k in reduce allreduce reducescatter allgather broadcast latency
do
	for m in accA accB accC
	do
		cmd="${cmd} ./job_type2_2n1p_${m}_${k}.sh"
	done
done
${cmd}
}

function exec4n () {
# 4 nodes
cmd="pjsub --step"
for k in reduce allreduce reducescatter allgather broadcast
do
	for m in accA accB accC
	do
		cmd="${cmd} ./job_type2_4n1p_${m}_${k}.sh"
	done
done
${cmd}
}

# main
if [ $# -eq 0 ]; then
	exec2n
	exec4n
else
	echo "arg = $1"
	if [ $1 = "2" ]; then
		exec2n
	fi
	if [ $1 = "4" ]; then
		exec4n
	fi
fi
