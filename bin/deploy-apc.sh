#!/bin/bash



scp $1 root@$2:/mnt/hd/tmp/
ssh root@$2 << EOF

cd /mnt/hd/tmp
tar -zxvf $1
cd vectastar_install
./installsys.sh
reboot

EOF
