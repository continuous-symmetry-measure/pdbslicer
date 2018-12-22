#
#=================================================================================
#
#         FILE:  AminoAcid
#  DESCRIPTION:  File parser object for the pdb files - but not acomplete pdb parser - 
#                just for amino  acids
#                [read the API documantion and "pdbsliecer" for more details]
#        FILES:  XYXParser.pm file4babel.log
#         BUGS:  Not That I knows of - but please report to sagivba@gmail.com
#        NOTES:  ---
#       AUTHOR:   (Sagiv Barhoom), <sagivba@gmail.com>
#      COMPANY:  
#      VERSION:  0.0.1
#      CREATED:  11/09/2014 10:32:20 PM IDT
#     REVISION:  ---
#     Data Structures:
#     pdb contain one or more proteine
#     proteine is a list of  peptides
#     peptide is a list of atom
#     atom has properties such as: X, Y, Z, name, resname, resseq  ...
#==================================================================================

use strict;
use warnings;


package OpSym::AminoAcid;

use strict;
use warnings;
use File::Slurp;
use Data::Dumper;
use OpSym::Conf;

my $amino_acids={
	ALA=>{full_name=> 'Alanine'         , number_of_atoms=> 10} ,
	ARG=>{full_name=> 'Arginine'        , number_of_atoms=> 24} ,
	ASN=>{full_name=> 'Asparagine'      , number_of_atoms=> 14} ,
	ASP=>{full_name=> 'Aspartate'       , number_of_atoms=> 12} ,
	CYS=>{full_name=> 'Cysteine'        , number_of_atoms=> 10} ,
	GLU=>{full_name=> 'Glutamate'       , number_of_atoms=> 15} ,
	GLN=>{full_name=> 'Glutamine'       , number_of_atoms=> 17} ,
	GLY=>{full_name=> 'Glycine'         , number_of_atoms=>  7} ,
	HIS=>{full_name=> 'Histidine'       , number_of_atoms=> 17} ,
	ILE=>{full_name=> 'Isoleucine'      , number_of_atoms=> 19} ,
	LEU=>{full_name=> 'Leucine'         , number_of_atoms=> 19} ,
	LYS=>{full_name=> 'Lysine'          , number_of_atoms=> 22} ,
	MET=>{full_name=> 'Methionine'      , number_of_atoms=> 17} ,
	PHE=>{full_name=> 'Phenylalanine'   , number_of_atoms=> 19} ,
	PRO=>{full_name=> 'Proline'         , number_of_atoms=> 14} ,
	SER=>{full_name=> 'Serine'          , number_of_atoms=> 11} ,
	THR=>{full_name=> 'Threonine'       , number_of_atoms=> 14} ,
	TRP=>{full_name=> 'Tryptophan'      , number_of_atoms=> 24} ,
	TYR=>{full_name=> 'Tyrosine'        , number_of_atoms=> 21} ,
	VAL=>{full_name=> 'Valine'          , number_of_atoms=> 16} ,
};





my $_dbg	= 00;
my $Version	="0.0.3";
sub dbg { print @_,"\n" if $_dbg == 1 }





sub is_valid_resname {
	my $class    = shift;
	my $resname  = shift;
	return 1 if exists $amino_acids->{$resname};
	return undef;
}	# ----------  end of subroutine is_valid_resname  ----------

sub validate_aminos{
	my $self    = shift;
	my $peptide = shift;

	for my $i (2..scalar (@$peptide)-2){
		my $atom       = $peptide->[$i];
		my $curr_amino = $atom->{resname};
		
		unless (exists $amino_acids->{$curr_amino}){
			$self->{STATUS}="AMINO_NOT_VALID:$atom->{resname} on atomline='$atom->{orig_line}'";
		}
#TODO	
		
	}	
	

}	# ----------  end of subroutine validate_aminos  ----------

sub new {
	
	my $class =shift;	
	my $self  ={ };
	bless $self, $class;
	$self->{peptide}   = shift;
	$self->{curr_index}= 1;
	

	$self->{STATUS}   = 'NEW_OK';
	return $self;	
}	# ----------  end of subroutine new  ----------



sub get_status {
	my $self = shift;
	return $self->{STATUS};
}	# ----------  end of subroutine get_status  ----------

