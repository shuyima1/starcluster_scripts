#!/bin/bash

NTHREADS=1
GENOME_FILE="/home/GRCh37/gtf/Homo_sapiens.GRCh37.68.gtf"
PREFIX="Aligned.out"
RNA_PATH="/RNAresultsGSE34914/results"
TEXT_INPUT="samples.txt"
QUEUE="all.q"
MEM="1G"
HTSEQ_COUNT="/home/scripts/htseq-rna-submit.sh"

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
	$HTSEQ_COUNT -g $GENOME_FILE -r $RNA_PATH -x "$line" -p $PREFIX
done < ${TEXT_INPUT}

