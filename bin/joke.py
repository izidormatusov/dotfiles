#!/usr/bin/env python
from urllib import urlopen, urlencode
import json
import sys

params = {}

if len(sys.argv) >= 2:
    params['firstName'] = sys.argv[1]
if len(sys.argv) >= 3:
    params['lastName'] = sys.argv[2]

query = urlencode(params)
url = 'http://api.icndb.com/jokes/random?' + query
response = json.loads(urlopen(url).read())
print response['value']['joke']
