#!/bin/bash
#PROCS=8
NTHREADS=8
GENOME_PATH="/STARgenomeIndex/GENjob4"
GTF="/home/GRCh37/gtf/Homo_sapiens.GRCh37.68.gtf"
GENOME_FILE="/home/GRCh37/fasta/Homo_sapiens.GRCh37.68.genome.fa"
SAM_OUT_PREFIX="Aligned.out"
MEM="64G"
QUEUE="all.q"
JOBNAME="tcga-rna"
EMAIL="dreamcatcher284@gmail.com"
#SAMPLEID=""
#OUTPUT="/results"
STAR="/home/STAR_2.3.0e/STAR"
SAMTOOLS="/home/samtools-0.1.19/samtools"
KEEPSAM="0"
INPATH=$PWD
OUTPATH=""

function usage {
	#echo "$0: [-m memory] [-N jobname] [-e email_address] [-g] [-c cert.pem] [-o OUTPUT_DIR] "
	echo "$0: [-n NTHREADS] [-e email_address] [-g genome_path] [-r rnaseq_path] [-x file1] [-y file2]"
	echo
}

while getopts "m:n:e:g:f:p:i:o:u:k:h" ARG; do # colons denote which options have an argument after the option
	case "$ARG" in
		m ) MEM=$OPTARG;;
		n ) NTHREADS=$OPTARG;;
		e ) EMAIL=$OPTARG;;
		g ) GENOME_PATH=$OPTARG;;
		f ) GTF=$OPTARG;;
		p ) SAM_OUT_PREFIX=$OPTARG;;
		i ) INPATH=$OPTARG;;
		o ) OUTPATH=$OPTARG;;
		u ) UUID=$OPTARG;;
		#x ) FILE1=$OPTARG;; #_1.fastq.gz
		#y ) FILE2=$OPTARG;; #_2.fastq.gz
		#c ) CERT=$OPTARG;;
        #        o ) OUTPUT=$OPTARG;;
        #        b ) SAVE_BAM=1;;
		k ) KEEPSAM=$OPTARG;;
		h ) usage; exit 0;;
		* ) usage; exit 1;;
	esac
done
shift $(($OPTIND - 1)) 


#FILE1=${@: -2}
#FILE2=\${`expr $i + $NUM_FILES_PER_READ`}

#F1=$(basename "${FILE1}")
#SAMPLEID=${F1%%.*}
#echo 

DATE=`date +%Y.%m.%d.%H.%M.%S`
FILE=`mktemp STAR-rna-.XXXXXXXXXX`

cat > $FILE <<EOF
#!/bin/bash

### SGE settings #################################################

#$ -S /bin/bash
#$ -V

# Change to current working directory (otherwise starts in $HOME)
#$ -cwd

# Set the name of the job
#$ -N ${JOBNAME}-job-${UUID}

# Combine output and error files into single output file (y=yes, n=no)
#$ -j y

# Request 8 cores total
#$ -pe orte $NTHREADS

# Specify the queue to submit the job to (only one at this time)
#$ -q $QUEUE

## Specify my email address for notification
###$ -M $EMAIL

## Specify what events to notify me for
## 'b'=job begins, 'e'=job ends, 'a'=job aborts, 's'=job suspended, 'n'=no email
###$ -m beas

# Minimum amount free memory we want
#$ -l mem_free=$MEM
#$ -l h_vmem=$MEM

# Restart the job if it fails (e.g. if EC2 spot instance is killed)
#$ -r y

### Job settings ###################################################

echo Running on host `hostname`
echo Start time is `date`
##echo Directory is `pwd`
##echo This job runs on the following processors:
##cat \$TMPDIR/machines
echo This job has allocated \$NSLOTS processors

## BEGIN COMMANDS 
echo "Processing SAMPLE: ${UUID}"
echo "fastq Input Location: ${INPATH}/${UUID}"
echo "BAM Output Location: ${OUTPATH}/results/${UUID}/"

##cd ${INPATH}

### Download TCGA-data
##echo "Downloading from TCGA"
##gtdownload -c /home/cghub.key -d ${UUID} -vv --ssl-no-verify-ca

##echo "Unpacking .fastq files"
cd ${INPATH}/${UUID}
tar -xvzf *.tar.gz

## Make the output directory
mkdir -p ${OUTPATH}/results/${UUID}/

echo Directory is `pwd`
## Run STAR-rna
echo "Running STAR"
eval "$STAR --runThreadN $NTHREADS --genomeDir $GENOME_PATH --outFileNamePrefix ${OUTPATH}/results/${UUID}/ --readFilesIn" '*_1.fastq' '*_2.fastq' "--alignIntronMin 20 --alignIntronMax 500000 --outFilterMismatchNmax 10"

echo "STAR complete"

if [ "$KEEPSAM" -eq "0" ]; then
        echo "Removing *.fastq files"
        rm *_1.fastq
       	rm *_2.fastq
fi

## Move into the output directory
cd ${OUTPATH}/results/${UUID}/

## Run SAM-tools
echo "Runnning SAMTOOLS"
$SAMTOOLS view -uST ${GENOME_FILE} Aligned.out.sam | $SAMTOOLS sort - Aligned.out

echo "SAMTOOLS complete"

## Run htseq-count
echo "Running HTSEQ-COUNT"
htseq-count -s no -i gene_name ${SAM_OUT_PREFIX}.sam ${GTF} > Aligned_hits.bam

echo "HTSEQ-COUNT complete"

if [ "$KEEPSAM" -eq "0" ]; then
	echo "Removing SAM file ${SAM_OUT_PREFIX}.sam"
	rm ${SAM_OUT_PREFIX}.sam
fi

echo End time is `date`

EOF

qsub $QSUBOPTS < $FILE

rm $FILE


