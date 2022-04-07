#!/bin/bash -x

function exec1n () {
# 1 node
for k in reduce allreduce reducescatter allgather broadcast latency
do
	cmd="pjsub --step"
	for m in cpu mpi ca nccl
	do
		cmd="${cmd} ./job_type2_1n2p_${m}_${k}.sh"
	done
	${cmd}
done
}

function exec2n () {
# 2 nodes
for k in reduce allreduce reducescatter allgather broadcast
do
	cmd="pjsub --step"
	for m in cpu mpi ca nccl
	do
		cmd="${cmd} ./job_type2_2n2p_${m}_${k}.sh"
	done
	${cmd}
done
}

function exec4n () {
# 4 nodes
for k in reduce allreduce reducescatter allgather broadcast
do
	cmd="pjsub --step"
	for m in cpu mpi ca nccl
	do
		cmd="${cmd} ./job_type2_4n2p_${m}_${k}.sh"
	done
	${cmd}
done
}

# main
if [ $# -eq 0 ]; then
	exec1n
	exec2n
	exec4n
else
	echo "arg = $1"
	if [ $1 = "1" ]; then
		exec1n
	fi
	if [ $1 = "2" ]; then
		exec2n
	fi
	if [ $1 = "4" ]; then
		exec4n
	fi
fi
