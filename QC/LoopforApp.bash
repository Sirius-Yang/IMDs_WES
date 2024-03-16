#!/bin/bash
finished=0
a=0

until ((finished)); do
	dx run QC_Step1 -iinput_file=file_list.txt -iline_number=${a} -igenotype=genotype.py -y
	((a<500?(a+=20):(finished=1)))
done


#/usr/lib64里的libpython3.6m文件, python3.6文件夹，和usr/bin/里的python3.6程序都要放到resources/usr/bin/下面，然后调取是usr/bin/python3 <<-EOF
#python3是指用python3程序，而不是一个单纯的路径
mv libpython3.6m.so.1.0 python3/ 
cp -r /usr/lib64/python3.6/ /mnt/storage/home1/Huashan1/SiriusWhite/QC_Step1/resources/usr/bin/python3


curl --insecure --data "action=login&username=17301050255&password=529462Sirius&ac_id=1&user_ip=10.190.65.16&nas_ip=&user_mac=&save_me=0&ajax=1" https://10.108.255.249/include/auth_action.php