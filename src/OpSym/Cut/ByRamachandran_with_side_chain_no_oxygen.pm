use strict;
use warnings;


package OpSym::Cut::ByRamachandran_with_side_chain_no_oxygen;

use strict;
use warnings;
use OpSym::AminoAcid;
use List::MoreUtils;
use Data::Dumper;
use parent 'OpSym::Cut::ByRamachandran_with_side_chain';

sub _is_member_in_list {
	my $item = shift;
	my $list = shift;
	my $ret_val = List::MoreUtils::true {$item eq $_ } @$list;
	
	return $ret_val;
	

}	# ----------  end of subroutine _is_member_in_list   ----------


sub grep_out_atoms_from_amino {
	my $self         = shift;
	my $amino_acid   = shift;
	my $atoms_to_grep_out = shift;
	my $list_of_atoms;
	for my $atom (@$amino_acid){
		push (@$list_of_atoms, $atom) if not _is_member_in_list ($atom->{atom_name}, $atoms_to_grep_out);
	}
	
	return $list_of_atoms;

}	# ----------  end of subroutine grep_atoms_from_amino   ----------


sub cut {
	#
	#
	#C (n-1)
	# amino (n) without O
	#C (n)
	#N (n+1)
	my $self         = shift;
	my $cutting= [];
	my $amino_acider = OpSym::AminoAcid->new($self->get_peptide());
	my $amino_list   = $amino_acider->get_amino_list();
	for my $i ( 1..scalar(@$amino_list)-2){
#		print "ATOM i=$i\n";
		my $prev_amino = $amino_list->[$i-1];
		my $curr_amino = $amino_list->[$i  ]; 
		my $next_amino = $amino_list->[$i+1];
		my @cut = (
			@{ $self->grep_atoms_from_amino    ($prev_amino, ['C']         ) },
			@{ $self->grep_out_atoms_from_amino($curr_amino, ['O']         ) },
			@{ $self->grep_atoms_from_amino    ($next_amino, ['N']         ) },
		);
		push @$cutting,  [@cut];
#		print Dumper $cutting;
		@cut=();
			
	}	
	
	$self->{cutting_list} = $self->remove_gap_edges($cutting);
	$self->{STATUS} = $amino_acider->get_status();
	
	$self->filter($self->{cutting_list});
	return $self->{cutting_list};
}	# ----------  end of subroutine cut   ----------
1;




