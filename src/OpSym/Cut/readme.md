# Cutters and Filters

This document indrodue the various classes used for slicing proteins. 
Read this document in if you want to understand how to implement additional class (in order to add to pdb slicer other method of slicing and filtering).
After implementing your Cutter or Filter do th following in ```pdbslicer.py```:
* Change the ```help()``` function in 
* Insert the name of the class in the global variable ```$cutters_classes```

## Cutters
Cutters are classes which alow us to slice a protoein data structure (model) into slices.
for example: Use  the ```ByAmino``` cutter to insert model and to get a list (Cut) of it amno acids data structure.
each item in this data structure is a list atoms which represents one amino acid.
an atom is represented by q hash referaces of the record componanats of atom line from the pdb file.

### Cut.pm
This is the parent class of each Cut sub class
Implements the following methods:
* dbg - print debug info
* new - constructior 
* get_status  
* get_peptide  - a peptide is a list of atoms and an atom is a hash of atom record
* get_curr_index 
* filter  filters atoms/aminos from the protein slices
* remove_gap_edges 
* cut  - preforms the cut - *overide this method for your own cut*
* cut2pdb returns the current cut as pdb string

### Implemented Cutters

we have already implemented this cutters:
* ByAtomsFile.pm
* ByAmino.pm
* ByAmino_N_CA_C_O.pm
* ByRamachandran.pm
	* ByRamachandran_with_side_chain.pm
	* ByRamachandran_with_side_chain_no_oxygen.pm

## Filters 
TODO

### Filter.pm
This is the parent class of each filter sub class
Implements the following methods:
TODO
 
### Implemented Filter
We implented the folllowing classes of filters:
* Filter/Aminos.pm
* Filter/RelativeResseq.pm
* Filter/PreProline_Other.pm
* Filter/Resseq.pm

