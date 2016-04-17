Gaussian 09 wrapper Bash scripts.


## g09template.sh

Converts a batch of molecular definition files [e.g. xyz coordinates or z-matrix] to g09 input files, according to a template specified by the user. 

Also generates a script file to run all the calculations.

Usage:

        ./g09template.sh template molecule1 [molecule2 ...] [-n number-of-processors] [-s script-file-name] 

See [`template-sample-opt.gjf`](template-sample-opt.gjf) for a sample template. Basically, the template defines the model chemistry, basis sets, optimization, etc., that you want to apply to all the molecules.

How to write a template:

 1. Write a file as if it's a normal g09 input file.

 2. Put `!chkfile!` for the line that specifies the checkpoint file name.

 3. Put `!nprocs!` for the line with number of CPUs.

 4. Put `!title!` for a copy of the file name.

 5. Put `!coordinates!` where the molecule definition should be.
 
 6. You can put the line for charge, multiplicity, fragments, etc., in either the template or the molecule files.
 

For example, supposing you have in current directory the script, the template, as well as 3 molecule files `mol-a.xyz`, `mol-b.xyz` and `mol-c.zmat`, which are generated by [Avogadro](http://avogadro.cc) or Chem3D), you can run:

        ./g09template.sh template-sample-opt.gjf mol* -n 8
        
        
And it will generate files automatically named like `mol-a_template-sample-opt.gjf`. The checkpoint files will be named accordingly. The script file is unspecified so it will be automatically named `g09_template-sample-opt.gjf.sh`, and made executable.


## g09run.sh

Runs a g09 calculation, and emails the last 10 lines of log when finished.

Usage:

        ./g09run.sh input-file [email-address]
