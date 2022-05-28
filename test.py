#! /usr/bin/env python3.6

with open('terraform.tfstate', 'r') as tfstate :
  line = tfstate.readline()
  count = 1
  for line in tfstate:
    count += 1
    if str("public_dns") in line:
      pubdns = line.split(':')
      with open('host', 'a') as hosts:
        hosts.write(f'{pubdns}') 
    elif str('\"public_ip\":') in line:
      pubip = line.split(':')
      with open('hostip', 'a') as hostsip:
        hostsip.write(f'{pubip}')
    else:
      continue

#commit test
