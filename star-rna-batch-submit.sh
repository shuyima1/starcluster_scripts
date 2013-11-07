#!/bin/bash
MEM="64G"
GENOME_PATH="/STARgenomeIndex/GENjob4"
RNASEQ_PATH="/RNAdataGSE34914/fastq"
OUT_PATH="/RNAresultsGSE34914/"
NTHREADS=8
STARSUBMIT="/home/scripts/star-rna-submit.sh"

while getopts "r:g:o:n:m:" ARG; do # colons denote which options have an argument after the option
	case "$ARG" in
		r ) RNASEQ_PATH=$OPTARG;;
		g ) GENOME_PATH=$OPTARG;;
		o ) OUT_PATH=$OPTARG;;
		n ) NTHREADS=$OPTARG;;
		m ) MEM=$OPTARG;;
	esac
done

echo "Input Directory: ${RNASEQ_PATH}"
cd ${OUT_PATH}

#for f1 in *_1.fastq.gz
#do
	#SAMPLENAME=$( basename "$f1") # extracts only the file name (rather than the directory also)
	#SAMPLEBASE=${SAMPLENAME%%_*} # extracts only the sample name (takes out _1)
while read line
do
	#SN=$( basename "$line")
	SAMPLEBASE=${line%%_*}
	echo ${SAMPLEBASE}
	FILE1="${RNASEQ_PATH}/${SAMPLEBASE}_1.fastq.gz"
	FILE2="${RNASEQ_PATH}/${SAMPLEBASE}_2.fastq.gz"

	$STARSUBMIT -n $NTHREADS -g $GENOME_PATH -x ${FILE1} -y ${FILE2}
done < files1.txt
#done
