#
#=================================================================================
#
#         FILE:  Sorter.pm
#
#  DESCRIPTION:  File parser object for the Gaussian program [http://Gaussian.Com]
#                the idea is to run Gaussian and to give the output of it to the 
#                parser
#                [read the API documantion and "mysym for more details]
#        FILES:  Sorter.pm
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


package OpSym::Sorter;

use strict;
use warnings;
use File::Slurp;
use Data::Dumper;
use OpSym::Conf;
my $_dbg	=0;
my $Version	="0.0.8";
sub dbg { print @_,"\n" if $_dbg == 1 }

sub new {

#===  CLASS METHOD  ============================================================
#         NAME:  new 
#      PURPOSE:  Constructor for the sorter Object
#   PARAMETERS:  file to sort and by which colomn
#      RETURNS:  Sorter Object
#  DESCRIPTION: 
#                
#     COMMENTS:  none
#     SEE ALSO:  n/a
#===============================================================================
	my	($class,$filename,$order_by)	= (shift,shift,shift);
	my $self = {file_name=>$filename};
	bless $self, $class;
	$self->{STATUS}='NEW_OK';
	unless ( -f $filename){
	    $self->{STATUS}="NEW_FAILED-no such file '$filename'";
	    return $self; 
	}
        unless ( ref $order_by eq 'ARRAY'){
            $self->{STATUS}="NEW_FAILED-order_by is not array ref";
            return $self;
        }

	my @lines = read_file $filename;
	chomp @lines;
	$self->{lines} 		= \@lines;
	$self->{order_by}	= $order_by;

	$self->{parsed_data}	= [];
	return $self;
}	# ----------  end of subroutine new  ----------

sub get_status{
	my $self = shift;
	return $self->{STATUS};
}	# ----------  end of subroutine get_status  ----------


sub parse_data {

#===  METHOD  ===================================================================
#         NAME:  parse_data 
#      PURPOSE:  collect the data names from the lines of the Gaussian file
#   PARAMETERS:  none
#      RETURNS:  
#                PARSE_DATA_FAILED 	if could not parse_data
#	         PARSE_DATA_OK 		if ok
#
#  DESCRIPTION: the relatie section of the file look like this
#     1      -3.899710     -93.405910       0.224800
#     2      -3.869710     -93.405840       0.276500
#     3      -3.839710     -93.405760       0.333500
#     4      -3.809710     -93.405670       0.395900
#     5      -3.779710     -93.405580       0.463700
#     6      -3.749710     -93.405470       0.536900
#     7      -3.719710     -93.405370       0.615600
#
# ------------------------------------------------------------------------
#                
#===============================================================================
	my	$self	        = shift;
	my @lines           = @{ $self->{lines} };
	my ($line);
	foreach $line (  @lines ) {
		$line=~s/^\s+//g;
		$line=~s/\s+/,/g;
		dbg "line=$line\n";
		my @tmp=split ( ",",$line);
		unless (scalar (@tmp) ==4){
			$self->{STATUS}="PARSE_DATA_FAILED-split '$line'";
			return $self->{STATUS};
		}
		push @{ $self->{parsed_data} } , [ split (",",$line) ] ;
	}               # -----  end foreach  -----
	$self->{STATUS}="PARSE_DATA_OK";
    	return $self->{STATUS};
}	# ----------  end of subroutine parse_data  ----------

sub sort_data {
	my $self = shift;
	$self->parse_data;
	unless ($self->{STATUS}=~/OK/) {return $self->{STATUS}}
	my $s1   = $self->{order_by}->[0]-1;
	my $s2   = $self->{order_by}->[1]-1;
	my $s3   = $self->{order_by}->[2]-1;
	my $s4   = $self->{order_by}->[3]-1;
	my @data=@{$self->{parsed_data}};

	my @sorted_data= sort {
				if    ( $a->[$s1]>$b->[$s1] ) {return  1}
				elsif ( $a->[$s1]<$b->[$s1] ) {return -1}
				
				elsif ( $a->[$s2]>$b->[$s2] ) {return  1}
				elsif ( $a->[$s2]<$b->[$s2] ) {return -1}
				
				elsif ( $a->[$s3]>$b->[$s3] ) {return  1}
				elsif ( $a->[$s3]<$b->[$s3] ) {return -1}
				
				elsif ( $a->[$s4]<$b->[$s4] ) {return  1}
				elsif ( $a->[$s4]<$b->[$s4] ) {return -1}
				
				else {return 0}
			 } @data;
	$self->{sorted_data}=\@sorted_data;
	$self->{STATUS}='SORT_DATA_OK';
	return $self->{STATUS};
}	# ----------  end of subroutine oort_data  ----------


sub get_sorted_data{
	my $self = shift;
        unless (exists $self->{sorted_data}){
                $self->{STATUS}='GET_MAX-DATA_NOT_SORTED';
                return undef;
        }
	return $self->{sorted_data};
}
sub get_max{
	
	my $self = shift;
	unless (exists $self->{sorted_data}){
		$self->{STATUS}='GET_MAX-DATA_NOT_SORTED';
		return undef;
	}
	my $last_element=scalar (@{$self->{sorted_data}}) -1;
	return $self->{sorted_data}->[$last_element];
}	# ----------  end of subroutine get_max  ----------

sub get_min{
        my $self = shift;
        unless (exists $self->{sorted_data}){
                $self->{STATUS}='GET_MAX-DATA_NOT_SORTED';
                return undef;
        }
        return $self->{sorted_data}->[0];


}	# ----------  end of subroutine get_min  ----------

sub get_TS{
   my $self = shift;
   unless (exists $self->{sorted_data}){
         $self->{STATUS}='GET_MAX-DATA_NOT_SORTED';
         return undef;
    }
	for my $data (@{ $self->{sorted_data} }){
        	return $data if $data->[1] == 0;
	}


}	# ----------  end of subroutine  get_TS  ----------


1;
