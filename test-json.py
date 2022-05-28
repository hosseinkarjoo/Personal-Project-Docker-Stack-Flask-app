import json

with open('terraform.tfstate', 'r') as tfstate:
  json_load = json.load(tfstate)

print(json_load['resources'], ['instances'], ['attributes'], ['public_ip'])