sub get_resseq {
	my $self = shift;
	my $amino_acid = shift;
	$self->is_amino_acid($amino_acid);
	return $amino_acid->[0]->{resseq} if $self->get_status=~/OK/; 
	return ;
}	# ----------  end of subroutine get_resseq  ----------

sub get_resname {
	my $self = shift;
	my $amino_acid = shift;
	$self->is_amino_acid($amino_acid);
	return $amino_acid->[0]->{resname} if $self->get_status=~/OK/; 
	return ;
}	# ----------  end of subroutine get_resname  ----------


sub get_curr_index {
	my $self = shift;
	return $self->{curr_index};
}	# ----------  end of subroutine get_curr_index  ----------


sub is_amino_acid {
	my $self       = shift;
	my $atoms_list = shift;

	
#	atom={
#		orig_line          =>$line,
#		line_index         =>$line_number, # but we start counting line numbering from 0    
#		record_name        =>_substr($line,  1 ,  6), # Record name   "ATOM  "
#		atom_serial_number =>_substr($line,  7 , 11), # Integer  serial  Atom  serial number.
#		atom_name          =>_substr($line, 13 , 16), # Atom          name         Atom name.
#		altloc             =>_substr($line, 17 , 17), # Character     altLoc       Alternate location indicator.
#		resname            =>_substr($line, 18 , 20), # Residue name  resName      Residue name.
#		chain_id           =>_substr($line, 22 , 22), # Character     chainID      Chain identifier.
#		resseq             =>_substr($line, 23 , 26), # Integer       resSeq       Residue sequence number.
#		icode              =>_substr($line, 27 , 27), # AChar         iCode        Code for insertion of residues.
#		X                  =>_substr($line, 31 , 38), # Real(8.3)     x            Orthogonal coordinates for X in Angstroms.
#		Y                  =>_substr($line, 39 , 46), # Real(8.3)     y            Orthogonal coordinates for Y in Angstroms.
#		Z                  =>_substr($line, 47 , 54), # Real(8.3)     z            Orthogonal coordinates for Z in Angstroms.
#		occupancy          =>_substr($line, 55 , 60), # Real(6.2)     occupancy    Occupancy.
#		tempfactor         =>_substr($line, 61 , 66), # Real(6.2)     tempFactor   Temperature  factor.
#		element_symbol     =>_substr($line, 77 , 78), # LString(2)    element      Element symbol, right-justified.
#		charge             =>_substr($line, 79 , 80), # LString(2)    charge       Charge  on the atom.
#	}

	unless (defined $atoms_list and defined $atoms_list->[0]->{resname}){	
		$self->{STATUS} = 'ERROR:IS_AMINO_ACID:NOT_ATOM_LIST';
		return ;
	}

	my $resname	= $atoms_list->[0]->{resname};
	unless ($self->is_valid_resname($resname)){	
		$self->{STATUS} = "ERROR:IS_AMINO_ACID:NO_SUCE_RESNAME:$resname";
		return ;
	}
	my $noa		= $amino_acids->{$resname}->{number_of_atoms};
	unless ($noa = scalar $atoms_list ){	
		$self->{STATUS} = "ERROR:IS_AMINO_ACID:GOT_".scalar ($atoms_list )."_ATOMS_BUT_EXPECTING_$noa";
		return ;
	}

	for my $atom (@$atoms_list){
		dbg Dumper $atom;
		unless ( $atom->{resname} eq $resname  ){	
			$self->{STATUS} = "ERROR:IS_AMINO_ACID:NON_VALID_RESNAMEON_ATOM:$atom->{atom_name}";
			return ;
		}
	}

		
	
	$self->{STATUS} = "OK:IS_AMINO_ACID:OK";
	return $self->{STATUS};
}	# ----------  end of subroutine is_amino_acid   ----------


