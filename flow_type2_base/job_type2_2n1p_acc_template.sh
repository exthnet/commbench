#!/bin/bash -x
#PJM -L rscgrp=cx-small
#PJM -L node=2
#PJM -L elapse=10:00
#PJM -j
#PJM -S

eval `cat env.sh`

OPTS="-report-bindings -display-devel-map"
#OPTS="-report-bindings"
#OPTS="-report-bindings -mca coll_hcoll_enable 1 -mca pml ucx -mca osc ucx -x HCOLL_CUDA_SBGP=p2p -x HCOLL_CUDA_BCOL=ucx_p2p"
#OPTS="-report-bindings -mca pml ucx --mca btl ^vader,tcp,openib,uct"
#OPTS="${OPTS} -report-bindings -mca coll_hcoll_enable 1 -mca pml ucx -mca osc ucx -x HCOLL_CUDA_SBGP=p2p -x HCOLL_CUDA_BCOL=nccl -x HCOLL_CUDA_STAGING_MAX_THRESHOLD=262144 -x UCX_TLS=rc_x,cuda_copy,gdr_copy"
#mpirun {$OPTS} -n 2 -machinefile $PJM_O_NODEINF -map-by ppr:1:node -bind-to socket ./job_type2_1p_2.sh ./BIN 2>&1|tee log_2n1p_BIN.txt
mpirun -output-filename out_2n1p_BIN_${PJM_JOBID} ${OPTS} -n 2 -machinefile $PJM_O_NODEINF -map-by ppr:1:node -bind-to socket ./job_type2_1p_2.sh ./BIN > log_2n1p_BIN.txt
