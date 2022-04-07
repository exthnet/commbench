#!/bin/bash

function plot_init () {
	cat <<EOF > template.plt
#!gnuplot
set datafile separator ","
set key center top
set logscale y
set xtics rotate by 90
set xtics offset 0,-2.5
set bmargin 5
set xlabel "size"
set xlabel offset 0,-1.5
set ylabel "time [usec]"
set yrange[1:30000]
set label 1 at screen 0.20,0.80 "CAPTION"
set grid
set grid ytics mytics
plot   "FIN" using 2:xticlabels(1) with lp title "CPU OpenMPI"
replot "FIN" using 3:xticlabels(1) with lp title "cudaMemcpy+MPI"
replot "FIN" using 4:xticlabels(1) with lp title "CUDA-Aware MPI"
replot "FIN" using 5:xticlabels(1) with lp title "NCCL"
set terminal "png"
set out "FOUT"
replot
EOF
}

function analyze1n () {
	# 1 node
	cmd="paste -d ,"
	for k in reduce allreduce reducescatter
	do
		for m in cpu mpi ca nccl
		do
			echo "" > log_1n2p_${m}_${k}.txt.csv
			echo "" >> log_1n2p_${m}_${k}.txt.csv
			grep RESULT log_1n2p_${m}_${k}.txt | awk '{print $3}' >> log_1n2p_${m}_${k}.txt.csv
			cmd="${cmd} log_1n2p_${m}_${k}.txt.csv"
		done
	done
	for k in allgather broadcast latency
	do
		for m in cpu mpi ca nccl
		do
			grep RESULT log_1n2p_${m}_${k}.txt | awk '{print $3}' > log_1n2p_${m}_${k}.txt.csv
			cmd="${cmd} log_1n2p_${m}_${k}.txt.csv"
		done
	done
	echo ${cmd}
	${cmd} > log_1n2p_all.csv
	# plot
	echo -e "1\n2\n4\n8\n16\n32\n64\n128\n256\n512\n1K\n2K\n4K\n8K\n16K\n32K\n64K\n128K\n256K\n512K\n1M" > size.dat
	for k in reduce allreduce reducescatter allgather broadcast latency
	do
		cmd="paste -d , size.dat"
		for m in cpu mpi ca nccl
		do
			cmd="${cmd} log_1n2p_${m}_${k}.txt.csv"
		done
		$cmd > log_1n2p_${k}_plot.csv
		sed -i -e "s/,,/,0.0,0.0/g" log_1n2p_${k}_plot.csv
		sed -e "s/FIN/log_1n2p_${k}_plot.csv/" template.plt > template2.plt
		sed -e "s/FOUT/result_1n2p_${k}.png/" template2.plt > template3.plt
		sed -e "s/CAPTION/1n2p ${k}/" template3.plt > template4.plt
		gnuplot template4.plt
	done
	# combined
	cmd="convert -append "
	for k in reduce allreduce reducescatter allgather broadcast
	do
		cmd="${cmd} result_1n2p_${k}.png"
	done
	$cmd result_1n2p_all.png
	cmd="${cmd} result_1n2p_latency.png"
	$cmd result_1n2p_all2.png
	/bin/cp result_1n2p_latency.png result_latency_1n2p.png
}

