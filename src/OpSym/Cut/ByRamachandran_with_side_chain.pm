use strict;
use warnings;


package OpSym::Cut::ByRamachandran_with_side_chain;

use strict;
use warnings;
use OpSym::AminoAcid;
use List::MoreUtils;
use Data::Dumper;
use parent 'OpSym::Cut::ByRamachandran';
my $_dbg	= 0;
my $Version	="0.0.1";
sub dbg { print @_,"\n" if $_dbg == 1 }



sub cut {
	#
	#
	#C (n-1)
	#amino (n)
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
#	$_dbg=1 if $i==99;
		dbg ("========$i=================");
		dbg (Dumper $next_amino);
		dbg (Dumper $amino_list->[$i+2]);
		my @cut = (
			@{ $self->grep_atoms_from_amino($prev_amino,['C']          ) },
			@{ $curr_amino },
			@{ $self->grep_atoms_from_amino($next_amino,['N']          ) },
		);
#		print Dumper $self->grep_atoms_from_amino($curr_amino,['N','CA','C']);
		push @$cutting,  [@cut];
#		print Dumper $cutting;
		@cut=();
			
	}	
	
	$self->{cutting_list} = $self->remove_gap_edges($cutting);
	$self->{STATUS} = $amino_acider->get_status();
	#print $self->filter;	
	$self->filter($self->{cutting_list});
	#print Dumper $self->{cutting_list};
	return $self->{cutting_list};
}	# ----------  end of subroutine cut   ----------
1;




