#!/bin/bash



DEPOSIT="/tmp/cloud"
output_file="cloud_ips.txt"

mkdir -p  /tmp/cloud


##############

#greps for IPv4 ips, and ranges, formats
range_finder() {
  while read -r subset; do
	if [[ $subset == *"^-^"* ]]; then
		echo $(ipcalc $(echo $subset | tr '^' ' ') | tail -n 1)
	else
		echo "$subset"
	fi

  done < <(grep -oE '([0-9]{1,3}(\.[0-9]{1,3}){3}(/[0-9]{1,2})?|([0-9]{1,3}(\.[0-9]{1,3}){3}[ ]?-[ ]?[0-9]{1,3}(\.[0-9]{1,3}){3}))' | tr ' ' '^')
}

#######################


echo getting AWS IP addresses

curl -s https://ip-ranges.amazonaws.com/ip-ranges.json | range_finder | sort -uV > $DEPOSIT/aws_ips

echo "Got $(cat $DEPOSIT/aws_ips | wc -l) lines"
echo

#######################

echo getting Cloudflare addresses

curl -s https://www.cloudflare.com/ips-v4 > $DEPOSIT/cloudflare_ips
echo >>  $DEPOSIT/cloudflare_ips

curl -s https://www.cloudflare.com/ips-v6 >> $DEPOSIT/cloudflare_ips

echo "Got $(cat $DEPOSIT/cloudflare_ips | wc -l) lines"
echo

###########################

echo getting Linode  addresses

curl -s https://geoip.linode.com/  | cut -f 1 -d \,> $DEPOSIT/linode_ips

echo "got $(cat $DEPOSIT/linode_ips | wc -l) lines"
echo

###########################

echo adding umraco addresses

echo "146.112.0.0/16" > $DEPOSIT/umbrella
echo "155.190.0.0/16" >> $DEPOSIT/umbrella

echo "got $(cat $DEPOSIT/umbrella | wc -l) lines"
echo

###########################

echo digitalocean IPs

curl -s https://www.digitalocean.com/geo/google.csv | cut -f 1 -d \, > $DEPOSIT/digitalocean_ips

echo "got $(cat $DEPOSIT/digitalocean_ips | wc -l) lines"
echo

#########################

echo getting microsft IPs 

#url download pulled from here: https://www.microsoft.com/en-us/download/details.aspx?id=53602

MSFT_URL="https://download.microsoft.com/download/B/2/A/B2AB28E1-DAE1-44E8-A867-4987FE089EBE/msft-public-ips.csv"

curl -s $MSFT_URL | cut -f 1 -d "," | grep -vi prefix> /tmp/MSFT_TMP

if grep -q 404.Not.Found /tmp/MSFT_TMP ; then 
	printf "\nMicrosoft IPs failed. try to find URL again\n"
	rm  /tmp/MSFT_TMP
	touch  $DEPOSIT/microsoft_ips
else
	mv /tmp/MSFT_TMP $DEPOSIT/microsoft_ips
fi

echo "Got $(cat $DEPOSIT/microsoft_ips | wc -l) lines"
echo


##########################
echo "Grabbing Jason Lang's"

curl -s https://gist.githubusercontent.com/curi0usJack/971385e8334e189d93a6cb4671238b10/raw/c1f61b6b2d43227d541f6f3cbf7bb874d8794c24/.htaccess | range_finder | sort -uV > $DEPOSIT/jlang

echo "Got $(cat $DEPOSIT/jlang | wc -l) lines"
echo

##########################

echo getting forcepoint stuff from ip info

curl -s https://ipinfo.io/AS44444 -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36 curl/7.55.1" | range_finder | sort -uV > $DEPOSIT/forcepoint

echo "Got $(cat $DEPOSIT/forcepoint | wc -l) lines"
echo
##########################

echo getting fortinet stuff from ip info

curl -s https://ipinfo.io/AS40934 -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36 curl/7.55.1"|  range_finder | sort -uV > $DEPOSIT/fortinet

echo "Got $(cat $DEPOSIT/fortinet | wc -l) lines"
echo

##########################

echo getting PALO ALTO stuff from ip info

curl -s https://ipinfo.io/AS54538 -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36 curl/7.55.1" | range_finder | sort -uV  > $DEPOSIT/palo

echo "Got $(cat $DEPOSIT/palo | wc -l) lines"
echo

##########################

echo getting symantic ranges

curl -s https://knowledge.broadcom.com/external/article/150693/ip-address-ranges-for-email-symantecclou.html |  range_finder | sort -uV > $DEPOSIT/symantec


echo "Got $(cat $DEPOSIT/symantec | wc -l) lines"
echo
##########################

echo getting zscalar ranges

curl -s https://config.zscaler.com/api/getdata/zscalerthree.net/all/cenr?site=config.zscaler.com |  range_finder | sort -uV > $DEPOSIT/zscalar

echo "Got $(cat $DEPOSIT/zscalar | wc -l) lines"
echo

##########################

echo Adding mimecast

echo """
103.13.69.0/24
103.96.20.0/22
124.47.150.0/24
124.47.189.0/24
146.101.76.0/23
146.101.78.0/24
180.189.28.0/24
185.58.84.0/22
193.7.204.0/24
193.7.207.0/24
194.104.108.0/24
194.104.111.0/24
195.130.217.0/24
204.141.92.0/24
205.139.110.0/23
207.211.30.0/24
207.211.31.0/24
207.82.80.0/24
216.145.219.0/24
216.145.221.0/24
216.205.24.0/24
216.35.243.0/24
216.35.244.0/24
41.74.192.0/21
41.74.200.0/23
41.74.202.0/24
41.74.203.0/24
41.74.204.0/22
51.163.158.0/23
62.140.10.0/24
62.140.7.0/24
63.128.21.0/24
91.220.42.0/24
""" > $DEPOSIT/mimecast
echo
##########################



echo adding extras
echo

echo """
195.189.155.0/24 # BitDefender
91.199.104.0/24 # BitDefender
91.212.136.0/24 # IKARUS Security Software
208.90.236.0/22 # Trustwave Holdings, Inc.
204.13.200.0/22 # Trustwave Holdings, Inc.
207.102.138.0/24, FORTINET TECHNOLOGIES (CANADA) INC
208.87.232.0/21 # SurfControl, Inc.
103.245.47.20 # McAfee Software (India) Private Limited
182.75.165.176/30 # NETSKOPE
3.80.0.0/12 # Finegrained AWS
3.0.0.0/9 # Finegrained AWS
"""  > $DEPOSIT/extras

#palo
echo """
70.42.131.0/24
70.42.131.0/24
64.74.215.0/24
65.154.226.0/24
85.115.60.0/24
208.87.232.0/21
""" > $DEPOSIT/extras
echo

##########################

cat $DEPOSIT/* oldblacklist.txt | sort -uV | grep -v ^\# > $output_file


echo "added $(cat $output_file | wc -l) ranges to $output_file"
