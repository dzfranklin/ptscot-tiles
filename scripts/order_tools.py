#!/usr/bin/env python3

import glob
import json
import sys

layers = {}
for pathname in glob.iglob("./layers/*/style.json"):
    with open(pathname) as f:
        contents = json.load(f)
    if "layers" not in contents:
        continue
    layers[pathname] = contents

for pathname in layers:
    for layer in layers[pathname]["layers"]:
        if "order" not in layer:
            print("missing order property: " + pathname)

command = sys.argv[1]
if command == "check":
    issues = 0

    orders = {}
    max_order = 0
    for pathname in layers:
        for layer in layers[pathname]["layers"]:
            order = layer["order"]
            if order in orders:
                print("duplicate order: " + str(order) + " in " + pathname + " and " + orders[order])
                issues += 1
            if order < 1:
                print("order below 1: " + pathname)
                issues + 1
            orders[order] = pathname
            max_order = max(max_order, order)

    for order in range(1, max_order + 1):
        if order not in orders:
            print("gap: " + str(order))
            issues += 1

    if issues > 0:
        print("found " + str(issues) + " issues")
        sys.exit(1)
    else:
        print("no issues found")
elif command == "add-gap":
    gap_number = int(sys.argv[2])
    for pathname in layers:
        for layer in layers[pathname]["layers"]:
            if layer["order"] >= gap_number:
                layer["order"] += 1
elif command == "remove-gap":
    gap_number = int(sys.argv[2])
    for pathname in layers:
        for layer in layers[pathname]["layers"]:
            if layer["order"] == gap_number:
                print("not a gap: " + str(gap_number) + " in " + pathname)
                sys.exit(1)
    for pathname in layers:
        for layer in layers[pathname]["layers"]:
            if layer["order"] > gap_number:
                layer["order"] -= 1
else:
    print("Unrecognized command: " + command)
    sys.exit(1)

for pathname in layers:
    with open(pathname, "w") as f:
        json.dump(layers[pathname], f, indent=2)
