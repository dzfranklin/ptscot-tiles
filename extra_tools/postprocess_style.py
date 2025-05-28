#!/usr/bin/env python

import json

import sys

fpath = sys.argv[1]

with open(fpath, 'r') as f:
    style = json.load(f)

with open("/style/hillshading_layer.json") as f:
    hillshading = json.load(f)

new_layers = []
did_include_hillshading = False
for layer in style["layers"]:
    if layer["id"] == "landcover_subclass_patterns":
        did_include_hillshading = True
        for extra_layer in hillshading["layers"]:
            new_layers.append(extra_layer)

    new_layers.append(layer)
style["layers"] = new_layers
assert did_include_hillshading

with open(fpath, 'w') as f:
    json.dump(style, f)
