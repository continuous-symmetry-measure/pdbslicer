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
use OpSym::Cut::ByRamachandran;
use OpSym::Cut::Filter::Aminos;

my $class='OpSym::PDBslicer';
my $filters;
print " ------------------------------------\n";
print " new PDBslicer object to create peptide \n";
print " ------------------------------------\n";
#my $P            =OpSym::PDBslicer->new('pdb_files/single_peptide.pdb');
my $P            =$class->new('pdb_files/single_peptide.pdb');
#$P->parse_peptide_lines();
isa_ok($P,$class);
my $status       = $P->parse_file();
ok ($status=~m'PARSE_FILE_OK-SINGLE_PEPTIDE',"parse_file: single_peptide.pdb - $status");
is ($P->get_number_of_models,1, "single_peptide.pdb has one model in it");
my $i            =0;
my $model        = $P->get_next_model;
my $ok_peptide   = $P-> get_peptide_by_number($model,1);

print " ------------------------------------\n";
print " new Cut::ByRamachandran object  \n";
print " ------------------------------------\n";
my $cut='OpSym::Cut::ByRamachandran';
my $C = $cut->new($ok_peptide);
#my $C = OpSym::Cut::ByRamachandran->new($ok_peptide);
isa_ok($C,$cut);

print " ------------------------------------\n";
print " test Cut::ByRamachandran->cut of single_peptide.pdb\n";
print " ------------------------------------\n";
my $ramachandran_list  = $C->cut();
ok $C->get_status()=~/OK/,$C->get_status();
my $atom_list = $ramachandran_list->[0];
is (scalar (@$atom_list), 5, "we have 5 aminos in the list");
#print $C->cut2pdb();


print " ------------------------------------\n";
print " test Cut::ByRamachandran->cut of 1HFF.pdb\n";
print " ------------------------------------\n";
$P           = undef;
$model       = undef;
$ok_peptide  = undef;
$C           = undef;  
$atom_list   = undef;
$P          = OpSym::PDBslicer->new('pdb_files/1HFF.pdb');
$status     = $P->parse_file();
$model      = $P->get_next_model;
$ok_peptide = $P-> get_peptide_by_number($model,1);
$C          = OpSym::Cut::ByRamachandran->new($ok_peptide);


$ramachandran_list  = $C->cut();
ok $C->get_status()=~/OK/,$C->get_status();
#print Dumper $ramachandran_list;
#for my $cut (@$ramachandran_list){ 
#	print 	"-----\n". $P->atoms_list2xyz($cut);
#}

print " ------------------------------------\n";
print " test Cut::ByRamachandran->cut of 1HFF.pdb - filter ASP\n";
print " ------------------------------------\n";
$filters = [OpSym::Cut::Filter::Aminos->new('ASP')];
$C          = OpSym::Cut::ByRamachandran->new($ok_peptide,$filters);
ok $C->get_status()=~/OK/,$C->get_status();
$ramachandran_list  = $C->cut();
#print Dumper $ramachandran_list;
for my $cut (@$ramachandran_list){ 
	print 	"-----\n". $P->atoms_list2xyz($cut);
}

print " ------------------------------------\n";
print " test Cut::ByRamachandran->cut of 1HFF.pdb - filter GLU\n";
print " ------------------------------------\n";
$filters = [OpSym::Cut::Filter::Aminos->new('GLU')];
$C          = OpSym::Cut::ByRamachandran->new($ok_peptide,$filters);
$ramachandran_list  = $C->cut();
ok $C->get_status()=~/OK/,$C->get_status();
print Dumper $ramachandran_list;
for my $cut (@$ramachandran_list){ 
	print 	"-----\n". $P->atoms_list2xyz($cut);
}



done_testing();

