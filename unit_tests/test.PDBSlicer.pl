#!/opt/lperl/bin/perl   
BEGIN
{	
	push @INC,'../src';
}
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;
use OpSym::Conf;
use Test::More;
use OpSym::PDBslicer;
my $P;
my $nom;
my $status;
my $i;

print " ------------------------------------\n";
print "  with_connect.pdb\n";
print " ------------------------------------\n";
undef $P;
$P=OpSym::PDBslicer->new('pdb_files/with_connect.pdb');
$P->set_parse_also_hetatm('Y');
$status= $P->parse_file();
is ($status , 'PARSE_FILE_OK-SINGLE_PEPTIDE-END_OF_MODEL_OK-MULTY_MODELS',"parse_file: with_connect.pdb");
$nom=$P->get_number_of_models;
is ($nom,3, "with_connect.pdb has $nom  models in it");
$P->validate_pdb_stracture();
is ($P->{connect}->[1]->[0], 'CONECT    1    4    5    3    2                                                 ', "connect test");



#print " ------------------------------------\n";
#print " two_peptides_no_model.pdb\n";
#print " ------------------------------------\n";
#undef $P;
#$P=OpSym::PDBslicer->new('pdb_files/two_peptides_no_model.pdb');
#$status= $P->parse_file();
#ok ($status =~ m'PARSE_FILE_OK-SINGLE_PEPTIDE',"parse_file: two_peptides_no_model.pdb");
#$nom=$P->get_number_of_models;
#is ($nom,1, "two_peptides_no_model.pdb has $nom model in it");
#$Data::Dumper::Maxrecurse=2;
#$Data::Dumper::Maxdepth =2;
#
#$i=0;
#while (my $model=$P->get_next_model()){
#	is ($P->get_number_of_peptides($model,1),2, "two_peptides_no_model.pdb first  model has two peptide in it");
#	my $peptide = $P-> get_peptide_by_number($model,1);
#	print " === peptide 1 ===\n";
#	print $P->atoms_list2pdb($peptide);
#	print " === peptide 1 END===\n";
#	$peptide = $P-> get_peptide_by_number($model,2);
#	print " === peptide 2 ===\n";
#	print $P->atoms_list2pdb($peptide);
#	print " === peptide 2 END===\n";
#
#	is $P->get_ter_line($model->[1]), 'TER      25      GLY     3',"get_ter_line";
#	
#}
#
#exit;
print " ------------------------------------\n";
print " new object\n";
print " ------------------------------------\n";
$P=OpSym::PDBslicer->new('pdb_files/single_peptide.pdb');
#$P->parse_peptide_lines();
isa_ok($P,'OpSym::PDBslicer');

print " ------------------------------------\n";
print " parse line\n";
print " ------------------------------------\n";
my $line;
#### OK line
$line='ATOM      1  N   GLY     1      -1.104  -0.267  -0.062  1.00  0.00           N1+';
$P->_parse_atom($line);
is ($P->get_status , '_PARSE_ATOM_OK',"_parse_atom:".$P->get_status);

$line='ATOM      X  N   GLY     1      -1.104  -0.267  -0.062  1.00  0.00           N1+';
$P->_parse_atom($line);
ok ($P->get_status ne '_PARSE_ATOM_OK',"_parse_atom:".$P->get_status);


$line='ATOM      1  N   XXX     1      -1.104  -0.267  -0.062  1.00  0.00           N1+';
$P->_parse_atom($line);
ok ($P->get_status ne '_PARSE_ATOM_OK',"_parse_atom:".$P->get_status);

$line='ATOM      1  N   GLY     X      -1.104  -0.267  -0.062  1.00  0.00           N1+';
$P->_parse_atom($line);
ok ($P->get_status ne '_PARSE_ATOM_OK',"_parse_atom:".$P->get_status);

$line='ATOM      1  N   GLY            -1.104  -0.267  -0.062  1.00  0.00           N1+';
$P->_parse_atom($line);
ok ($P->get_status ne '_PARSE_ATOM_OK',"_parse_atom:".$P->get_status);



