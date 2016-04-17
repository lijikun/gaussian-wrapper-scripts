Gaussian 09 wrapper Bash scripts.


## g09template.sh

Converts a batch of molecular definition files [e.g. xyz coordinates or z-matrix] to g09 input files, according to a template specified by the user. 

Also generates a script file to run all the calculations.

Usage:

        ./g09template.sh template molecule1 [molecule2 ...] [-n number-of-processors] [-s script-file-name] 

How to write a template:

 1. Write a file as if it's a normal g09 input file.

 2. Put `!chkfile!` for the line that specifies the checkpoint file name.

 3. Put `!nprocs!` for the line with number of CPUs.

 4. Put `!title!` for the comment line.

 5. Put `!coordinates!` where the molecule definition should be.
 
 6. You can put the line for charge and multiplicity (fragment charge/multiplicity, too) in either (but not both)
 
    * The template (if every molecule has the same charge and multiplicity), or 
        
    * The molecule definition files (if there are differenct charges, etc. among molecules)

See [`g09template-sample-opt.gjf`](g09template-sample-opt.gjf) for a sample template. You can use it like this (supposing you have `a.xyz`, `b.xyz` and `c.xyz`):

        ./g09template.sh g09template-sample-opt.gjf *.xyz -s run-opt.sh -n 8

Basically, the template defines the model chemistry, basis sets, optimization, etc., that you want to apply to all the molecules, and the molecules' atomic coordinates are defined in respective files.


What it does:

 1. For each molecule file, creates a g09 input file according to the template, automatically named as `molecule_template`.
 
 2. Does the replacements 2-4 above. Will do multiple replacements if a `!...!` string appears more than once. 
 
 3. Reads in the definition, getting rid of empty lines and lines with only one number.
 
 4. Replaces `!coordinates!` with the real molecule definition.
 
 5. Add an empty line to the end of each input file if it doesn't have one.
 
 6. Generates a Bash script for running g09 with all the input files generated. Makes it executable.
 



## g09run.sh

Runs a g09 calculation, and emails the last 10 lines of log when finished.

Usage:

        ./g09run.sh input-file [email-address]
