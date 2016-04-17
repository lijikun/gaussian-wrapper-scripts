#!/bin/bash
#
# Batch-generates g09 input files from coordinates and a template
# Usage: coord2input.sh templatefile coordfile1 [coordfile2 ...] [-c charge] [-m multiplicity] [-s invoking-script] [-n number-of-processors]

# Default parameters:
charge=0
multiplicity=1
scriptName="g09batch.sh"
nProcs=1
template=
coords=
scriptCommand="g09"

# Processes command line arguments:
while [[ $1 ]]; do
    case "$1" in
        -c)
            isCharge='^-?[0-9]+$'
            if [[ $2 && $2 =~ $isCharge ]]; then
                charge=$2
                shift 2;
            else
                echo "Warning: Invalid charge $2. Default to ${charge}."
                shift;
            fi;;
        -m)
            isMultiplicity='^0*[1-9][0-9]*$'
            if [[ $2 && $2 =~ $isMultiplicity ]];then
                multiplicity=$2
                shift 2
            else
                echo "Warning: Invalid multiplicity $2. Default to ${multiplicity}."
                shift
            fi;;
        -s)
            if [[ "$2" ]]; then
                scriptName=$2
                shift 2
            else
                echo "Warning: No script file name specified. Default to ${scriptName}."
                shift
            fi;;
        -n)
            isNProcs='^0*[1-9][0-9]*$'
            if [[ $2 && $2 =~ $isNProcs ]]; then
                nProcs=$2
                shift 2
            else
                echo "Warning: Invalid number of processors $2. Default to ${nProcs}."
                shift
            fi;;
        *)
            if [[ -f $1 ]]; then
                if [[ $template ]]; then
                    coords=${coords}$'\n'$1 
                else
                    template=$1
                fi
            else
                echo "Warning: File $1 does not exist. Ignored."
            fi
            shift;;
    esac
done
[[ $template ]] || { echo "Error: No template file specified."; exit 1; }
[[ $coords ]] || { echo "Error: No coordinate file(s) specified."; exit 1; }


# Generates g09 input files:
echo "#Processors = ${nProcs}"
echo "Charge = ${charge}    Multiplicity = ${multiplicity}"
echo "Template file: ${template}"
echo
echo "Generated input files:"
[[ -f $scriptName ]] || { echo '#!/bin/bash'; echo; } > $scriptName
OLDIFS=$IFS
IFS=$'\n'
for x in $coords;
do
    extension='\.\w*$'
    baseName=$(basename $x)
    if [[ $baseName =~ $extension ]]; then
        title=${baseName%${BASH_REMATCH[0]}}
    else
        title=$baseName
    fi
    inputFile="${title}_$(basename $template)"
    { cat $template | while read templateLine; do
        case $templateLine in
            !chkfile!)
                echo "%chk=${inputFile}.chk" ;;
            !nprocs!)
                echo "%nprocshared=${nProcs}" ;;
            !title!)
                echo ${inputFile} ;;
            !coordinates!)
                echo "${charge}    ${multiplicity}"
                [[ $discardLine ]] || discardLine='^[0-9]*$'
                cat $x | while read coordLine; do
                    [[ $coordLine =~ $discardLine ]] || echo ${coordLine}
                done ;;
            *)
                echo ${templateLine} ;;
        esac
    done; } > $inputFile
    # Adds an empty line to end of file if there isn't one in the template.
    [[ $(tail -n1 $inputFile) ]] && echo >> $inputFile
    echo "${scriptCommand} ${inputFile}" >> $scriptName
    echo "  ${inputFile}"
done
IFS=$OLDIFS
echo
echo "Generated run script: ${scriptName}"
chmod +x $scriptName
