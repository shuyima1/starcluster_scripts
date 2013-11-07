#!/bin/bash

NTHREADS=1
GENOME_FILE="/home/GRCh37/fasta/Homo_sapiens.GRCh37.68.genome.fa"
PREFIX="Aligned.out"
RNA_PATH="/RNAresultsGSE34914/results"
TEXT_INPUT="samples.txt"
QUEUE="all.q"
MEM="1G"
SAMTOOLSBAM="/home/scripts/samtoolsbamconvert.sh"

while getopts "m:n:g:r:t:p:" ARG; do
	case "$ARG" in
		m ) MEM=$OPTARG;;
		n ) NTHREADS=$OPTARG;;
		g ) GENOME_FILE=$OPTARG;;
		r ) RNA_PATH=$OPTARG;;
		t ) TEXT_INPUT=$OPTARG;;
		p ) PREFIX=$OPTARG;;
	esac
done
#shift $(($OPTIND - 1))

while read line
do
	$SAMTOOLSBAM -n $NTHREADS -g $GENOME_FILE -r $RNA_PATH -s "$line" -p $PREFIX
done < ${TEXT_INPUT}

