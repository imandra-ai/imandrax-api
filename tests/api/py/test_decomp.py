#!/usr/bin/env python

with open('decomp.iml', 'r') as file:
    data = file.read()

import imandrax_api
c = imandrax_api.Client('http://localhost:8000')
c.eval_src(data)
d = c.decompose(name='run_cycle', basis=['h_639909746', 'h_1617160941', 'h_767026065', 'h_1551930034'], timeout=1200, prune=False)
print(d)
print("done, exiting")
