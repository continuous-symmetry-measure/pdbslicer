#
#=================================================================================
#
#         FILE:  RangeOfNumbers.pm
#
#  DESCRIPTION: gets string such as 1,9,2-6,12
#		returns array 1,2,3,4,5,6,9,12
#		here are some examples:
#		3,2,1  =>1,2,3 & STAUS:LIST_OK
#		3,2,1,3=>1,2,3 & STAUS:LIST_OK
#		2-4,-1 =>undef & STATUS:ERROR_NON_NATURAL_NUMBER
#		
#        FILES:  RangeOfNumbers.pm
#         BUGS:  Not That I knows of - but please report to sagivba@gmail.com
#        NOTES:  ---
#       AUTHOR:   (Sagiv Barhoom), <sagivba@gmail.com>
#      COMPANY:  
#      VERSION:  0.0.6
#      CREATED:  02/02/2007 10:32:20 PM IDT
#     REVISION:  ---
#==================================================================================

use strict;
use warnings;


package OpSym::RangeOfNumbers;
use strict;
use warnings;
use File::Slurp;
use Data::Dumper;
use OpSym::Conf;
use List::MoreUtils;
my $_dbg	=1;
my $Version	="0.0.1";
sub dbg { print @_,"\n" if $_dbg == 1 }

sub new {

	my	($class,$numbers_string)	= (shift,shift);
	my $self = {NUMBERS_STRING=>$numbers_string};
	if  ( defined $numbers_string and  $numbers_string!~m/^([\d,]|-)+$/ ){
	    warn "The RangeOfNumbers string '$numbers_string' contain non valid  characters.".
		 " Valid characters are:0-9 ',' and '-'.";
	    $self->{STATUS}='NON_VALID_CHARACTERS';
	}
	bless $self, $class;
	$self->{STATUS}='NEW_OK';
	$self->{LIST_OF_NUMBERS}=[];
	return $self;
}	# ----------  end of subroutine new  ----------

sub get_status{
	my $self=shift;
	return $self->{STATUS};

}	# ----------  end of subroutine get_status  ----------


sub parse_numbers_string{
	my $self=shift;
	my $numbers_string=shift;
	unless ( $numbers_string=~m/^([\d,]|-)+$/ ){
	    warn "The RangeOfNumbers string '$numbers_string' contain non valid  characters.".
		 " Valid characters are:0-9 ',' and '-'.";
	    $self->{STATUS}='NON_VALID_CHARACTERS';
	    return $self->get_status();
	}

	my @tmp			= split ',',$numbers_string;
	my @range_of_numbers	= ();
	$self->{STATUS}		= 'PARSE_NUMBERS_STRING_OK';
	for my $n (@tmp){
		if ($n=~/^\d+$/){
			push @range_of_numbers,$n;
			
		}
		elsif ($n=~/^(\d+)-(\d+)/){
			my ($first,$last)=($1,$2);
			unless ($first<=$last){
				warn "The RangeOfNumbers string '$numbers_string' contain non valid element:$n.";
				$self->{STATUS}="NON_VALID_ELEMENT_FIRST_GT_LAST-$n";
				next;
			}
			push @range_of_numbers,($first..$last);
		}
		else{
			warn "The RangeOfNumbers string '$numbers_string' contain non valid  element:$n.";
			$self->{STATUS}="NON_VALID_AELEMENT-$n";

		}		
		
	}
	my @unique 		= sort {$a<=>$b} (List::MoreUtils::uniq( @range_of_numbers )); 
	$self->{LIST_OF_NUMBERS}	= [@unique];
	return $self->{STATUS};
		
}	# ----------  end of subroutine parse_numbers_string  ----------

sub get_range_of_numbers{
	my $self=shift;
	return $self->{LIST_OF_NUMBERS};
	

}	# ----------  end of subroutine parse_numbers_string  ----------

1; 
