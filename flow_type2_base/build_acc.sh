#!/bin/bash

OUTDIR=`pwd`
cd ../src
make OUTDIR=${OUTDIR} acc
