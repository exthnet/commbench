#!/bin/bash
export CUDA_VISIBLE_DEVICES=$(( ${OMPI_COMM_WORLD_LOCAL_RANK} * 2 ))
echo "CUDA_VISIBLE_DEVICES = ${CUDA_VISIBLE_DEVICES}"
numactl -l $1
