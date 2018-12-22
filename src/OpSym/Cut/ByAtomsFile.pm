use strict;
use warnings;


package OpSym::Cut::ByAtomsFile;

use strict;
use warnings;
use OpSym::AminoAcid;
use List::MoreUtils;
use Data::Dumper;
use File::Slurp;
use parent 'OpSym::Cut::Cut';



my $_dbg	= 0;
my $Version	="0.0.3";
sub dbg { print @_,"\n" if $_dbg == 1 }


sub _is_member_in_list {
	my $item = shift;
	my $list = shift;
	my $ret_val = List::MoreUtils::true {$item eq $_ } @$list;
	dbg ("atom_name=$item list =".join(",", @$list ). " ret_val=$ret_val");
	
	return $ret_val;
	

}	# ----------  end of subroutine cut   ----------


sub grep_atoms_from_amino {
	my $self          = shift;
	my $amino_acid    = shift;
	my $atoms_to_grep = shift;
	my $list_of_atoms =[];
#return $list_of_atoms 
	if ($atoms_to_grep->[0]=~/^NONE/i) {
		# $self->{STATUS}='not valid line: "NONE" value is not allowed';
		
		return [];
	}
	if ($atoms_to_grep->[0]=~/^ALL/i){
		push @$list_of_atoms,@$amino_acid;
		
	} 
	else {
		for my $atom (@$amino_acid){
			push (@$list_of_atoms, $atom) if _is_member_in_list ($atom->{atom_name},  $atoms_to_grep);
		}
	}
	
	return $list_of_atoms;

}	# ----------  end of subroutine grep_atoms_from_amino   ----------


#sub grep_atoms_from_amino {
#	my $self          = shift;
#	my $amino_acid    = shift;
#	my $resname	  = uc $amino_acid->[0]->{resname};
#	my $atoms_to_grep = $self->{cutter_atoms}->{$resname};
#
#	my $list_of_atoms = [];
#	for my $atom (@$amino_acid){
#		push (@$list_of_atoms, $atom) if _is_member_in_list ($atom->{atom_name},  $atoms_to_grep);
#	}
##	print Dumper $list_of_atoms;	
#	return $list_of_atoms;
#
#}	# ----------  end of subroutine cut   ----------

#sub pass_the_filter {
#
#	my $self         = shift;
#	my $atoms_list	 = shift;
#	dbg  Dumper $atoms_list; 
#	dbg  "resname=$atoms_list->[1]->{resname}";
#	return 1 	 if $atoms_list->[1]->{resname}  eq $self->{filter_pattern}; 
#	return undef;
#
#}
#
sub cut {
	# by atoms file
	my $self         = shift;
	unless ( scalar (keys(%{$self->{cutter_atoms}})) == 20 ) {
		$self->{STATUS} = 'ERROR:DID_YOU_PARSED_ATOMS_FILE?';
		return undef;
	}
	my $cutting= [];
	my $amino_acider = OpSym::AminoAcid->new($self->get_peptide());
	my $amino_list   = $amino_acider->get_amino_list();
	for my $i ( 0..scalar(@$amino_list)-1){
		my $curr_amino 	  = $amino_list->[$i  ]; 
		my $resname	  = uc $curr_amino->[0]->{resname};
		my $atoms_to_grep = $self->{cutter_atoms}->{$resname};
		my @cut = (
			@{ $self->grep_atoms_from_amino($curr_amino, $atoms_to_grep ) },
		);
		return [] unless $self->get_status() =~/OK/;
		push @$cutting,  [@cut];
		@cut=();
			
	}	
#print Dumper  $self->{cutting_list}; 
	$self->{cutting_list} = $self->remove_gap_edges($cutting);
	$self->{STATUS} = $amino_acider->get_status();
	
	$self->filter($self->{cutting_list});
	shift @{$self->{cutting_list} };
	pop   @{$self->{cutting_list} };	
	
	return $self->{cutting_list};
}	# ----------  end of subroutine cut   ----------

sub parse_atoms_file {
	my $self         = shift;
	my $atoms_file   = shift;
	unless ( -r $atoms_file){
		$self->{STATUS}= "ATOMS_FILE_IS_NOT_READBLE:$atoms_file";
		return $self->get_status();
	}
	$self->{atoms_file} = $atoms_file;
	my @lines= read_file $atoms_file;
	$self->{cutter_atoms}={}; # for example {GLY => [N,C,C,O]}
	for my $line (@lines){
		next if $line =~/^#/;
		chomp $line;
		$line=~s/\s+//g while $line=~/\s/;
		$line=~s/#.*//g if $line=~/#/;
		my ($resname,$atoms) = split ":", $line;
		my @atoms= split ",", $atoms;
		unless ( $resname ) {
			$self->{STATUS}= "ATOMS_FILE_IS_VAILD-LINE:$line(amino_name?)";
			return $self->get_status();
		}
		if  ( $self->{cutter_atoms}->{uc $resname}){ 
			$self->{STATUS}= "ATOMS_FILE_IS_VAILD-LINE:$line(duplicate amino?)";
			return $self->get_status();
		}
	
		unless ( $atoms[0] ) {
			$self->{STATUS}= "ATOMS_FILE_IS_VAILD-LINE:$line(atoms?)";
			return $self->get_status();
		}
		for my $atom ( @atoms ){
			unless($atom){
				$self->{STATUS}= "ATOMS_FILE_IS_VAILD-LINE:$line(atom not valid?)";
				return $self->get_status();
			}
			
		}


		$self->{cutter_atoms}->{uc $resname}=[@atoms];
#		print Dumper $self->{cutter_atoms};
		
	}
	
		
	$self->{STATUS}= "PARSE_ATOMS_FILE_OK";
	return $self->get_status();
	


}	# ----------  end of subroutine parse_atoms_file   ----------
	
1;

