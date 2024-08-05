#!/bin/sh
for file in $(find . -path ./prometheus -prune -o -iname "*.lua" -print) ; do
    echo "obfuscating $file"
    lua ./prometheus/cli.lua --preset Strong $file
done

for file in $(find . -iname "*.obfuscated.lua" -print) ; do
    echo "renaming $file to ${file%.obfuscated.lua}.lua"
    mv $file ${file%.obfuscated.lua}.lua
done