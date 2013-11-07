#!/bin/bash
MEM="64G"
GENOME_PATH="/STARgenomeIndex/GENjob4"
GTF="/home/GRCh37/gtf/Homo_sapiens.GRCh37.68.gtf"
OUTPATH="/RNAresultsERP001058/"
SAM_OUT_PREFIX="Aligned.out"
NTHREADS=8
TCGASUBMIT="/home/scripts/TCGA-rna-ND-submit.sh"
TEXTFILE="xaa"
KEEPSAM="0"
INPATH=$PWD
while getopts "i:g:f:o:n:m:p:t:k:" ARG; do # colons denote which options have an argument after the option
	case "$ARG" in
		i ) INPATH=$OPTARG;;
		g ) GENOME_PATH=$OPTARG;;
		f ) GTF=$OPTARG;;
		o ) OUTPATH=$OPTARG;;
		n ) NTHREADS=$OPTARG;;
		m ) MEM=$OPTARG;;
		p ) SAM_OUT_PREFIX=$OPTARG;;
		t ) TEXTFILE=$OPTARG;;
		k ) KEEPSAM=$OPTARG;;
	esac
done

echo "Input Directory: ${INPATH}"
cd ${INPATH}

#for f1 in *_1.fastq.gz
#do
	#SAMPLENAME=$( basename "$f1") # extracts only the file name (rather than the directory also)
	#SAMPLEBASE=${SAMPLENAME%%_*} # extracts only the sample name (takes out _1)
while read line
do
	#SN=$( basename "$line")
	#SAMPLEBASE=${line%%.*}
	#echo "Processing File: ${SAMPLEBASE}"
	UUID="$line"
	echo "Processing UUID: ${UUID}"

	$TCGASUBMIT -u ${UUID} -i ${INPATH} -o ${OUTPATH} -g $GENOME_PATH -f ${GTF} -n ${NTHREADS} -p ${SAM_OUT_PREFIX} -k ${KEEPSAM}
done < ${TEXTFILE}
#done
