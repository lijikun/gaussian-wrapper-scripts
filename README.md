Gaussian 09 wrapper Bash scripts.

## g09run.sh

Runs a g09 calculation, and emails the last 10 lines of log when finished.

Usage:

        ./g09run.sh input-file [email-address]

## coord2input.sh

Converts a batch of molecular definition coordinates (xyz or zmat) to g09 input files, according to a template file specified. 

Also generates a script file to run all the calculations.

Usage:

        ./coord2input.sh template coordinates1 [coordinates2 ...] [-n number-of-processors] [-s script-file-name] [-c charge] [-m multiplicity] 

How to write a template:

 1. Write a normal g09 input file with specifications you want.

 2. Replace checkpoint file definition with `!chkfile!`

 3. Replace number of processors with `!nprocs!`

 4. Replace comment line with `!title!`

 5. Replace charge, multiplicity and molecule definition with `!coordinates!`

See `coord2input-sample-template.gjf` for a sample.
