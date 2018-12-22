package OpSym::Cut::Filter::RelativeResseq;

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
	my $relative_resseq = $atoms_list->[1]->{relative_resseq};
	my $filtered= grep( /^$relative_resseq$/, @{$self->{filter_pattern}} );
	dbg  	"filter_pattern:".join (",", @{$self->{filter_pattern}}).
		" ==> filtered:$filtered"; 

	return 1 if $filtered;
	return undef;

}



1;


