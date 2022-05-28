#! /usr/bin/env python3.6
import os 

aws_access_key = str(input("Enter access-key: "))
#aws_secret_key = input("Enter secret-key: ")

os.environ['AACCESS_KEY'] = aws_access_key
#print(os.environ['ACCESS_KEY'])
#print(aws_access_key)
print(os.environ['HOME'])