sub get_next_amino_acid {
	my $self       = shift;
	my $peptide    = $self->{peptide};
	my $curr_index = $self->{curr_index}; # start of last detected amino acid
	my $resname    = $peptide->[$curr_index]->{resname};
	my $resseq     = $peptide->[$curr_index]->{resseq};
	if ( defined $peptide->[$self->get_curr_index()]  ) {
		$self->{STATUS} = "GET_NEXT_AMINO_WILL_CONTINUE";
	}	
	else{
		$self->{STATUS} = "GET_NEXT_AMINO_ERROR-NO_SUCH_AMINO";
	}
	
	unless ( defined $resname ) {
		$self->{STATUS}="ERROR:GET_NEXT_AMINO_ACID:NOT_DEFINED_RESNAME-CURR_INDEX:$curr_index";
		return;
	}

	my $amino_acid  = $amino_acids->{$resname}; 	
	unless ( defined $amino_acid ){
		$self->{STATUS}="ERROR:GET_NEXT_AMINO_ACID:NOT_VALID_RESNAME-$resname";
		return;
	}
        my $atoms_list  = [ $peptide->[$curr_index++] ];
	while (defined $peptide->[$curr_index] and $peptide->[$curr_index]->{resseq} == $resseq) {
		push @$atoms_list, $peptide->[$curr_index++];
	}
	
	unless ( $self->is_amino_acid($atoms_list) ) {
		return;
	}	
	
	$self->{curr_index} = $curr_index;
	if ( defined $peptide->[$self->get_curr_index()]  ) {
		$self->{STATUS} = "GET_NEXT_AMINO_OK";
	}	
	else{
		$self->{STATUS} = "GET_NEXT_AMINO_OK-LAST_AMINO";
	}
		
	return $atoms_list;
	
}	# ----------  end of subroutine get_next_amino_acid  ----------



sub get_amino_list{
	my $self        = shift;
	$self->{STATUS} = "GET_AMINO_LIST_OK";	
	return $self->{amino_list} if exists $self->{amino_list};
	$self->{curr_index}=1;
	my $amino_list  =[];
	my $curr_amino;
	while ( $self->{STATUS} !~/LAST_AMINO/ and  $curr_amino = $self->get_next_amino_acid()) {
		return  unless $curr_amino;
		push @$amino_list,$curr_amino;
	}
	
	$self->{STATUS} = "GET_AMINO_LIST_OK";	
	$self->{amino_list}=$amino_list; 
	return $amino_list;
	
}	# ----------  end of subroutine get_amino_list_from_peptide  ----------

sub get_all_amino_res_hash{
	my $self           = shift;
	my $amino_list     = $self->get_amino_list();
	my $amino_res_hash={};
	return unless $self->get_status eq 'GET_AMINO_LIST_OK';

	for my $amino_acid (@$amino_list){
		my $resname = $self->get_resname_from_amino($amino_acid);
		my $resseq  = $self->get_resseq_from_amino($amino_acid);
		$amino_res_hash->{$resseq}=$resname;
	}

	return $amino_res_hash;
	
}	# ----------  end of subroutine get_all_amino_res_hash  ----------


sub get_all_amino_resnames{
	my $self           = shift;
	my $amino_list     = $self->get_amino_list();
	my $amino_resnames = []; 
	return unless $self->get_status eq 'GET_AMINO_LIST_OK';

	for my $amino_acid (@$amino_list){
		push @$amino_resnames , $self->get_resname_from_amino($amino_acid);
	}

	return $amino_resnames;
	
}	# ----------  end of subroutine get_amino_list_from_peptide  ----------

sub get_resseq_from_amino {
	my $self           = shift;
	my $amino          = shift;
	unless(defined $amino->[0] and defined $amino->[0]->{resseq}){
		$self->{STATUS}="ERROR:GET_RESNAME_FROM_AMINO-NO_RESNAME";
		return;
	}	
	return $amino->[0]->{resseq};
	
}	# ----------  end of subroutine get_resseq_from_amino   ----------


sub get_resname_from_amino {
	my $self           = shift;
	my $amino          = shift;
	unless(defined $amino->[0] and defined $amino->[0]->{resname}){
		$self->{STATUS}="ERROR:GET_RESNAME_FROM_AMINO-NO_RESNAME";
		return;
	}	
	return $amino->[0]->{resname};
	
}	# ----------  end of subroutine get_resname_from_amino   ----------

sub amino_to_string{
	my $self           = shift;
	my $amino          = shift;
	my $str= "";
	for my $atom (@$amino){
		$str.="$atom->{orig_line}\n";
	}
	
	return $str;
}	# ----------  end of subroutine get_resname_from_amino   ----------

1;

