package OpSym::Cut::Filter::Aminos;

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
#	dbg  Dumper $atoms_list; 
	dbg ">$atoms_list->[0]->{resseq}";
	dbg Dumper $atoms_list->[1];
	dbg $self->{filter_pattern};
#	if($atoms_list->[1]->{resseq} == 55 ){
#		print Dumper	$atoms_list;
#		print "\n$atoms_list->[1]->{resseq} $atoms_list->[1]->{resname} eq $self->{filter_pattern} => ".($atoms_list->[1]->{resname}  eq $self->{filter_pattern}? "TRUE":"FALSE");
#	}
	return 1 	 if $atoms_list->[1]->{resname}  eq $self->{filter_pattern}; 
	return undef;

}



1;


