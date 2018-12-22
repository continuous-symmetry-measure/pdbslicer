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
use OpSym::Cut::ByAmino;
use OpSym::Cut::Filter::Aminos;
use OpSym::Cut::Filter::Resseq;
use OpSym::Cut::Filter::RelativeResseq;
my ($P,$C,$status,$amino_list,$i);
my ($model,$ok_peptide,$reseqs_list,$filters);

print " ------------------------------------\n";
print " new PDBslicer object to create peptide \n";
print " ------------------------------------\n";
$P            =OpSym::PDBslicer->new('pdb_files/single_peptide.pdb');
#$P->parse_peptide_lines();
isa_ok($P,'OpSym::PDBslicer');
$status       = $P->parse_file();
is ($status , 'PARSE_FILE_OK-SINGLE_PEPTIDE',"parse_file: single_peptide.pdb");
is ($P->get_number_of_models,1, "single_peptide.pdb has one model in it");
$i            =0;
$model        = $P->get_next_model;
$ok_peptide   = $P-> get_peptide_by_number($model,1);
my $gaps=($P->pdb_stracture_has_gaps() ? 'has_gaps':'no_gaps');
is $gaps,'no_gaps' , "no gaps in pdb struct";
print $P->gaps_report_text() if $P->pdb_stracture_has_gaps();

print " ------------------------------------\n";
print " new Cut::ByAmino object to create peptide \n";
print " ------------------------------------\n";
$C = OpSym::Cut::ByAmino->new($ok_peptide);
isa_ok($C,'OpSym::Cut::ByAmino');
$amino_list = $C->cut();

is (scalar (@$amino_list), 1, "we have 1 aminos in the list");

for my $cut (@$amino_list){ 
	
	print 	"-----\n". $P->atoms_list2xyz($cut);
}
undef $C;
undef $amino_list ;

print " ------------------------------------\n";
print " new Cut::ByAmino object to create peptide  but this time filtered using Filter::Aminos\n";
print " ------------------------------------\n";
$filters = [OpSym::Cut::Filter::Aminos->new('GLU')];
$C = OpSym::Cut::ByAmino->new($ok_peptide,$filters); # we have only GLY so will return empty list
isa_ok($C,'OpSym::Cut::ByAmino');
$amino_list = $C->cut();
is (scalar (@$amino_list), 0, "we have 0 aminos in the list");
undef $C;
undef $amino_list ;

print " ------------------------------------\n";
print " new Cut::ByAmino object to create peptide  but this time filtered using Filter::Aminos\n";
print " ------------------------------------\n";
$filters = [OpSym::Cut::Filter::Aminos->new('GLY')];
$C = OpSym::Cut::ByAmino->new($ok_peptide,$filters); 
isa_ok($C,'OpSym::Cut::ByAmino');
$amino_list = $C->cut();

is (scalar (@$amino_list), 1, "we have 1 aminos in the list");
for my $cut (@$amino_list){ 
	
	print 	"-----\n". $P->atoms_list2xyz($cut);
}

print " ------------------------------------\n";
print " new Cut::ByAmino object to create peptide  but this time filtered using Filter::Resseqs\n";
print " ------------------------------------\n";
$reseqs_list=[2,3];
$filters = [OpSym::Cut::Filter::Resseq->new($reseqs_list)];
$C = OpSym::Cut::ByAmino->new($ok_peptide,$filters); # we have only GLY so will return empty list
#print Dumper $ok_peptide;
isa_ok($C,'OpSym::Cut::ByAmino');
$amino_list = $C->cut();
#print Dumper $amino_list;
is (scalar (@$amino_list), 1, "we have 1 reseqs_list in the list");
undef $C;
undef $amino_list ;



print " ------------------------------------\n";
print " new Cut::ByAmino object to create peptide  but this time filtered using Filter::Resseqs\n";
print " and create full pdb file from results\n";
print " ------------------------------------\n";


$P            =OpSym::PDBslicer->new('pdb_files/two_peptides_no_model.pdb');
isa_ok($P,'OpSym::PDBslicer');
$status       = $P->parse_file();
is ($status , 'PARSE_FILE_OK-MULTY_PEPTIDE',"parse_file: two_peptides_no_model.pdb");
is (    $P->{pdb}->[0]     ,'MODEL_No_ZERO_NOT_EXISTS',"{pdb}->[0],'MODEL_No_ZERO_NOT_EXISTS'");
is (ref $P->{pdb}->[1]     ,'ARRAY', "{pdb}->[1] is an array( first model)");
$model=$P->get_next_model();
is (    $model->[0],'ZERO_PEPTIDE_NOT_EXISTS',"modle->[0] 'ZERO_PEPTIDE_NOT_EXISTS'");
is (ref $model->[1],'ARRAY', "model->[1] is an array( first peptide )");
is (ref $model->[2],'ARRAY', "model->[2] is an array( second peptide)");
is ($P->get_number_of_models,1, "two_peptides.pdb has one model in it");
is ($P->get_number_of_peptides($model),2, "two_peptides.pdb has two peptide in it");
$i            =0;

print "\n";
undef $ok_peptide;
$reseqs_list=[2,3];
$filters = [OpSym::Cut::Filter::RelativeResseq->new($reseqs_list)];
my $peptides_list =[];
$peptides_list=['ZERO_PEPTIDE_NOT_EXISTS'];
done_testing();
exit;
1;
__END__


for my $pep_i (1..$P->get_number_of_peptides($model)){
	print "\n................peptide number $pep_i ...................\n";	
	$ok_peptide   = $P->get_peptide_by_number($model,$pep_i);
	is ($ok_peptide->[0],'ZERO_ATOM_NOT_EXISTS',"pepetide->[0] ZERO_ATOM_NOT_EXISTS (peptide No. $pep_i)");
	is (ref $ok_peptide->[1],'HASH',"pepetide->[1] is hash (peptide No. $pep_i");

	$C = OpSym::Cut::ByAmino->new($ok_peptide,$filters); 
	isa_ok($C,'OpSym::Cut::ByAmino');
	print Dumper $ok_peptide;
	$amino_list = $C->cut();
	print Dumper $amino_list;
	is (scalar (@$amino_list), 2, "we have 2 reseqs_list in the list");
#
#print ref $amino_list;
#print scalar @{$amino_list->[0]};
#print scalar @{$amino_list->[1]};
#print Dumper $amino_list->[1];
#exit;
##	my $cut_peptide= $C->get_peptide();
	my $cut_peptide= ['ZERO_ATOM_NOT_EXISTS'];
	for my $atom_list (@$amino_list){
		push @$cut_peptide,@$atom_list;

		is ($cut_peptide->[0],'ZERO_ATOM_NOT_EXISTS',"pepetide->[0] ZERO_ATOM_NOT_EXISTS (peptide No. $pep_i)");
		is (ref $cut_peptide->[1],'HASH',"pepetide->[1] is hash (peptide No. $pep_i");
	}
	push @$peptides_list,$cut_peptide;
}

#print Dumper $peptides_list;
print " ---------\n".$P->peptides_list2pdb($peptides_list);
undef $ok_peptide;
done_testing();
exit;
1;
__END__



