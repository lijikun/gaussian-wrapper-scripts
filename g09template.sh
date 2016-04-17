#!/bin/bash
#
# Batch-generates g09 input files from coordinates and a template
# Usage: g09template.sh template molecule1 [molecule2 ...] [-n number-of-processors] [-s script-file] 

# Default parameters:
scriptName=
nProcs=1
template=
coords=
scriptCommand="g09"

# Processes command line arguments:
while [[ "$1" ]]; do
    case "$1" in
        -s)
            if [[ "$2" ]]; then
                scriptName="$2"
                shift 2
            else
                echo "Warning: No script file name specified."
                shift
            fi;;
        -n)
            isNProcs='^0*[1-9][0-9]*$'
            if [[ "$2" && "$2" =~ $isNProcs ]]; then
                nProcs=$2
                shift 2
            else
                echo "Warning: Invalid number of processors $2."
                shift
            fi;;
        *)
            if [[ -f "$1" ]]; then
                if [[ "$template" ]]; then
                    coords="${coords}"$'\n'"$1" 
                else
                    template="$1"
                fi
            else
                echo "Warning: File $1 does not exist. Ignored."
            fi
            shift;;
    esac
done
[[ $template ]] || { echo "Error: No template file specified."; exit 1; }
[[ $coords ]] || { echo "Error: No molecule coordinate file(s) specified."; exit 1; }
[[ $scriptName ]] || scriptName="g09_$(basename ${template}).sh"


# Generates g09 input files:
echo "#Processors = ${nProcs}"
echo "Template file: ${template}"
echo
[[ -f $scriptName ]] && mv "$scriptName" "${scriptName}.bak"
{ echo '#!/bin/bash'; echo; } > "$scriptName"
echo "Generated input files:"
OLDIFS=$IFS
IFS=$'\n'
for x in $coords; do
    extension='\.\w*$'
    baseName="$(basename $x)"
    if [[ "$baseName" =~ $extension ]]; then
        title="${baseName%${BASH_REMATCH[0]}}"
    else
        title="$baseName"
    fi
    inputFile="${title}_$(basename ${template})"
    [[ -f "${inputFile}" ]] && mv "${inputFile}" "${inputFile}.bak"
    { cat "$template" | while read templateLine; do
        case "$templateLine" in
            !chkfile!)
                echo "%chk=${inputFile}.chk" ;;
            !nprocs!)
                echo "%nprocshared=${nProcs}" ;;
            !title!)
                echo "${inputFile}" ;;
            !coordinates!)
                [[ $discardLine ]] || discardLine='^[0-9]*$'
                cat $x | while read coordLine; do
                    [[ $coordLine =~ $discardLine ]] || echo "${coordLine}"
                done ;;
            *)
                echo "${templateLine}" ;;
        esac
    done; } > "${inputFile}"
    # Adds an empty line to end of file if there isn't one in the template.
    [[ $(tail -n1 "${inputFile}") ]] && echo >> "$inputFile"
    echo "${scriptCommand} \"${inputFile}\"" >> "$scriptName"
    echo "  ${inputFile}"
done
IFS=$OLDIFS
echo
echo "Generated run script: ${scriptName}"
chmod +x "$scriptName"
