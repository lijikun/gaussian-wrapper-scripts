#!/bin/bash
#
# Submits job and sends last 20 lines of result by email when finished.
# Usage: g17run.bash input-filename [email] 

extension='.com$|.gjf$'
exec_name="sbatch ${HOME}/.g17wrap.csh"
user_name='your_user_name'
sleep_interval=600

if [[ -f "$1" ]]; then
    if [[ "$1" =~ $extension ]]; then
        echo "Running: $exec_name $1...."
        #outputFile="${1/%${BASH_REMATCH[0]}/\.log}"
        output_file="$1.log"
        job_id=$($exec_name "$1" | awk '{print $4}')
        echo "Job ID is ${job_id}"
        if [[ "$2" ]] && echo "Using email client: "$(which mail) ; then
            while squeue -u $user_name | grep $job_id ; do
                    sleep $sleep_interval
            done
            echo "Mailing output to $2...."
            tail $output_file --lines=20 | mail $2 -s "${exec_name} Job $1 Result"                       
        else
            echo 'Email address not specified or no "mail" command available. Skipping mailing.' >&2
        fi
        exit 0
    else
        echo "Input must have extension of .com or .gjf." >&2
        echo "Usage: g09run.sh job-file-name [email-address]"
        exit 2
    fi
else
    echo "Input $1 does not exist." >&2
    exit 1
fi
