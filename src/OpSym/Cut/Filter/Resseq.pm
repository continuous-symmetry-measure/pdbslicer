package OpSym::Cut::Filter::Resseq;

use strict;
use warnings;
use File::Slurp;
use Data::Dumper;
use OpSym::Conf;
use parent 'OpSym::Cut::Filter::Filter';



my $_dbg	= 0;
my $Version	="0.0.1";
sub dbg { print @_,"\n" if $_dbg == 1 }

sub pass_the_filter {

	my $self         = shift;
	my $atoms_list	 = shift;
	dbg  Dumper $atoms_list; 
	dbg  Dumper $self->{filter_pattern}; 
	my $resseq = $atoms_list->[1]->{resseq};
	return 1 if  grep( /^$resseq$/, @{$self->{filter_pattern}} );
	return undef;

}



1;


