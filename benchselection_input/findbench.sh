#!/bin/bash
# Finds sat benchmarks and pastes them to a folder

if [ $# -ne 3 ]; then
    echo "Usage: findbench.sh [folder] [list.csv] [destination]"
fi


while IFS= read -r lines; do
    filename=$( echo $lines | cut -d "," -f 2 | cut -d "." -f 1)
    findresult=$(find "$1" -name "$filename*")
    if [ $findresult ]; then
        cp $findresult $3
    else
	echo "$filename" "NOT FOUND"
    fi
done < $2
