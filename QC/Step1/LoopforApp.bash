#!/bin/bash
finished=0
a=0

until ((finished)); do
	dx run QC_Step1 -iinput_file=file_list.txt -iline_number=${a} -igenotype=genotype.py -y
	((a<500?(a+=20):(finished=1)))
done
