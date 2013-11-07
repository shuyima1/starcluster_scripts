#!/bin/bash

### SGE settings #################################################

#$ -S /bin/bash
#$ -V

# Change to current working directory (otherwise starts in $HOME)
#$ -cwd

# Set the name of the job
#$ -N star-genome-create

# Combine output and error files into single output file (y=yes, n=no)
#$ -j y

#$ -q all.q

STAR=/home/STAR_2.3.0e/STAR
GENDIR=/STARgenomeIndex/GENjob4  #/STARhumangenomeIndex/GENjob3 #/STARhumangenomeIndex
GENFASTA=/mnt/GRCh37/fasta/Homo_sapiens.GRCh37.68.genome.fa
GENGTF=/mnt/GRCh37/gtf/Homo_sapiens.GRCh37.68.gtf

$STAR --runMode genomeGenerate --genomeDir $GENDIR --genomeFastaFiles $GENFASTA --sjdbGTFfile $GENGTF --sjdbOverhang 100 --runThreadN 4