function analyze2n () {
	# 2 nodes
	cmd="paste -d ,"
	for k in reduce allreduce reducescatter
	do
		for m in cpu mpi ca nccl
		do
			echo "" > log_2n2p_${m}_${k}.txt.csv
			echo "" >> log_2n2p_${m}_${k}.txt.csv
			grep RESULT log_2n2p_${m}_${k}.txt | awk '{print $3}' >> log_2n2p_${m}_${k}.txt.csv
			cmd="${cmd} log_2n2p_${m}_${k}.txt.csv"
		done
	done
	for k in allgather broadcast
	do
		for m in cpu mpi ca nccl
		do
			grep RESULT log_2n2p_${m}_${k}.txt | awk '{print $3}' > log_2n2p_${m}_${k}.txt.csv
			cmd="${cmd} log_2n2p_${m}_${k}.txt.csv"
		done
	done
	echo ${cmd}
	${cmd} > log_2n2p_all.csv
	# plot
	echo -e "1\n2\n4\n8\n16\n32\n64\n128\n256\n512\n1K\n2K\n4K\n8K\n16K\n32K\n64K\n128K\n256K\n512K\n1M" > size.dat
	for k in reduce allreduce reducescatter allgather broadcast
	do
		cmd="paste -d , size.dat"
		for m in cpu mpi ca nccl
		do
			cmd="${cmd} log_2n2p_${m}_${k}.txt.csv"
		done
		$cmd > log_2n2p_${k}_plot.csv
		sed -i -e "s/,,/,0.0,0.0/g" log_2n2p_${k}_plot.csv
		sed -e "s/FIN/log_2n2p_${k}_plot.csv/" template.plt > template2.plt
		sed -e "s/FOUT/result_2n2p_${k}.png/" template2.plt > template3.plt
		sed -e "s/CAPTION/2n2p ${k}/" template3.plt > template4.plt
		gnuplot template4.plt
	done
	# combined
	cmd="convert -append "
	for k in reduce allreduce reducescatter allgather broadcast
	do
		cmd="${cmd} result_2n2p_${k}.png"
	done
	$cmd result_2n2p_all.png
}

function analyze4n () {
	# 4 nodes
	cmd="paste -d ,"
	for k in reduce allreduce reducescatter
	do
		for m in cpu mpi ca nccl
		do
			echo "" > log_4n2p_${m}_${k}.txt.csv
			echo "" >> log_4n2p_${m}_${k}.txt.csv
			grep RESULT log_4n2p_${m}_${k}.txt | awk '{print $3}' >> log_4n2p_${m}_${k}.txt.csv
			cmd="${cmd} log_4n2p_${m}_${k}.txt.csv"
		done
	done
	for k in allgather broadcast
	do
		for m in cpu mpi ca nccl
		do
			grep RESULT log_4n2p_${m}_${k}.txt | awk '{print $3}' > log_4n2p_${m}_${k}.txt.csv
			cmd="${cmd} log_4n2p_${m}_${k}.txt.csv"
		done
	done
	echo ${cmd}
	${cmd} > log_4n2p_all.csv
	# plot
	echo -e "1\n2\n4\n8\n16\n32\n64\n128\n256\n512\n1K\n2K\n4K\n8K\n16K\n32K\n64K\n128K\n256K\n512K\n1M" > size.dat
	for k in reduce allreduce reducescatter allgather broadcast
	do
		cmd="paste -d , size.dat"
		for m in cpu mpi ca nccl
		do
			cmd="${cmd} log_4n2p_${m}_${k}.txt.csv"
		done
		$cmd > log_4n2p_${k}_plot.csv
		sed -i -e "s/,,/,0.0,0.0/g" log_4n2p_${k}_plot.csv
		sed -e "s/FIN/log_4n2p_${k}_plot.csv/" template.plt > template2.plt
		sed -e "s/FOUT/result_4n2p_${k}.png/" template2.plt > template3.plt
		sed -e "s/CAPTION/4n2p ${k}/" template3.plt > template4.plt
		gnuplot template4.plt
	done
	# combined
	cmd="convert -append "
	for k in reduce allreduce reducescatter allgather broadcast
	do
		cmd="${cmd} result_4n2p_${k}.png"
	done
	$cmd result_4n2p_all.png
}

# main
plot_init
if [ $# -eq 0 ]; then
	analyze1n
	analyze2n
	analyze4n
else
	echo "arg = $1"
	if [ $1 = "1" ]; then
		analyze1n
	fi
	if [ $1 = "2" ]; then
		analyze2n
	fi
	if [ $1 = "4" ]; then
		analyze4n
	fi
fi
