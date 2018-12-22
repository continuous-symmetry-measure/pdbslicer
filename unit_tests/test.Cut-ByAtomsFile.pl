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
use OpSym::Cut::ByAtomsFile;
use OpSym::Cut::Filter::Aminos;

print " ------------------------------------\n";
print " new PDBslicer object to create peptide \n";
print " ------------------------------------\n";
my $P            =OpSym::PDBslicer->new('pdb_files/single_peptide.pdb');
isa_ok($P,'OpSym::PDBslicer');
$P->set_show_prograss('FALSE');
my $status       = $P->parse_file();
is ($status , 'PARSE_FILE_OK-SINGLE_PEPTIDE',"parse_file: single_peptide.pdb");
is ($P->get_number_of_models,1, "single_peptide.pdb has one model in it");
my $i            =0;
my $model        = $P->get_next_model;
my $ok_peptide   = $P-> get_peptide_by_number($model,1);

print " ------------------------------------\n";
print " new Cut::ByAtomsFile object to create peptide \n";
print " ------------------------------------\n";
my $atoms_file_1='./Cut-ByAtomsFile_files/atoms1.txt';
my $atoms_file_2='./Cut-ByAtomsFile_files/atoms2.txt';

my $C ;
$C    = OpSym::Cut::ByAtomsFile->new($ok_peptide);
isa_ok($C,'OpSym::Cut::ByAtomsFile');

$C->parse_atoms_file($atoms_file_1);
#print $C->get_status();
is ($C->get_status, 'PARSE_ATOMS_FILE_OK', 'parse_atoms_file atoms1.txt');
my $cut = $C->cut();
#Gly:N,  CA  ,C  ,	O
#print "atoms_list".Dumper $cut;
for my $atoms_list (@$cut){
	my $i=0;
	for my $an ('N','CA','C','O'){
		my $atm = $atoms_list->[$i++];
#		print Dumper $atm;
		is ($atm->{atom_name},$an,,"atom_name => $an");
	}
}

print " ------------------------------------\n";
print " new PDBslicer object to create peptide \n";
print " ------------------------------------\n";
undef $P;
undef $C;
undef $model;
$P            =OpSym::PDBslicer->new('pdb_files/one_of_each.pdb');
isa_ok($P,'OpSym::PDBslicer');
$P->set_show_prograss('FALSE');
$status       = $P->parse_file();
is ($status , 'PARSE_FILE_OK-SINGLE_PEPTIDE',"parse_file: one_of_each.pdb");
$model        = $P->get_next_model;
$ok_peptide   = $P-> get_peptide_by_number($model,1);

$C    = OpSym::Cut::ByAtomsFile->new($ok_peptide);
isa_ok($C,'OpSym::Cut::ByAtomsFile');
$C->parse_atoms_file($atoms_file_2);
is ($C->get_status, 'PARSE_ATOMS_FILE_OK', 'parse_atoms_file atoms2.txt');
$cut = $C->cut();
is( scalar (@$cut),20, 'test fo 20 amino acids');
ok ($C->get_status=~/OK/,' NONE status OK');
#for my $atoms_list (@$cut){
#	my $i=0;
#	if (defined $atoms_list->[0] and $atoms_list->[0]->{resname} eq 'ALA'){
#		for my $atm (@$atoms_list){
#			if ($atm->{resname} eq 'ALA'){
#				print "$atm->{orig_line}\n" ;
#				$i++;
#			}
#		
#		}
#		is ($i,12,"atoms  ALL  test");
#	}
#	$i=0;
#	if (defined $atoms_list->[0] and $atoms_list->[0]->{resname} eq 'ARG'){
#		for my $atm (@$atoms_list){
#			if ($atm->{resname} eq 'ARG'){
#				print "$atm->{orig_line}\n";
#				$i++;
#			}
#		}
#		is ($i,0,"atoms  NONE  test");
#	}
#}

#print ref ($C)."\n";
print " ------------------------------------\n";
print " not valid atom filesi\n";
print " ------------------------------------\n";
my $not_valid_atoms_files={
	"Cut-ByAtomsFile_files/atoms_list_not_valid.txt"=>"atom not valid",
	"Cut-ByAtomsFile_files/atoms_duplicate_amino.txt"=>"duplicate amino",
	
};

for my $file (keys %$not_valid_atoms_files){
	undef $C;
	$C    = OpSym::Cut::ByAtomsFile->new($ok_peptide);
	isa_ok($C,'OpSym::Cut::ByAtomsFile');
	$C->parse_atoms_file($file);
	my $expected_status = $not_valid_atoms_files->{$file};
	ok ($C->get_status=~/$expected_status/, "$file=~/$expected_status/");
}


done_testing()
__END__

