#!/bin/bash
MEM="64G"
GENOME_PATH="/STARgenomeIndex/GENjob4"
RNASEQ1_PATH="/RNAdataERP001058_1"
RNASEQ2_PATH="/RNAdataERP001058_2"
OUT_PATH="/RNAresultsERP001058/"
NTHREADS=8
STARSUBMIT="/home/scripts/star-rna-submit.sh"
TEXTFILE="xaa"
while getopts "q:r:g:o:n:m:t:" ARG; do # colons denote which options have an argument after the option
	case "$ARG" in
		q ) RNASEQ1_PATH=$OPTARG;;
		r ) RNASEQ2_PATH=$OPTARG;;
		g ) GENOME_PATH=$OPTARG;;
		o ) OUT_PATH=$OPTARG;;
		n ) NTHREADS=$OPTARG;;
		m ) MEM=$OPTARG;;
		t ) TEXTFILE=$OPTARG;;
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
	FILE1="${RNASEQ1_PATH}/${SAMPLEBASE}_1.fastq.gz"
	FILE2="${RNASEQ2_PATH}/${SAMPLEBASE}_2.fastq.gz"

	$STARSUBMIT -n $NTHREADS -g $GENOME_PATH -x ${FILE1} -y ${FILE2}
done < ${TEXTFILE}
#done
