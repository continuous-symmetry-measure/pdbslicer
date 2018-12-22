use strict;
use warnings;


package OpSym::Cut::Cut;

use strict;
use warnings;
use File::Slurp;
use Data::Dumper;
use OpSym::Conf;



my $_dbg	= 0;
my $Version	="0.0.2";
sub dbg { print @_,"\n" if $_dbg == 1 }



sub new {
	
	my $class =shift;	
	my $self  ={ };
	bless $self, $class;
	$self->{STATUS}   = 'NEW_OK';
	$self->{peptide}             = shift;
	$self->{filters_list}       =  shift || [];
		 	

	for my $filter ( @{ $self->{filters_list}  } ){
		my $ref_pattern=ref($filter);
		if ( index($ref_pattern,'OpSym::Cut::Filter')==-1 ){
			$self->{STATUS}   = 'NEW_ERROR-I got filter- but this is not OpSym::Cut::Filter object';
			warn $self->{STATUS}." ref filter is:".ref($self->{filters_list});
		}
	}
	$self->{curr_index}          = 1;
	$self->{cutting_list}        = [] ;
	

	return $self;	
}	# ----------  end of subroutine new  ----------



sub get_status {
	my $self = shift;
	return $self->{STATUS};
}	# ----------  end of subroutine get_status  ----------

sub get_peptide {
	my $self = shift;
	return $self->{peptide};
}	# ----------  end of subroutine get_peptide  ----------


sub get_curr_index {
	my $self = shift;
	return $self->{curr_index};
}	# ----------  end of subroutine get_curr_index  ----------
#
#sub pass_the_filter {
#
#	my $self         = shift;
#	my $atoms_list	 = shift;
#	return $self->{filters_list}->pass_the_filter($atoms_list);
#
#}	# ----------  end of subroutine pass_the_filter  ----------

sub filter {
	my $self                  = shift;

	my $filtered_cutting_list = [];
	if ( scalar (@{$self->{filters_list}}) ==0){
		return $self->{cutting_list};
	}
	
	$self->{orig_cutting_list}       = [];
	@{$self->{orig_cutting_list}}    = @{$self->{cutting_list}};
	for my $filter (@{ $self->{filters_list}}){
		$self->{cutting_list}            = $filter->filter($self->{cutting_list});
	}
	
	return $filtered_cutting_list;

}	# ----------  end of subroutine filter   ----------

sub remove_gap_edges {
	my $self =shift;
	my $cutting= shift;
	my $clean_cutting=[];
	# remove gaps edges
	for my $amino (@{$cutting}){
		if (ref($amino) eq 'ARRAY' and scalar(@$amino)==0) { # empty array --> []
			next;
		}
		push @$clean_cutting, $amino unless exists $amino->[1]->{gap_in_resseq};
	}
	return $clean_cutting;

}	# ----------  end of subroutine remove   ----------

sub cut {
	my $self         = shift;
	my $cutting_list = [];
	
	return $self->filter($self->{cutting_list});
}	# ----------  end of subroutine cut   ----------

sub cut2pdb{
	my $self        = shift;
	my $cutting_list=  $self->{cutting_list};
	my $pdb         = "";
	for my $i (0..scalar(@$cutting_list)-1){
		my $atom = $cutting_list->[$i];
		$pdb    .="$atom->{orig_line}\n";
	}
	return $pdb;	
}	# ----------  end of subroutine cut2pdb   ----------


1;

