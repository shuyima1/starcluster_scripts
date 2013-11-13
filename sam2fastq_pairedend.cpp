#include <iostream>
#include <stdlib.h>
#include <fstream>
#include <string.h>
#include <sstream> // for int2strinng
#include <vector>
#include <algorithm> // for count
#include <numeric> // for accumulate
#include <tr1/unordered_map>
using namespace std;

void usage() {
    printf("Usage: sam2fastq_paireded -i input_sam -o output_prefix\n");
}

const int SAM_UNMAPPED           = 0x004;
const int SAM_REVERSE_COMPLEMENT = 0x010;

typedef struct sam_record {

    string header;
    int chr;
    int pos;
    unsigned temp;
    char flag;
    string cigar;
    string seq;
    string phred;   
    int num_alignments;
    
    void process_sam_record(string line) {
    
        std::stringstream linestream(line);
        std::vector<string> tokens;
        
        //Split the line by tabs
        while (linestream) {
            string s;
            if (!getline(linestream, s, '\t')) break;
            tokens.push_back(s);
        }
    
        //Split the header if necessary
        std::stringstream headerstream(tokens[0]);
        headerstream >> header;
        seq = tokens[9];
        
        std::stringstream charstream(tokens[1]);
        charstream >> temp;
        flag = (char)temp;

        phred = tokens[10];
        num_alignments = 1;
        //printf("%s\t%s\t%s\t%s\t%c\n",header.c_str(), seq.c_str(), "+", phred.c_str(), flag);
    }
    
    void reverse_complement() {
    
        string complement = "";
        
        //Gets the reverse complement of the sequence
        for (int i = seq.length()-1; i >= 0; i--) { 
                    
            switch (seq[i]) {
            
                case 'A':
                    complement.append("T");
                    break;
                case 'T':
                    complement.append("A");
                    break;
                case 'C':
                    complement.append("G");
                    break;
                case 'G':
                    complement.append("C");
                    break;
                case 'N':
                    complement.append("N");
                    break;
                default:
                    complement.append("N");
                    printf("Warning, character '%c' not known in read %s", seq[i], header.c_str());
                    break;      
            }
        }
        
        seq = complement;
    }
    
    void WriteFASTQ(ofstream &outfile) {
        
        //If this read is mapped and reverse complemented
        if (!(flag & SAM_UNMAPPED) && (flag & SAM_REVERSE_COMPLEMENT)) {
            reverse_complement();
        }
      
        //Write out only the record with the highest quality
        outfile << "@"+header << endl;
        outfile << seq << endl;
        outfile << "+" << endl;
        outfile << phred << endl;
        
    }

} sam_record;

typedef tr1::unordered_map<string, sam_record> sam_map;

int filter(ifstream &infile, ofstream &outfile1, ofstream &outfile2, int min_length) {

    sam_map sm;
    struct sam_record record;
    sam_map::iterator pos;
    int num_lines = 0;
    string line;
    
    std::getline(infile, line, '\n');
    while (!infile.eof()){
                        
        //Calculate complement of this read
        record.process_sam_record(line);
        
        //Look in the hash table using the header for this read       
        pos = sm.find(record.header);
        
        //If this sequence is not found, create a new vector to store this sequence (and others like it)
        if (pos == sm.end()) {
        
            //Just add this sam_element into the map
            sm.insert(sam_map::value_type(record.header, record)); 
            
        } else if (pos != sm.end()) {
        
            //Increment the count
            pos->second.num_alignments += 1;
            
            if (pos->second.num_alignments == 1) {
                //printf("Warning, only one alignment: %s\n", pos->second.header.c_str());
            } else if (pos->second.num_alignments == 2) {
                
                //Write out the FASTQ files
                //Ensure the length meets the minimum 
                if ((min_length == -1) || ((pos->second.seq.length() == min_length) && (record.seq.length() == min_length))) {
                
                    pos->second.WriteFASTQ(outfile1);
                    record.WriteFASTQ(outfile2);                
                }
                
            } else {
                //printf("Warning, more than 2 alignments: %s\n", pos->second.header.c_str());
            }

        }
            
        num_lines++;
        if ((num_lines % 1000000) == 0) {
            printf("Processed %d reads\n", num_lines);
        }
        
        std::getline(infile, line, '\n');         
        
    }
}

int main(int argc, char *argv[]){

    string filename = "";
    string output = "";
    int min_length=-1;

    //Process the command-line arguments
    int c;
    while ((c=getopt(argc, argv, "i:o:l:h")) != EOF) {
        switch(c) {
            case 'i':
                filename = optarg;
                break;
            case 'o':
                output = optarg;
                break;
            case 'l':
                min_length = atoi(optarg);
                break;
            case 'h':
                usage();
                exit(0);
            case ':':
                cerr << "Invalid option " << optarg << endl;
                usage();
                exit(1);
                break; 	
	    }
    }

    //Get input filename
    if (filename.length() == 0) {
        fprintf(stderr, "Input filename required\n");
        usage();
        exit(1);
    }
    
    //Make sure we set an output filename so we don't overwrite anything
    if (output.length() == 0) {
        fprintf(stderr, "Output prefix required\n");
        usage();
        exit(1);
    }
    
    //Open input file
    std::ifstream infile(filename.c_str(), std::ios::in);
    if (!infile.is_open()) { 
        printf("Cannot open input file '%s'\n", filename.c_str());
	    exit(1);
    }
    
    string filename1 = output + "_1.fastq";
    string filename2 = output + "_2.fastq";
    
    //Open output file
    std::ofstream outfile1(filename1.c_str(), std::ios::out);
    if (!outfile1.is_open()) {
        printf("Cannot open output file '%s'\n", filename1.c_str());
        exit(1);
    }
    std::ofstream outfile2(filename2.c_str(), std::ios::out);
    if (!outfile2.is_open()) {
        printf("Cannot open output file '%s'\n", filename2.c_str());
        exit(1);
    }
    
    //Filter the reads
    filter(infile, outfile1, outfile2, min_length);
    
    //Close the files
    infile.close();
    outfile1.close();
    outfile2.close();
    return 0;
}

