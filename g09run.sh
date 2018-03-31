#!/bin/bash
#
# Runs g09 and sends last ten lines of result by email when finished.
# Usage: g09run input-filename [email] 

extension='.com$|.gjf$'
exec_name='g09'

if which $exec_name
then
    if [[ -f "$1" ]]
    then
        if [[ "$1" =~ $extension ]]  # Regex for correct extensions of the files.
        then
            echo "Running: $exec_name $1...."
            outputFile="${1/%${BASH_REMATCH[0]}/\.log}"
            $exec_name "$1"
            if [[ "$2" ]] && which mail
            then
                echo "Mailing output to $2...."
                tail $outputFile | mail $2 -s "$exec_name Job $1 Result"                       
            else
                echo 'Email address not specified or no "mail" command available. Skipping mailing.' >&2
            fi
        else
            echo "Input must have extension of .com or .gjf." >&2
            echo "Usage: g09run.sh [job file name] [email address]"
            exit 2
        fi
    else
        echo "Input $1 does not exist." >&2
        exit 1
    fi
else
    echo "$exec_name is not initialized." >&2
    exit 255
fi


