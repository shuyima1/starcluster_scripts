#!/bin/bash
NTHREADS=1
GENOME_FILE="/home/GRCh37/fasta/Homo_sapiens.GRCh37.68.genome.fa"
PREFIX="Aligned.out"
RNA_PATH="/RNAresultsGSE34914/results"
SAMPLEID=""
QUEUE="all.q"
##JOBNAME="samtools"
MEM="1G"
SAMTOOLS="/home/samtools-0.1.19/samtools"

while getopts "m:n:g:r:s:p:h" ARG; do # colons denote which options have an argument after the option
	case "$ARG" in
		m ) MEM=$OPTARG;;
		n ) NTHREADS=$OPTARG;;
	#	e ) EMAIL=$OPTARG;;
		g ) GENOME_FILE=$OPTARG;;
		r ) RNA_PATH=$OPTARG;;
		s ) SAMPLEID=$OPTARG;;
		p ) PREFIX=$OPTARG;;
		h ) usage; exit 0;;
		* ) usage; exit 1;;
	esac
done
shift $(($OPTIND - 1)) 

DATE=`date +%Y.%m.%d.%H.%M.%S`
FILE=`mktemp SAMTOOLS-rna-.XXXXXXXXXX`

cat > $FILE <<EOF
#!/bin/bash

### SGE settings #################################################

#$ -S /bin/bash
#$ -V

# Change to current working directory (otherwise starts in $HOME)
#$ -cwd

# Set the name of the job
#$ -N samtools-job-${SAMPLEID}

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
###$ -l mem_free=$MEM
###$ -l h_vmem=$MEM

# Restart the job if it fails (e.g. if EC2 spot instance is killed)
#$ -r y

### Job settings ###################################################

echo Running on host `hostname`
echo Start time is `date`
echo Directory is `pwd`
##echo This job runs on the following processors:
##cat \$TMPDIR/machines
echo This job has allocated \$NSLOTS processors

# BEGIN COMMANDS 
echo "Processing SAMPLE: ${SAMPLEID}"
echo "SAMPLE Location: ${RNA_PATH}/${SAMPLEID}"

# Move into the output directory
cd ${RNA_PATH}/${SAMPLEID}

ls

#### Run SAMTOOLS
$SAMTOOLS view -uST ${GENOME_FILE} Aligned.out.sam | $SAMTOOLS sort - Aligned.out

echo End time is `date`

EOF

qsub $QSUBOPTS < $FILE

rm $FILE
