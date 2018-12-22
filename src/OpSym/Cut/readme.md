# Cutters and Filters

This document introdues the various classes used for slicing proteins. 
See blow instractions to in order to add new methods of slicing and filtering.
After implementing your Cutter or Filter do the following in ```pdbslicer.py```:
* Change the ```help()``` function
* Insert the name of the class in the global variable ```$cutters_classes```

## Cutters
Cutters are classes which allow us to slice a protein data structure (model) into slices.
For example: Use  the ```ByAmino``` cutter to insert model and to get a list (Cut) of its amino acids data structure.
Each item in this data structure is a list of atoms which represents one amino acid.
An atom is represented by a hash references of the record components of atom line from the PDB file.
```perl
$line= 'ATOM    149  CD1ALEU A  18     -24.795  15.010  15.993  0.50 10.41           C';
$atom_record = $parser->_parse_atom($line);
# Will results:
 {
        'record_name' => 'ATOM',
        'chain_id' => 'A',
        'atom_serial_number' => '149',
        'atom_name' => 'CD1',
        'resname' => 'LEU',
        'altloc' => 'A',
        'resseq' => '18',
        'charge' => '',
        'occupancy' => '0.50',
        'X' => '-24.795',
        'Y' => '15.010',
        'Z' => '15.993',
        'tempfactor' => '10.41',
        'icode' => '',
        'element_symbol' => 'C',
        'line_index' => 'NOT_DEFINED',
        'orig_line' => 'ATOM    149  CD1ALEU A  18     -24.795  15.010  15.993  0.50 10.41           C',
 };

```
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

We have already implemented the following cutters:
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
We implemented the following classes of filters:
* Filter/Aminos.pm
* Filter/RelativeResseq.pm
* Filter/PreProline_Other.pm
* Filter/Resseq.pm

