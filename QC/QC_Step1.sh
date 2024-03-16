#!/bin/bash

main() {
    
	# Step 0: Downloading executables
   
    pip install joblib 
    pip install pyspark 
    pip install numpy==1.22.4
    pip install cryptography==36.0.0 
    pip install hail 
    PATH=$PATH:'/home/dnanexus/.local/bin''/usr/bin/local'
    
	mkdir ~/jdk
    cd ~/jdk
    dx download project-GF4jpV8JyFyK68BP64YpqFYQ:file-GJ5Gj1QJyFy54K2X9Bzf8g0X
    tar -zxvf jdk-8u161-linux-x64.tar.gz
    export JAVA_HOME=/home/dnanexus/jdk/jdk1.8.0_161
    export JRE_HOME=/home/dnanexus/jdk/jdk1.8.0_161/jre
    export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib:$CLASSPATH
    export PATH=$JAVA_HOME/bin:$PATH
    
	export PYSPARK_SUBMIT_ARGS="--driver-memory 120g --executor-memory 120g pyspark-shell"
    source ~/.bashrc


    # Step 1: input variables recognition from JSON
    
	cd $HOME
    dx download "$input_file" -o input_file     
    position="$line_number"
    dx download "$genotype" -o genotype

    #note1: ${i} is the variable from Json file, rename the variable in shell script

    
    # Step 2: downloading .gz files
	
    for i in {0..9}; do #total 100 files per running
	     cd $HOME
	     mkdir -p ~/data/pVCF_raw
         mkdir -p ~/data/pVCF_mt
         mkdir -p ~/data/plink
			 
         cp input_file ~/data/pVCF_raw/
         echo "Value of Starting Line Number: '$position'" 
            
  	     cd ~/data/pVCF_raw
         linecount=0
         while read lines; do
             ((++linecount))
                 if [ "$linecount" -lt $(($position + 20)) -a "$linecount" -ge "$position" ]; then #20 files per time
                     if [[ "${lines}" =~ ^ukb23148_[a-z][0-9|X|Y]+_[a-z][0-9]+_[a-z][0-9].vcf.gz$ ]]; then #select only .gz files, not .tbi files
                         dx download "project-GF4jpV8JyFyK68BP64YpqFYQ:/Bulk/Exome sequences/Population level exome OQFE variants, pVCF format - interim 450k release/$lines"  
                         echo ${lines}   
                     fi 
                 fi
         done < input_file
		 
    #note1: have to name the input variable of Json file, and then loop while $line could be performed
    #note2: in shell, to perform 'if' selection for regular expressions, have to [[ "$i" =~ ... ]], regular expression should not be written in "..."
    #note3: [0-9|X|Y] is acceptable but [0-9a-z] is not in "if" selection. The ".", "*" is not acceptable


    # Step 3: performing main analysis
         cd $HOME
         python3 genotype
    #note 4: could also write like below to perform python in shell
    #usr/bin/python3 <<-EOF
    #EOF


    # Step 4: uploading results
         dx upload -r $HOME/data/plink/ --destination "project-GF4jpV8JyFyK68BP64YpqFYQ:/Sirius_data/plinkwbs"
		 rm -r ~/data/
		 
		 ((position+=20))
		 
     done

}
