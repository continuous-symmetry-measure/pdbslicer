# unittests  for pdbslicer
cd into the unittests directory and then run each unittest file.
## Example

```
[user@csm_server unit_tests]$ ./test.Cut-ByAmino.pl
 ------------------------------------
 new PDBslicer object to create peptide
 ------------------------------------
ok 1 - The object isa OpSym::PDBslicer
parsing file progress: 100.00%
ok 2 - parse_file: single_peptide.pdb
ok 3 - single_peptide.pdb has one model in it
ok 4 - no gaps in pdb struct
 ------------------------------------
 new Cut::ByAmino object to create peptide
 ------------------------------------
ok 5 - The object isa OpSym::Cut::ByAmino
ok 6 - we have 1 aminos in the list
-----
6
#
C        3.674    -0.160    -0.222
C        4.711     0.684     0.027
O        4.510     1.838     0.434
H        2.354     1.437     0.384
H        3.809    -1.046     0.397
H        3.738    -0.441    -1.272
 ------------------------------------
 new Cut::ByAmino object to create peptide  but this time filtered using Filter::Aminos
 ------------------------------------
ok 7 - The object isa OpSym::Cut::ByAmino
ok 8 - we have 0 aminos in the list
 ------------------------------------
 new Cut::ByAmino object to create peptide  but this time filtered using Filter::Aminos
 ------------------------------------
ok 9 - The object isa OpSym::Cut::ByAmino
ok 10 - we have 1 aminos in the list
-----
6
#
C        3.674    -0.160    -0.222
C        4.711     0.684     0.027
O        4.510     1.838     0.434
H        2.354     1.437     0.384
H        3.809    -1.046     0.397
H        3.738    -0.441    -1.272
 ------------------------------------
 new Cut::ByAmino object to create peptide  but this time filtered using Filter::Resseqs
 ------------------------------------
ok 11 - The object isa OpSym::Cut::ByAmino
ok 12 - we have 1 reseqs_list in the list
 ------------------------------------
 new Cut::ByAmino object to create peptide  but this time filtered using Filter::Resseqs
 and create full pdb file from results
 ------------------------------------
ok 13 - The object isa OpSym::PDBslicer
parsing file progress: 100.00%
ok 14 - parse_file: two_peptides_no_model.pdb
ok 15 - {pdb}->[0],'MODEL_No_ZERO_NOT_EXISTS'
ok 16 - {pdb}->[1] is an array( first model)
ok 17 - modle->[0] 'ZERO_PEPTIDE_NOT_EXISTS'
ok 18 - model->[1] is an array( first peptide )
ok 19 - model->[2] is an array( second peptide)
ok 20 - two_peptides.pdb has one model in it
ok 21 - two_peptides.pdb has two peptide in it

1..21

```
