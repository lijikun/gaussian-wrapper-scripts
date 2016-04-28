#!/bin/bash
#
# Batch-generates g09 input files from coordinates and a template
# Usage: g09template.sh template molecule1 [molecule2 ...] [-n number-of-processors] [-s script-file] 

# Default parameters:
scriptName=
nProcs=1
template=
coords=()
scriptCommand="g09"

# Processes command line arguments:
while [[ "$1" ]]; do
    case "$1" in
        -s)
            if [[ "$2" ]]; then
                scriptName="$2"
                shift 2
            else
                echo "Warning: No script file name specified." >&2
                shift
            fi;;
        -n)
            isNProcs='^0*[1-9][0-9]*$'
            if [[ "$2" && "$2" =~ $isNProcs ]]; then
                nProcs=$2
                shift 2
            else
                echo "Warning: Invalid number of processors $2." >&2
                shift
            fi;;
        *)
            if [[ -f "$1" ]]; then
                if [[ "$template" ]]; then
                    coords+=("$1") 
                else
                    template="$1"
                fi
            else
                echo "Warning: File $1 does not exist. Ignored." >&2
            fi
            shift;;
    esac
done
[[ $template ]] || { echo "Error: No template file specified." >&2 ; exit 1; }
templateBase="$(basename ${template})"
[[ $coords ]] || { echo "Error: No molecule coordinate file(s) specified." >&2 ; exit 1; }
[[ $scriptName ]] || scriptName="g09_${templateBase}.sh"


# Generates g09 input files:
echo "#Processors = ${nProcs}"
echo "Template file: ${template}"
echo
[[ -e $scriptName ]] && mv "$scriptName" "${scriptName}.bak"
{ echo '#!/bin/bash'; echo; } > "$scriptName"
echo "Generated input files:"
for x in "${coords[@]}"; do
    baseName="$(basename ${x})"
    inputFile="${baseName}_${templateBase}"
    [[ -e "${inputFile}" ]] && mv "${inputFile}" "${inputFile}.bak"
    { cat "$template" | while read templateLine; do
        case "$templateLine" in
            !chkfile!)
                echo "%chk=\"${inputFile}.chk\"" ;;
            !nprocs!)
                echo "%nprocshared=${nProcs}" ;;
            !title!)
                echo "${inputFile}" ;;
            !coordinates!)
                # First deletes all lines with a single number.
                # Then deletes all empty lines at the beginning and the end.
                sed "${x}" \
                    -e '/^[[:space:]]*[0-9]\+[[:space:]]*$/d' \
                    -e '/[[:alnum:]]/,$!d' \
                    | tac \
                    | sed -e '/[[:alnum:]]/,$!d' \
                    | tac
                ;;
            *)
                echo "${templateLine}" ;;
        esac
    done; } > "${inputFile}"
    # Adds an empty line to end of file if there isn't one in the template.
    [[ $(tail -n1 "${inputFile}") ]] && echo >> "$inputFile"
    echo "${scriptCommand} \"${inputFile}\"" >> "$scriptName"
    echo "  ${inputFile}"
done
echo
echo "Generated run script: ${scriptName}"
chmod +x "$scriptName"
