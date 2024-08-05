#!/bin/sh
for file in $(find . -iname "*.lua") ; do
    echo "obfuscating $file"
    lua ./cli.lua --preset Strong $file
done