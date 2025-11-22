#!/bin/bash
tmpFile=$HOME/.tmpFile
while IFS= read -r line; do
    if [[ "$line" == *"$1"* ]];
        then
            ;
    fi

done < "$input_file"
