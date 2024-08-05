#!/bin/sh
for file in $(find . -path ./prometheus -prune -o -iname "*.lua" -print) ; do
    echo "obfuscating $file"
    lua ./prometheus/cli.lua --preset Strong $file
done