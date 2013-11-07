#!/bin/bash
#PROCS=8
NTHREADS=1
SOURCE_PATH="/STARgenomeIndex/GENjob4/"
DESTINATION_PATH="/RNAresults_dbGaP1/"
MEM="1G"
QUEUE="all.q"
JOBNAME="File-Move"
EMAIL="dreamcatcher284@gmail.com"
FILE1=""
#SAMPLEID=""
#OUTPUT="/results"
#STAR="/home/STAR_2.3.0e/STAR"
#TEXTFILE="samples.txt"

function usage {
	#echo "$0: [-m memory] [-N jobname] [-e email_address] [-g] [-c cert.pem] [-o OUTPUT_DIR] "
	echo "$0: [-n NTHREADS] [-e email_address] [-g genome_path] [-r rnaseq_path] [-x file1] [-y file2]"
	echo
}

while getopts "s:d:f:h" ARG; do # colons denote which options have an argument after the option
	case "$ARG" in
		#m ) MEM=$OPTARG;;
		#n ) NTHREADS=$OPTARG;;
		#e ) EMAIL=$OPTARG;;
		s ) SOURCE_PATH=$OPTARG;;
		d ) DESTINATION_PATH=$OPTARG;;
		#s ) SAMPLEID=$OPTARG;;
		#t ) TEXTFILE=$OPTARG;; #_1.fastq.gz
		f ) FILE1=$OPTARG;; #_2.fastq.gz
		#c ) CERT=$OPTARG;;
        #        o ) OUTPUT=$OPTARG;;
        #        b ) SAVE_BAM=1;;
		h ) usage; exit 0;;
		* ) usage; exit 1;;
	esac
done
shift $(($OPTIND - 1)) 


#FILE1=${@: -2}
#FILE2=\${`expr $i + $NUM_FILES_PER_READ`}

#FILE1=""
#while read line
#do
#FILE1="$FILE1,$RNASEQ_PATH$line"
#done < ${TEXTFILE}

#FILE1=${FILE1#*,}
#echo ${FILE1}

#FILE2=""
#while read line
#do
#FILE2="$FILE2,$RNASEQ_PATH$line"
#done < files2b.txt

#FILE2=${FILE2#*,}
#echo ${FILE2}

#SAMPLEID=${F1%%,*}
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
#$ -N ${JOBNAME}-job-${FILE1}

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
echo Directory is `pwd`
echo This job has allocated \$NSLOTS processors

# BEGIN COMMANDS 
echo "Moving in Directory: ${SOURCE_PATH}"
echo "Output Location: ${DESTINATION_PATH}"

# Make the output directory
mv ${SOURCE_PATH}${FILE1} ${DESTINATION_PATH}

echo End time is `date`

EOF

qsub $QSUBOPTS < $FILE

rm $FILE


