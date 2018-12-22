package OpSym::Cut::Filter::PreProline_General;

use strict;
use warnings;
use File::Slurp;
use Data::Dumper;
use OpSym::Conf;
use parent 'OpSym::Cut::Filter::Filter';



my $_dbg	= 0;
my $Version	="0.0.1";
sub dbg { print @_,"\n" if $_dbg == 1 }

sub new {
	
	my $class =shift;	
	my $self = $class->SUPER::new(@_); # first prarameter is PRE_PRO or GENERAL or PRE_PRO|GENERAL
	bless $self, $class;
	return $self;	
}	# ----------  end of subroutine new  ----------


sub pass_the_filter {

	my $self         = shift;
	my $atoms_list	 = shift;
	dbg  Dumper $atoms_list; 
	dbg  Dumper $self->{filter_pattern}; 
	my $rama_type= $atoms_list->[1]->{rama_type};
	return 1 if  $rama_type=~/$self->{filter_pattern}/;
	return undef;

}



1;


