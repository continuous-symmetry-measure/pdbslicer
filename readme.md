# pdbslicer
PDB files contain information about protein structure. This software bisects the protein into subunits in order to analyze the properties of its fragments. 
The following type of subunits are defined:
1. Amino acid - includes all the atoms of a given residue
2. Ramachandran subunit –for amino acid #i includes the atoms: C(i-1)-N(i)-CA(i)-C(i)-N(i+1)
3. User defined subunit - with an external atoms.txt file (see format below)
4. Amino acid backbone – includes the atoms N-CA-C-O
5. Ramachandran with side chain - for amino acid #i includes the atoms: C(i-1)-N(i)-CA(i)-C(i)-N(i+1), the backbone atoms and all the atoms of the side chain
6. Ramachandran with side chain and without the backbone oxygen – similar to subunit 5, without the backbone oxygen

Please see below how to create new types of subunits.

## Publications
1. Y. Baruch-Shpigler, H. Wang, I. Tuvi-Arad and D. Avnir, [Chiral Ramachandran plots I: Glycine, Biochemistry](http://pubs.acs.org/doi/abs/10.1021/acs.biochem.7b00525), 56, 5635-5643 (2017).
2. H. Wang, D. Avnir and I. Tuvi-Arad, [Chiral Ramachandran Plots II: General trends and proteins chirality spectra, Biochemistry](https://pubs.acs.org/doi/10.1021/acs.biochem.8b00974) ([in press, DOI: 10.1021/acs.biochem.8b00974](https://pubs.acs.org/doi/10.1021/acs.biochem.8b00974)).  

## How to use the software
``` perl
pdbslicer -
        Cut a protein pdb file into subunits.
Version: 0.9.5.3
Usage:
        pdbslicer  [-o OUTPUT_FILE] [-v ][ -R RANGE ] [-O output_dir]  [-M RESNAME] [-C CUTTING METHOD] [-P FILTER] [-A RANGE]
        pdbslicer -h

Parameters:
        -h      Get this help
        -i      Input pdb file     [default is input.pdb]
        -O      Output directory name
        -C      Cutting method:
                        1=cut by amino acid,
                        2=cut by Ramachandran backbone
                        3=cut with external "atoms.txt" file. Requires  the -a option.
                        4=cut by amino acid backbone N|CA|C|O atoms
                        5=cut by Ramachandran with side chain
                        6=cut by Ramachandran with side chain no oxygen
        -a      Cut specific atoms of each amino acid. An atoms.txt file should be specified.
        -R      Model range (1-10,12,14)
        -M r    Filter by residue name (example: -M GLY)
        -P      Filter PreProline and Other. Valid values for this parmaeter:
                        "GENERAL", "PRE_PRO", "GLY", "PRO" or any combination such as "GENERAL|PRE_PRO"
        -A a-b  Filter by residue sequance number (example: -A 2-8)
        -J      Do not add time signature to the output directory
        -G a-b  Create a new PDB file with amino acids a-b. The new  file name: old.a-b.pdb
        -L      Number of subunits in the output files default is  100
        -v      Verbose output


```


## Cutting with "atoms.txt" file
Eech line of the  atoms.txt represnts one amino acid.
The file must have 20 lines - one for each amino acid.
The line structure is "residue name" then ':' and the chosen atoms  seperated by comma.
If no atoms are chosen then after the ':' will come the string 'NONE'
Here is an example of such a file:
```

Ala:  N,CA,C,O,CB
Arg:  ALL ATOMS
Asn:  N,CA,C,O,CB
Asp:  N,CA,C,O,CB
Cys:  N,CA,C,O,CB
Glu:  N,CA,C,O,CB
Gln:  N,CA,C,O,CB
Gly:  N,CA,C,O
His:  N,CA,C,O,CB
Ile:  N,CA,C,O,CB
Leu:  N,CA,C,O,CB
Lys:  N,CA,C,O,CB
Met:  N,CA,C,O,CB
Phe:  N,CA,C,O,CB
Pro:  N,CA,C,O,CB
Ser:  N,CA,C,O,CB
Thr:  N,CA,C,O,CB
Trp:  N,CA,C,O,CB
Tyr:  N,CA,C,O,CB
Val:  N,CA,C,O,CB

```

# output files
The output is in the directory "out_{PDB_NAME}{timestring}"
This directory contains:

       * cmd_string.txt            - the command as typed by the user
       * output files              - files names are indexed by serial-number + model + peptide-name



## create your own cut 

Data Structures:
```
pdb object contain one or more models - each model represents protein...
protein is a list of  peptides
  peptide is a list of atoms
    atom has properties such as: X, Y, Z, name, resname, resseq  ...

```
[Read here to learn how](./src/OpSym/Cut/readme.md)


