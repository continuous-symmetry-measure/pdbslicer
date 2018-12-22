#
#=================================================================================
#
#         FILE:  CmdString.pm
#
#  DESCRIPTION:  create cmd_string content for cmd_string file
#        FILES:  CmdString.pm 
#         BUGS:  Not That I knows of - but please report to sagivba@gmail.com
#        NOTES:  ---
#       AUTHOR:   (Sagiv Barhoom), <sagivba@gmail.com>
#      COMPANY:  
#      VERSION:  0.0.1
#      CREATED:  04/08/2013 10:32:20 PM IDT
#     REVISION:  ---
#==================================================================================

use strict;
use warnings;


package OpSym::CmdString;

use strict;
use warnings;
use File::Slurp;
use Data::Dumper;
use OpSym::Conf;
my $_dbg	= 0;
my $Version	="0.0.1";
sub dbg { print @_,"\n" if $_dbg == 1 }

sub  get_cmd_string {
	my $class	= shift;
        my $cmd_string	= shift(@_)." ";
        for my $c (@_){
		if     ($c=~/^-/)	{ $cmd_string.="$c ";}
		else   			{ $cmd_string.="'$c' ";}

        }

	return $cmd_string;
}	# ----------  end of subroutine get_cmd_string  ----------


sub  get_file_lines {
	my $class          = shift;
	my $csm_dir        = shift;

	return join("\n",$class->get_cmd_string(@_) );
}	# ----------  end of subroutine  get_file_lines  ----------




1;

