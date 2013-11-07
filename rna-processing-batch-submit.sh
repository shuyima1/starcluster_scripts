#!/bin/bash
MEM="64G"
GENOME_PATH="/STARgenomeIndex/GENjob4"
GTF="/home/GRCh37/gtf/Homo_sapiens.GRCh37.68.gtf"
RNASEQ1_PATH="/RNAdataERP001058_1"
RNASEQ2_PATH="/RNAdataERP001058_2"
OUT_PATH="/RNAresultsERP001058/"
SAM_OUT_PREFIX="Aligned.out"
NTHREADS=8
RNASUBMIT="/home/scripts/rna-processing-submit.sh"
TEXTFILE="xaa"
KEEPSAM="0"
while getopts "q:r:g:f:o:n:m:p:t:k:" ARG; do # colons denote which options have an argument after the option
	case "$ARG" in
		q ) RNASEQ1_PATH=$OPTARG;;
		r ) RNASEQ2_PATH=$OPTARG;;
		g ) GENOME_PATH=$OPTARG;;
		f ) GTF=$OPTARG;;
		o ) OUT_PATH=$OPTARG;;
		n ) NTHREADS=$OPTARG;;
		m ) MEM=$OPTARG;;
		p ) SAM_OUT_PREFIX=$OPTARG;;
		t ) TEXTFILE=$OPTARG;;
		k ) KEEPSAM=$OPTARG;;
	esac
done

echo "Input Directory: ${RNASEQ1_PATH}"
cd ${OUT_PATH}

#for f1 in *_1.fastq.gz
#do
	#SAMPLENAME=$( basename "$f1") # extracts only the file name (rather than the directory also)
	#SAMPLEBASE=${SAMPLENAME%%_*} # extracts only the sample name (takes out _1)
while read line
do
	#SN=$( basename "$line")
	SAMPLEBASE=${line%%.*}
	echo ${SAMPLEBASE}
	FILE1="${RNASEQ1_PATH}/${SAMPLEBASE}.sra.ncbi_enc_1.fastq.gz"
	FILE2="${RNASEQ2_PATH}/${SAMPLEBASE}.sra.ncbi_enc_2.fastq.gz"

	$RNASUBMIT -g $GENOME_PATH -f ${GTF} -n ${NTHREADS} -p ${SAM_OUT_PREFIX} -x ${FILE1} -y ${FILE2} -k ${KEEPSAM}
done < ${TEXTFILE}
#done