$line= 'ATOM    149  CD1ALEU A  18     -24.795  15.010  15.993  0.50 10.41           C';
my $atom_record = $P->_parse_atom($line);
#print "line='$line'\n";
ok ($P->get_status eq '_PARSE_ATOM_OK',"_parse_atom:".$P->get_status);
my $rec_data = {   
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
for my $k ( keys %$rec_data){
	is $atom_record->{$k},$rec_data->{$k},"_parse_atom test: $k is $rec_data->{$k}"
}

#print Dumper $P->_parse_atom($line);



$line='ATOM      1  N   GLY     ';
$P->_parse_atom($line);
ok ($P->get_status ne '_PARSE_ATOM_OK',"_parse_atom:".$P->get_status);




print " ------------------------------------\n";
print "  single_peptide.pdb\n";
print " ------------------------------------\n";
undef $P;
$P=OpSym::PDBslicer->new('pdb_files/single_peptide.pdb');
$status= $P->parse_file();
ok ($status=~m'PARSE_FILE_OK-SINGLE_PEPTIDE',"parse_file: single_peptide.pdb - $status");
$nom=$P->get_number_of_models;
is ($nom,1, "single_peptide.pdb has one model in it");
$i=0;
while (my $model=$P->get_next_model()){
	is ($P->get_number_of_peptides($model),1, "single_peptide.pdb first  model has one peptide in it");
	is $P->get_ter_line($model->[1]), 'TER      25      GLY     3',"get_ter_line";
	
}

print " ------------------------------------\n";
print " two_peptides_no_model.pdb\n";
print " ------------------------------------\n";
undef $P;
$P=OpSym::PDBslicer->new('pdb_files/two_peptides_no_model.pdb');
$status= $P->parse_file();
ok ($status =~ m'PARSE_FILE_OK-MULTY_PEPTIDE',"parse_file: two_peptides_no_model.pdb");
$nom=$P->get_number_of_models;
is ($nom,1, "two_peptides_no_model.pdb has $nom model in it");


$i=0;
while (my $model=$P->get_next_model()){
	is ($P->get_number_of_peptides($model,1),2, "two_peptides_no_model.pdb first  model has two peptide in it");
	my $peptide = $P-> get_peptide_by_number($model,1);
	print " === peptide 1 ===\n";
	print $P->atoms_list2pdb($peptide);
	print " === peptide 1 END===\n";
	$peptide = $P-> get_peptide_by_number($model,2);
	print " === peptide 2 ===\n";
	print $P->atoms_list2pdb($peptide);
	print " === peptide 2 END===\n";

	is $P->get_ter_line($model->[1]), 'TER      25      GLY     3',"get_ter_line";
	
}


print " ------------------------------------\n";
print "  two_model_peptides.pdb\n";
print " ------------------------------------\n";
undef $P;
$P=OpSym::PDBslicer->new('pdb_files/two_model_peptides.pdb');
$status= $P->parse_file();
is ($status , 'PARSE_FILE_OK-SINGLE_PEPTIDE-END_OF_MODEL_OK-MULTY_MODELS',"parse_file: two_model_peptides.pdb");
$nom=$P->get_number_of_models;
is ($nom,2, "two_model_peptides.pdb has $nom  models in it");
$P->validate_pdb_stracture();


$i=0;
while (my $model=$P->get_next_model()){
	$i++;
	print " === Model No $i ===\n";
	is ($P->get_number_of_peptides($model),1, "two_model_peptides.pdb  model No. $i  has one peptide in it");
	is $P->get_ter_line($model->[1]), 'TER      25      GLY     3',"get_ter_line";
	#print Dumper $model;
	
}

print " ------------------------------------\n";
print "  1N6V.pdb\n";
print " ------------------------------------\n";
undef $P;
$P=OpSym::PDBslicer->new('pdb_files/1N6V.pdb');
$status= $P->parse_file();
ok($status =~/PARSE_FILE_OK/,"parse_file: 1HFF.pdb");
is ($P->get_number_of_models,1,"1N6V.pdb has 1 models in it");
my $model= $P->get_next_model;
my $peptide = $P-> get_peptide_by_number($model,1);

my $atom=$peptide->[794];
is($atom->{rama_type} , 'PRE_PRO', "test PRE_PRO");

$atom=$peptide->[800];
is($atom->{rama_type} , 'PRO', "test PRO");

$atom=$peptide->[815];
is($atom->{rama_type} , 'OTHER', "test OTHER");

$atom=$peptide->[1362];
is($atom->{rama_type} ,'GLY', "test GLY");



write_file '/tmp/1.pdb',$P->atoms_list2pdb($peptide);
$P->validate_pdb_stracture();



print " ------------------------------------\n";
print "  1HFF.pdb\n";
print " ------------------------------------\n";
undef $P;
$P=OpSym::PDBslicer->new('pdb_files/1HFF.pdb');
$status= $P->parse_file();
is ($status , 'PARSE_FILE_OK-SINGLE_PEPTIDE-END_OF_MODEL_OK-MULTY_MODELS',"parse_file: 1HFF.pdb");
is ($P->get_number_of_models,55, "1HFF.pdb has 55 models in it");
my $model= $P->get_next_model;
my $peptide = $P-> get_peptide_by_number($model,1);
#print Dumper $peptide;
write_file '/tmp/1.pdb',$P->atoms_list2pdb($peptide);
$P->validate_pdb_stracture();



print " ------------------------------------\n";
print "  1xy1.pdb\n";
print " ------------------------------------\n";
undef $P;
$P=OpSym::PDBslicer->new('pdb_files/1xy1.pdb');
$status= $P->parse_file();
is ($status , 'PARSE_FILE_OK-MULTY_PEPTIDE',"parse_file: 1xy1.pdb");
is ($P->get_number_of_models,1, "1xy1.pdb has 1 models in it");
$model= $P->get_next_model;
is ($P->get_number_of_peptides($model,1),2, "1xy1.pdb first  model has two peptide in it");
$peptide = $P-> get_peptide_by_number($model,1);
#print Dumper $peptide;
write_file '/tmp/1.pdb',$P->atoms_list2pdb($peptide);
$P->validate_pdb_stracture();
print $P->gaps_report_text();


for my $gap_file ( glob "pdb_files/sequence_gaps/*pdb"){
	print " ------------------------------------\n";
	print "  $gap_file\n";
	print " ------------------------------------\n";
	undef $P;
	$P=OpSym::PDBslicer->new($gap_file);
	$P->set_warn_on_alidation_error('OFF');
	$status= $P->parse_file();
	ok ($status=~'PARSE_FILE_OK',"parse_file: $gap_file");
	ok $P->pdb_stracture_has_gaps(), "pdb_stracture_has_gaps";
	print $P->gaps_report_text() if $P->pdb_stracture_has_gaps();
}	

done_testing();

