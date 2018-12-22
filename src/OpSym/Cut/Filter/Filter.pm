package OpSym::Cut::Filter::Filter;

use strict;
use warnings;
use File::Slurp;
use Data::Dumper;
use OpSym::Conf;



my $_dbg	= 00;
my $Version	="0.0.1";
sub dbg { print @_,"\n" if $_dbg == 1 }



sub new {
	
	my $class =shift;	
	my $self  ={ };
	bless $self, $class;
	$self->{filter_pattern}      = shift;
	
	$self->{STATUS}   = 'NEW_OK';
	return $self;	
}	# ----------  end of subroutine new  ----------



sub get_status {
	my $self = shift;
	return $self->{STATUS};
}	# ----------  end of subroutine get_status  ----------

sub pass_the_filter {

	my $self         = shift;
	my $list	 = shift;
	dbg  Dumper $list;
	return 1 	 if 1==1; # by defuat do not filter
	return undef;

}	# ----------  end of subroutine pass_the_filter  -

sub filter {
	my $self          = shift;
	my $cutting_list  = shift;
	my $filtered_list = [];
	unless ( $self->{filter_pattern} ){
		return $cutting_list;
	}
	
	for my $items_list ( @{ $cutting_list }){
		push ( @$filtered_list, $items_list ) if $self->pass_the_filter($items_list);
		
	}
	return $filtered_list;

}	# ----------  end of subroutine filter   ----------



1;


