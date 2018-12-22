#
#=================================================================================
#
#         FILE:  PDBSlicer
#  DESCRIPTION:  File parser object for the pdb files - but not acomplete pdb parser - 
#                just for amino  acids
#                [read the API documantion and "pdbsliecer" for more details]
#         BUGS:  Not That I knows of - but please report to sagivba@gmail.com
#        NOTES:  ---
#       AUTHOR:   (Sagiv Barhoom), <sagivba@gmail.com>
#      COMPANY:  
#      VERSION:  0.0.4
#      CREATED:  11/09/2014 10:32:20 PM IDT
#     REVISION:  ---
#     Data Structures:
#     pdb contain one or more proteine
#     proteine is a list of  peptides
#     peptide is a list of atom
#     atom has properties such as: X, Y, Z, name, resname, resseq  ...
#==================================================================================

use strict;
use warnings;


package OpSym::PDBslicer;

use strict;
use warnings;
use File::Slurp;
use Data::Dumper;
use OpSym::Conf;
use OpSym::AminoAcid;

my $amino_acids={
	ALA=>{full_name=> 'Alanine'         , number_of_atoms=> 10} ,
	ARG=>{full_name=> 'Arginine'        , number_of_atoms=> 24} ,
	ASN=>{full_name=> 'Asparagine'      , number_of_atoms=> 14} ,
	ASP=>{full_name=> 'Aspartate'       , number_of_atoms=> 12} ,
	CYS=>{full_name=> 'Cysteine'        , number_of_atoms=> 10} ,
	GLU=>{full_name=> 'Glutamate'       , number_of_atoms=> 15} ,
	GLN=>{full_name=> 'Glutamine'       , number_of_atoms=> 17} ,
	GLY=>{full_name=> 'Glycine'         , number_of_atoms=>  7} ,
	HIS=>{full_name=> 'Histidine'       , number_of_atoms=> 17} ,
	ILE=>{full_name=> 'Isoleucine'      , number_of_atoms=> 19} ,
	LEU=>{full_name=> 'Leucine'         , number_of_atoms=> 19} ,
	LYS=>{full_name=> 'Lysine'          , number_of_atoms=> 22} ,
	MET=>{full_name=> 'Methionine'      , number_of_atoms=> 17} ,
	PHE=>{full_name=> 'Phenylalanine'   , number_of_atoms=> 19} ,
	PRO=>{full_name=> 'Proline'         , number_of_atoms=> 14} ,
	SER=>{full_name=> 'Serine'          , number_of_atoms=> 11} ,
	THR=>{full_name=> 'Threonine'       , number_of_atoms=> 14} ,
	TRP=>{full_name=> 'Tryptophan'      , number_of_atoms=> 24} ,
	TYR=>{full_name=> 'Tyrosine'        , number_of_atoms=> 21} ,
	VAL=>{full_name=> 'Valine'          , number_of_atoms=> 16} ,
};





my $_dbg	= 0;
my $Version	="0.0.4";
sub dbg { print @_,"\n" if $_dbg == 1 }





sub _substr{
    my ($line,$start,$end)=(shift,shift(@_)-1,shift(@_)-1);
#    warn "substr( $line, $start, $end-$start+1)\n";
    return substr( $line, $start, $end-$start+1);
}


sub _parse_atom {
	my $self= shift;
	my $line = shift;
	my $line_number=shift;
	
#12345678901234567890123456789012345678901234567890123456789012345678901234567890
#.........1.........2.........3.........4.........5.........6.........7.........8
#ATOM      1  N   GLY     1      -1.104  -0.267  -0.062  1.00  0.00           N1+

	my $line_start='^ATOM';
	if ($self->{_parse_also_hetatm}){
		$line_start='^(ATOM|HETATM)';
	}

	if ( not defined  $line or $line !~/$line_start/ ){
		$self->{STATUS}="NOT_${line_start}_LINE:'$line'";
		return 
	}
	
	if ( length ( $line ) <60 ){
		$self->{STATUS}="LINE_TOO_SHORT:'$line'";
		return 
	}
#	dbg "_parse_atom:$line_number->$line";
	
	my $parsed_atom={
		orig_line          =>$line,
		line_index         =>$line_number, # but we start counting line numbering from 0    
		record_name        =>_substr($line,  1 ,  6), # Record name   "ATOM  |HETATM"
		atom_serial_number =>_substr($line,  7 , 11), # Integer  serial  Atom  serial number.
		atom_name          =>_substr($line, 13 , 16), # Atom          name         Atom name.
		altloc             =>_substr($line, 17 , 17), # Character     altLoc       Alternate location indicator.
		resname            =>_substr($line, 18 , 20), # Residue name  resName      Residue name.
		chain_id           =>_substr($line, 22 , 22), # Character     chainID      Chain identifier.
		resseq             =>_substr($line, 23 , 26), # Integer       resSeq       Residue sequence number.
		icode              =>_substr($line, 27 , 27), # AChar         iCode        Code for insertion of residues.
		X                  =>_substr($line, 31 , 38), # Real(8.3)     x            Orthogonal coordinates for X in Angstroms.
		Y                  =>_substr($line, 39 , 46), # Real(8.3)     y            Orthogonal coordinates for Y in Angstroms.
		Z                  =>_substr($line, 47 , 54), # Real(8.3)     z            Orthogonal coordinates for Z in Angstroms.
		occupancy          =>_substr($line, 55 , 60), # Real(6.2)     occupancy    Occupancy.
		tempfactor         =>_substr($line, 61 , 66), # Real(6.2)     tempFactor   Temperature  factor.
		element_symbol     =>_substr($line, 77 , 78), # LString(2)    element      Element symbol, right-justified.
		charge             =>_substr($line, 79 , 80), # LString(2)    charge       Charge  on the atom.
	};
	

	for my $k (sort  keys %$parsed_atom){
		if (defined $parsed_atom->{$k} ){
			$parsed_atom->{$k}=~s/^\s*//;
			$parsed_atom->{$k}=~s/\s*$//;
		}
		$parsed_atom->{$k} = 'NOT_DEFINED' if not defined $parsed_atom->{$k};
#		dbg (printf "%25s|%s|%d\n",$k,$parsed_atom->{$k},length $parsed_atom->{$k});
	}

	$self->{STATUS}="_PARSE_ATOM_OK";

 	$self->{STATUS}="NOT_VALID_LINE:record_name=$parsed_atom->{record_name} at line=$line" 
			if $parsed_atom->{record_name} eq 'NOT_DEFINED' or $parsed_atom->{record_name}!~ /$line_start/ ;
           
	
	$self->{STATUS}="NOT_VALID_LINE:atom_serial_number=$parsed_atom->{atom_serial_number} at line=$line" 
			if $parsed_atom->{atom_serial_number} eq 'NOT_DEFINED'    or     $parsed_atom->{atom_serial_number}!~/^\d+$/;

 	$self->{STATUS}="NOT_VALID_LINE:atom_name=$parsed_atom->{atom_name} at line=$line"  
			if $parsed_atom->{atom_name} eq 'NOT_DEFINED'  or     $parsed_atom->{atom_name}!~/^[A-Z][A-Z\d]{0,3}$/i;

 	$self->{STATUS}="NOT_VALID_LINE:altloc=$parsed_atom->{altloc} at line=$line"         
			if defined $parsed_atom->{altloc}          and  
                                   $parsed_atom->{altloc} ne ''    and 
                                   $parsed_atom->{altloc} !~ /^[A-Z]$/i;
	
	if ($parsed_atom->{record_name}=~/^ATOM/){	
		if ($parsed_atom->{resname} eq 'NOT_DEFINED' or 
			not exists $amino_acids->{$parsed_atom->{resname}}){
			#TODO amino acid validation
			$self->{STATUS}="NOT_VALID_LINE:resname=$parsed_atom->{resname} at line=$line"
		}
	}

 	$self->{STATUS}="NOT_VALID_LINE:chain_id='$parsed_atom->{chain_id}' at line=$line"
			if defined $parsed_atom->{chain_id}          and  
                                   $parsed_atom->{chain_id} ne ''    and 
                                   $parsed_atom->{chain_id} !~ /^.+$/;
	                       

 	$self->{STATUS}="NOT_VALID_LINE:resseq=$parsed_atom->{resseq} at line=$line" 
			if  $parsed_atom->{resseq}  eq 'NOT_DEFINED'  or     $parsed_atom->{resseq}!~/^[-]?\d+$/;


 	$self->{STATUS}="NOT_VALID_LINE:X=$parsed_atom->{X} at line=$line" 
			if $parsed_atom->{X} eq 'NOT_DEFINED'  or   $parsed_atom->{X}!~/^[+-]?\d+(\.\d+)?$/;

 	$self->{STATUS}="NOT_VALID_LINE:Y=$parsed_atom->{Y} at line=$line" 
			if $parsed_atom->{Y} eq 'NOT_DEFINED'  or     $parsed_atom->{Y}!~/^[+-]?\d+(\.\d+)?$/;

 	$self->{STATUS}="NOT_VALID_LINE:Z=$parsed_atom->{Z} at line=$line"
			if $parsed_atom->{Z} eq 'NOT_DEFINED'  or     $parsed_atom->{Z}!~/^[+-]?\d+(\.\d+)?$/;

 	$self->{STATUS}="NOT_VALID_LINE:occupancy=$parsed_atom->{occupancy} at line=$line" 
	                if defined $parsed_atom->{occupancy}          and  
                                   $parsed_atom->{occupancy} ne ''    and 
                                   $parsed_atom->{occupancy} !~ /^[+-]?\d+(\.\d+)?$/;


	unless ($self->{STATUS} eq '_PARSE_ATOM_OK'){
		return undef; 
	}

	return $parsed_atom; 

}	# ----------  end of subroutine parsed_atom  ----------

sub _warn { 
	my $self= shift;
	warn @_ if $self->{_warn_on_validation_error} eq 'ON' ;
}

sub new {
	
	my ($class,$filename,$show_prograss)	
				= (shift,shift,shift);
	my $self 		= {file_name=>$filename};
	unless ( -f $filename){
	    warn "Error: no such file '$filename'"; 
            return undef;
	}
	
	bless $self, $class;
	$self->{pdb}		=['MODEL_No_ZERO_NOT_EXISTS']; # empty list of proteines
	$self->{peptides}   	= [];

	my @L          = read_file $filename;
	chop @L;
	$self->{lines} 				= \@L;
	$self->{model_index}			= 1;
	$self->{_warn_on_validation_error}	= 'OFF';
	$self->{_parse_also_hetatm}		= undef;
	$self->{_show_prograss}			= $self->set_show_prograss($show_prograss);
	$self->{STATUS} = 'NEW_OK';
	return $self;
}	# ----------  end of subroutine new  ----------


sub set_warn_on_validation_error {
	my $self = shift;
	$self->{_warn_on_validation_error}=shift||'OFF';

}

sub set_show_prograss {
	my $self = shift;
	$self->{_show_prograss}=shift||'ON';

}



sub set_parse_also_hetatm {
	my $self = shift;
	$self->{_parse_also_hetatm}=shift||undef;

}

sub get_status {
	my $self = shift;
	return $self->{STATUS};
}	# ----------  end of subroutine get_status  ----------

sub find_next_line_number_with_the_string {
	my $self 	= shift;
	my $lines	= shift;
	my $curr_index	= shift;
	my $string	= shift;
	my $func_name   = "find_next_line_number_with_the_string";
	$self->{STATUS} = "$func_name:DID_NOT_FIND:$string";
	my $ret_index	;
	for (my $i = $curr_index; $i<scalar @$lines; $i++){
		if ( defined $lines->[$i] and $lines->[$i] =~/$string/ ){
			$self->{STATUS} = "$func_name:FOUND_STRING_OK";
			$ret_index = $i;
			last;
		}
		
	}

	
	return $ret_index;

}	# ----------  end of subroutine find_next_line_number_with_the_string  ----------

sub find_prev_line_number_with_the_string {
	my $self 	= shift;
	my $lines	= shift;
	my $curr_index	= shift;
	my $string	= shift;
	my $func_name   = "find_prev_line_number_with_the_string";
	$self->{STATUS} = "$func_name:DID_NOT_FIND:$string";
	my $ret_index	;
	for (my $i = $curr_index; $i>=0; $i--){
		if ( defined  $lines->[$i] and   $lines->[$i] =~/$string/ ){
			$self->{STATUS} = "$func_name:FOUND_STRING_OK";
			$ret_index = $i;
			last;
		}
		
	}

	
	return $ret_index;

}	# ----------  end of subroutine find_prev_line_number_with_the_string  ----------

sub _new_model   { return ['ZERO_PEPTIDE_NOT_EXISTS']}
sub _new_peptide { return ['ZERO_ATOM_NOT_EXISTS']   }


sub parse_peptide {
	my $self     = shift;
	my $i	     = shift; # first line number of the peptide
	my $peptide  = _new_peptide;
	
	$self->{STATUS}='START_OF_PARSE_PEPTIDE_LINES';

	my $relative_resseq = 1; # this will be usfule for filtering
	my %prev_atom;
	my $skip_rgxp='^(HETATM|ANISOU)';
	if ($self->{_parse_also_hetatm}){
			$skip_rgxp='^(ANISOU)';
	}
	while ( $self->{lines}->[$i] !~ /^(TER|END|CONECT|MASTER)/){
		my $curr_line = $self->{lines}->[$i];
		if ( defined  $curr_line and  $curr_line =~/$skip_rgxp/){
			$i++;
			next;
		}
		my $atom=$self->_parse_atom($curr_line,$i);
		if (defined $prev_atom{resseq} and $prev_atom{resseq} != $atom->{resseq}){
			$relative_resseq++;
		}
		$atom->{relative_resseq}=$relative_resseq;
		warn "ERROR:". $self->get_status if $self->get_status=~/^NOT_ATOM_LINE/;
		last unless  $self->get_status eq '_PARSE_ATOM_OK';
		push @{$peptide},$atom;	
		%prev_atom=%$atom;
		$i++;
	}
	
	my $connect  = [];
	while( $self->{lines}->[$i] =~/^CONECT/){
		my $curr_line = $self->{lines}->[$i];
		push @$connect,$curr_line;
		$i++;
	}

	dbg "parse_peptide $i ".$self->get_status()."\n";
	# now we should have the peptides atoms as an array
	# the array index is the atom serial number 
	
	$self->{STATUS}="PARSE_PEPTIDE_LINES_ENDED_OK" if $self->get_status eq '_PARSE_ATOM_OK';
	dbg "parse_peptide $i ".$self->get_status()."\n";
	my $prgrs=sprintf "% 3.2f",100*$i/scalar(@{$self->{lines}}-1);
	print "\rparsing file progress: $prgrs%                                  " if $self->{_show_prograss} eq 'ON';
	$self->set_rama_type_of_peptide($peptide);
	$connect = undef if scalar($connect)==0;
	return  ($peptide,$i,$connect);
	
}	# ----------  end of subroutine parse_peptide  ----------

sub set_rama_type_of_atom {
	my $self    = shift;
	my ($atom,$amino)=(shift,shift);
	my $res_hash=$amino->get_all_amino_res_hash();
	my $rama_type;
	my $resseq = $atom->{resseq};
	if (not exists $res_hash->{$resseq+1}){
		$atom->{rama_type}='GENERAL';
		return;
	}
	my $next_amino= $res_hash->{$resseq+1};
	if ($atom->{resname}=~/GLY/){
		$rama_type='GLY';
	}
	elsif ($atom->{resname}=~/PRO/){
		$rama_type='PRO';
	}
	elsif ($next_amino=~/PRO/){
		$rama_type='PRE_PRO';
	}
	else{
		$rama_type='GENERAL';
	}

	$atom->{rama_type}=$rama_type;

}	# ----------  end of subroutine set_rama_type_of_atom  ----------

sub set_rama_type_of_peptide {
	my $self    = shift;
	my $peptide = shift;
	my $amino=OpSym::AminoAcid->new($peptide);

	for my $i (1..scalar(@$peptide)-1){
		my $atom=$peptide->[$i];
		$self->set_rama_type_of_atom($atom,$amino)

	}
		

}	# ----------  end of subroutine set_rama_type_of_peptide  ----------

sub parse_file{
	my $self = shift;
	my $lines   = $self->{lines};
	my $i=-1;

	$self->{STATUS}='PARSE_FILE-NO_DATA';
	# find header_till_first_remark
	$i=-1;
	$i=$self->find_next_line_number_with_the_string($lines,$i,"^REMARK");
	$self->{_HEADER_TILL_FIRST_REMARK}=$i-1 if $self->get_status()=~/OK$/;
	
	

	#find the begining of atoms lines
	$i=-1;
	$i=$self->find_next_line_number_with_the_string($lines,$i,"^(MODEL|ATOM|HETATM|ANISOU)");
	$self->{_ATOMS_STRAT_MARK}=$i;
	my $models_index = 1;
	# iterate while there are atoms lines on models
	while ($i< scalar @{$lines} and $self->get_status()=~/FOUND_STRING_OK/){
		if ($lines->[$i]=~/^MODEL/){
			$i=$self->find_next_line_number_with_the_string($lines,$i,"^(ATOM|HETATM|ANISOU)");
			last unless $self->get_status()=~/FOUND_STRING_OK/;
		}

		my $model  = _new_model();
		my $peptide = _new_peptide();
		my $connect;
		my $old_status;
		# iterate while there are peptides in the model
		while ($lines->[$i]=~/^(ATOM|TER|HETATM|ANISOU|END)/){			
#                       print "parse_file:$i ==>'$lines->[$i]'\n";
			# exit loop if there are no more peptides 
			# (if has no more atoms lines till the end of the file) 
			$old_status= $self->get_status;
			my $line_start='^ATOM';
			if ($self->{_parse_also_hetatm}){
				$line_start='^(ATOM|HETATM)';
			}
			$self->find_next_line_number_with_the_string($lines,$i,$line_start);
			unless ($self->get_status()=~/FOUND_STRING_OK/){
				$i=scalar @$lines;
				$self->{STATUS}=$old_status;
				last ;
			}

			my $prev_i=$i;
			($peptide,$i,$connect)=$self->parse_peptide($i);
			if ($self->get_status eq 'PARSE_PEPTIDE_LINES_ENDED_OK'){
				push @$model, $peptide;
				if ($self->get_number_of_peptides($model) ==1) {
					$self->{STATUS}='PARSE_FILE_OK-SINGLE_PEPTIDE';
				}
				elsif ($self->get_number_of_peptides($model) > 1) {
					$self->{STATUS}='PARSE_FILE_OK-MULTY_PEPTIDE';
				}
				else{

					$self->{STATUS}='PARSE_FILE-UNEXPECTED_ERROR';
				}

			}
			else{
				$self->{STATUS}="PARSE_FILE_ERROR-PEPTIDE_ERROR_LINES: $prev_i-$i".
						 $self->{STATUS};
				return $self->get_status; # this indicates that status is error
			}

			# peptide was parsed if there was TER line move to the next
			if ( $lines->[$i]=~/^TER/){
				$i++; # dont change the status there are more peptides
			}
				
			while ($lines->[$i]=~/^(CONECT|MASTER)/){
				$i++; # if exists CONECT or MASTER section jump over them to the end 
			}

			# if this is end of module  -
			# 	- set the status 
			# 	- move to the next line 
			# 	- exit peptides loop 
			#  so if  this is the last model - then ENDMDL\nEND
			#  and  we will exit the loop 
			if ($lines->[$i]=~/^ENDMDL/){
				$i++; # so if this is the last model then $lines->[$i]=
				$self->{STATUS}.='-END_OF_MODEL_OK';
				last;
			}

			# if this line is END line exit the p
			if ( not defined $lines->[$i] or $lines->[$i]=~/^END/ and not $lines->[$i]=~/^ENDMDL/){
				if ($self->get_number_of_peptides($model) ==1) {
					$self->{STATUS}='PARSE_FILE_OK-SINGLE_PEPTIDE';
				}
				elsif ($self->get_number_of_peptides($model) > 1) {
					$self->{STATUS}='PARSE_FILE_OK-MULTY_PEPTIDE';
				}
				else{
					$self->{STATUS}='PARSE_FILE-UNEXPECTED_ERROR';
				}
				last;
			}
		} # --end of peptides in model
		print "\rparsing file progress: 100.00%                                " if $self->{_show_prograss} eq 'ON';


		# inserting the model into ${pdb} if exists
		$self->{pdb}->[$models_index]=$model if $model->[1]; 
		$self->{connect}->[$models_index]=$connect if $connect->[1]; 
		$self->{STATUS}.='-MULTY_MODELS' if $models_index>1;
		$models_index++;

		$old_status= $self->get_status;

		last if not defined $lines->[$i] or $lines->[$i]=~/^END/;
		
		$i=$self->find_next_line_number_with_the_string($lines,$i,"^(MODEL|ATOM|HETATM|ANISOU)");
		
		if ($self->get_status()=~/FOUND_STRING_OK/){
			next;
		}
		else{
			$self->{STATUS} = $old_status;
			last;
		}

	} # -- ehd of atoms an models	
	$self->validate_pdb_stracture();
	print "\n" if $self->{_show_prograss} eq 'ON';
	return $self->get_status;
}	# ----------  end of subroutine parse_file  ----------

sub set_gaps_in_data {
	my $self = shift;
	my $gap_type =shift; #'resseqs_numbers',
	my $model_number=shift;
	my $peptide_number=shift;
	my ($start,$end)= (shift,shift);
	my $str_gap;
	#warn "strat=$start;end=$end";
	if ($start+2==$end){
		$str_gap=sprintf "%5s",$start+1;
	}
	else{
		$str_gap=sprintf "%5s-%s",$start+1,$end-1;

	}
	$self->{gaps_in_data}->{$model_number}->{$peptide_number}->{$gap_type}->{$str_gap}=1;
	return;
}
sub gaps_report_text{
	my $self = shift;
	my $gap_report_text="";
	my $gr=$self->{gaps_in_data};
	my @indent=("\t");
	my $indent_str;
	for my $model_index (sort keys %$gr){
		my $model_gaps=$gr->{$model_index};
		$indent_str=join "", @indent;
		$gap_report_text .=  "$indent_str model index=$model_index\n"; 
		push @indent,"\t";

		for my $peptide_index ( sort keys %$model_gaps){
			my $paptide_gaps=$model_gaps->{$peptide_index};
			$indent_str=join "",@indent;
			$gap_report_text .= "$indent_str peptide_index index=$peptide_index\n"; 
			push @indent,"\t";
			my @gaps_list;
			for my $gap_type ( sort keys %$paptide_gaps){
				$indent_str=join "",@indent;
				$gap_report_text .= "$indent_str $gap_type: "; 
				@gaps_list =sort keys %{ $paptide_gaps->{$gap_type} };
				$gap_report_text .= join (",",@gaps_list)."\n";
			}
			pop @indent;

		}
		pop @indent;
	}

	return "gaps in data:\n".$gap_report_text;
}	# ----------  end of subroutine gaps_report ----------

sub pdb_stracture_has_gaps{
	my $self =shift;
	return exists $self->{gaps_in_data};

}	# ----------  end of subroutine pdb_stracture_has_gaps ----------

sub validate_atom {
	# check that a given atom has valid 
	# atom_serial_number 
	my $self = shift;
	my $atom = shift;
	my $last_atom_serial = shift;

	my $expected_atom_serial= $last_atom_serial+1;
	my $atom_serial_number  = $atom->{atom_serial_number};
	if ($atom_serial_number != $expected_atom_serial){
		$atom->{gap_in_serial_number}='END_GAP';
		$self->_warn (
			"\nWARN: line '$atom->{line_index}': '$atom->{orig_line}'\n".
		     	"          atom serial  : '$atom_serial_number'\n".
		     	"        but expecting  : '$expected_atom_serial'\n"
	     	);
	}


	return ($atom_serial_number)
}	# ----------  end of subroutine validate_atom  ----------

sub _mark_resgaps {
	# input peptide
	# output list of gaps (array)
	#  a=(_,1,1,1,2,2,4,4,4  )
	#  b=(_,_,1,1,1,2,2,4,4,4)
	#a-b=(_,_,0,0,1,0,2,0,0)
	#gaps end where a-b >1
	#gaps starts on the first 1 before gaps end
	#    (_,_,_,_,S,S,E,E,E)
	my $self    = shift;
	my $peptide = shift;
	my $model_number=shift;
	my $peptide_number=shift;
	my (@a,@b,@a_minus_b);
	for my $atom_index (1..scalar(@$peptide)-1){
		$a[$atom_index] = $peptide->[$atom_index]->{resseq};
	}
	@b=@a;
	unshift @b,undef;
	for my $i (1..$#a){
		if (not defined $a[$i] or not defined $b[$i]){
			$a_minus_b[$i]= undef;
		}
		else{ 
			$a_minus_b[$i]=$a[$i]-$b[$i];
		}
	}

	my @gaps_arr; # just for debug
	my $in_gap;
	for my $i (reverse 2..$#a_minus_b) {
		if ($a_minus_b[$i] >1){
			$peptide->[$i]->{gap_in_resseq}='END_GAP';
			$gaps_arr[$i]='E';
			$in_gap=1;
		}
		elsif ($a_minus_b[$i] == 1 and $in_gap ){
			#gaps starts on the first 1 before gaps end
			$peptide->[$i]->{gap_in_resseq}='START_GAP';
			$gaps_arr[$i]='S';
			$in_gap=undef;

		}
		elsif ($a_minus_b[$i] == 0 and $in_gap ){
			$peptide->[$i]->{gap_in_resseq}='START_GAP';
			$gaps_arr[$i]='S';
		}

	}
	# at this stage 
	#a-b=(_,_,0,0,1,0,2,0,0)
	#but gaps_arr look like this:
	#    (_,_,_,_,S,S,E)
	# so we need to mark E to the end of the gaps
	$in_gap=undef;
	for my $i ( 2..$#a_minus_b) {
		if ($a_minus_b[$i] >1 and $gaps_arr[$i] ne 'E'){
			warn "This is a bug in _mark_resgaps method. a_minus_b[$i] >1 but no gaps_arr[$i] ne 'E'";

		}
		elsif ($a_minus_b[$i] >1 ){
			$in_gap=1;
		}
		elsif ($a_minus_b[$i] == 1 and $in_gap ){
			#gap ended 
			$in_gap=undef;

		}
		elsif ($a_minus_b[$i] == 0 and $in_gap ){
			$peptide->[$i]->{gap_in_resseq}='END_GAP';
			$gaps_arr[$i]='E';
		}

	}
	sub nvl{ my $n=shift; return (defined $n ?$n : '-');}
	$in_gap=undef;
	my ($start,$end);
	for my $i (1..$#a){
#		warn sprintf "%5s %5s %5s %5s %5s\n",$i,
#			nvl($a[$i]),  
#			nvl($b[$i]),  
#			nvl($a_minus_b[$i]),  
#			nvl($gaps_arr[$i]);
		if (nvl($gaps_arr[$i]) eq 'S' and not defined $in_gap){
			# (..... undef,'S'...)
			$start = $peptide->[$i]->{resseq};
			$in_gap=1;
#		warn sprintf "$i => %s\n",join (",",@gaps_arr[$i..$i+20]);
		}
		elsif (nvl($gaps_arr[$i]) eq 'E' and not defined $gaps_arr[$i+1]){
			# (..... undef,'S','S','E','E', undef...)
			$end = $peptide->[$i]->{resseq};
			$self->set_gaps_in_data('resseqs_numbers',$model_number,$peptide_number,$start,$end);
			$in_gap=undef;
		}

	}
	return $peptide;

}

sub validate_peptide{
	my $self = shift;
	my $peptide= shift;
	my $last_atom_serial=shift;
	my ($model_number,$peptide_number) = (shift,shift);
	return unless (ref $peptide eq 'ARRAY');
	my $atom_index=-1;
	$peptide= $self->_mark_resgaps($peptide,$model_number,$peptide_number);

	for my $atom (@$peptide){
		$atom_index++;
		if ($atom_index==0){
			next;
		}
		my $expexted_serial=$last_atom_serial+1;
		$last_atom_serial=$self->validate_atom($atom,$last_atom_serial);
		
		if (exists $peptide->[$atom_index]->{gap_in_serial_number}){
			my ($start,$end)=( $expexted_serial,$atom->{atom_serial_number}-1);
			$self->set_gaps_in_data('atoms_indexes',$model_number,$peptide_number,$start,$end);
		}

	}

	return $last_atom_serial;

}	# ----------  end of subroutine validate_peptide  ----------


sub validate_model{
	my $self = shift;
	my $model= shift;
	my $model_number= shift;
	my ($last_resseq,$last_atom_serial)=(0,0);
	return unless (ref $model eq 'ARRAY');

	# warn if first atom serial number is not 1 or first atom resseq is not 1
	my $first_pepdite=$self->get_peptide_by_number($self->get_model_by_number(1),1);
	my $first_atom=$first_pepdite->[1];
	$self->validate_atom($first_atom,0,0);

	my $peptide_number=-1;
	for my $peptide (@$model){
		$peptide_number++;
		if ($peptide_number==0){
			next;
		}
		$last_resseq=0;
		$last_atom_serial = $self->validate_peptide($peptide,$last_atom_serial,$model_number,$peptide_number);
		$last_atom_serial++; # here came TER line so we increse by 1

	}
}	# ----------  end of subroutine validate_model  ----------

sub validate_pdb_stracture {
# for each model in $self->{pdb}
#  	validate_model
#  		for each peptide in model validate_peptide
#			validate_atom  			
#  	VALIDATION_REPORT:
#  		ststistic data:
#  		number of models: XXX
#  		model No. i
#  			number of peptides:
#  			number of atoms:
#  		model No. 2 ....
#
#  		Errors
#  			
#
	my $self = shift;
	my $pdb=$self->{pdb};
	my $model_number=-1;
	for my $model (@$pdb){
		$model_number++;
		if ($model_number==0){
			next;
		}
		$self->validate_model($model,$model_number);
	}
	return $self->{VALIDATION_REPORT}

}	# ----------  end of subroutine validate_pdb_stracture  ----------

sub get_validation_report {
	my $self = shift;
	my $vr=$self->{VALIDATION_REPORT};
	my $newline=$\;
	my $vr_text="VALIDATION_REPORT:";

	$\=$newline;
	return $vr_text;
}	# ----------  end of subroutine  get_validation_report  ----------

sub get_number_of_models{
	my $self = shift;
	return scalar @{$self->{pdb}}-1;
	
}	# ----------  end of subroutine get_number_of_models  ----------

sub get_number_of_peptides{
	my $self = shift;
	my $model= shift;
	my $tmp = shift;
	return scalar @{$model} -1 ; # the first item in the array is: ZERO_ATOM_NOT_EXISTS
	
}	# ----------  end of subroutine get_number_of_models  ----------

sub get_peptide_by_number{
	my $self           = shift;
	my $model          = shift;
	my $peptide_number = shift;
	#TODO change status if not valid
	if (not defined $model){
		warn "model is not defiend";
	}
	elsif (ref $model ne ref [] ){
		warn "model is not valid";
	}
	elsif( not defined $model->[$peptide_number]){
		warn "model has  no peptide number $peptide_number";
	}

	return $model->[$peptide_number];
	
}	# ----------  end of subroutine get_peptide_by_number  ----------

sub get_model_by_number{
	my $self           = shift;
	my $model_index    = shift;
	my $model          = $self->{pdb}->[$model_index];
	$self->{STATUS}    = "ERROR:MODEL_NUMBER_${model_index}_DOES_NOT_EXSISTS" unless defined $model;
	return $model;
	
}	# ----------  end of subroutine get_model_by_number  ----------



sub get_connect_by_number{
	my $self           = shift;
	my $model_index    = shift;
	my $connect          = $self->{connect}->[$model_index];
	$self->{STATUS}    = "ERROR:MODEL_NUMBER_${model_index}_DOES_NOT_EXSISTS" unless defined $connect;
	return $connect;
	
}	# ----------  end of subroutine get_connect_by_number  ----------



sub get_peptide_chain_id{
	my $self           = shift;
	my $peptide        = shift;
	my $peptide_index  = shift;
	my $chain_id          = $peptide->[1]->{chain_id};
	$self->{STATUS}    = "ERROR:PEPTIDE NUMBER ${peptide_index}_DOES_NOT_HAVE_CHAIN_ID" unless defined $chain_id;
	return $chain_id;
	
}	# ----------  end of subroutine get_model_by_number  ----------


sub get_next_model {
	my $self = shift;
	return $self->get_model_by_number($self->{model_index}++);
}	# ----------  end of subroutine get_next_model  ----------

sub get_ter_line {
	my $self    = shift;
	my $peptide = shift;
	my $ter_index=$peptide->[scalar (@$peptide) -1]->{line_index} + 1;
	return $self->{lines}->[$ter_index];
}	# ----------  end of subroutine get_ter_line  ----------

sub create_ter_line {
	my $self       = shift;
	my $atoms_list = shift;
	my $last_atom  = $atoms_list->[ $#$atoms_list];
	#012345678901234567890123456
	#TER      25      GLY     3
	#                           12345678901234567890123456
	my $ter_line             = 'TER                       ';
	substr($ter_line, 7-1, 5)  = sprintf ("%5d", $self->{_atoms_index});
	substr($ter_line,18-1, 3)  = sprintf ("%3s", ($last_atom->{resname}? $last_atom->{resname} : " " ));
	substr($ter_line,23-1, 4)  = sprintf ("%4s", ($last_atom->{resseq} ? $last_atom->{resseq}  : " " ));
	$self->{_atoms_index}++;
	return $ter_line;
}	# ----------  end of subroutine create_ter_line  ----------

sub which_resname{
	my $self         = shift;
	my $atoms_list   = shift;
	return $atoms_list->[2]->{resname};
}	# ----------  end of subroutine which_resname  ----------

sub which_resseq{
	my $self         = shift;
	my $atoms_list   = shift;
	return $atoms_list->[2]->{resseq};
}


sub peptides_list2pdb {

	my $self         = shift;
	my $peptides_list= shift;
	my $model_number = shift;
	my $reset_atom_index = shift;
	my $with_connect = shift;
	my $no_ter_line  = shift;

	$with_connect='FALSE' unless $with_connect;
	$reset_atom_index='FALSE' unless $reset_atom_index;

	my $connect	 = $self->get_connect_by_number($model_number) if $with_connect eq 'WITH_CONNECT';
	my $last_index   = scalar(@$peptides_list)-1;
	my $line         = "";
	my $pdb          = "";
	my $first_index =  (ref ($peptides_list->[0]) eq ref([]) ? 0 : 1 );
	for my $i ($first_index..$last_index){
		my $atoms_list = $peptides_list->[$i];
		$pdb    .=$self->atoms_list2pdb($atoms_list,$model_number,'DONT_APPEND_END_LINE',$reset_atom_index,$no_ter_line);
	}
	#      1234567
	#MODEL       2
	$connect =[] unless $connect;
	my $connect_str=join("\n",@$connect);
	$connect_str.="\n" if length($connect_str)>0 and substr($connect_str,-1) ne "\n";
	$pdb    = sprintf("MODEL %7d\n${pdb}%sENDMDL\n",$model_number,$connect_str) if $model_number;
	$pdb   .= "END\n";

	return $pdb;	

}	# ----------  end of subroutine peptides_list2pdb  ----------

sub atoms_list2pdb {
	my $self             = shift;
	my $atoms_list       = shift;
	my $model_number     = shift;
	my $append_end_line  = shift;
	my $reset_atom_index = shift;
	my $no_ter_line      = shift;
	$reset_atom_index    ='FALSE' unless $reset_atom_index;

#	print  Dumper "atoms_list:",$atoms_list;
#	print  Dumper "model_number",$model_number;
#	print  Dumper "append_end_line",$append_end_line;
#	print  Dumper "reset_atom_index",$reset_atom_index;


	if (not $self->{_atoms_index} or $reset_atom_index eq 'RESET_ATOM_INDEX'){
		$self->{_atoms_index}=1;
	}
	$append_end_line=($append_end_line ? "FALSE" : "TRUE");
	my $last_index   = scalar(@$atoms_list)-1;
	my $line         = "";
	my $pdb          = "";
	my $first_index =  (ref ($atoms_list->[0]) eq ref({}) ? 0 : 1 );
	for my $i ($first_index..$last_index){
		my $atom = $atoms_list->[$i];
		$line    = $atom->{orig_line};
#print  Dumper "_atoms_index",$self->{_atoms_index};
#print  Dumper "atom",$atom;
#print "line='$line'\n";
		substr($line,6,5) = sprintf "%5d",$self->{_atoms_index};
		$self->{_atoms_index}++;
		$pdb    .="$line\n";
	}
	if ($no_ter_line){
		$line         = "";
	}
	else{
		$line   =  $self->create_ter_line($atoms_list);
	}
	chomp $line;
	$pdb   .= "$line\n" if $line=~/\S/;
	#      1234567
	#MODEL       2
	$pdb    = sprintf("MODEL %7d\n${pdb}ENDMDL\n",$model_number)  if $model_number and $append_end_line eq 'TRUE';
	$pdb   .= "END\n" if $append_end_line eq 'TRUE';
	return $pdb;	
}	# ----------  end of subroutine atoms_list2pdb   ----------

sub atoms_list2xyz{
	my $self        = shift;
	my $atoms_list  = shift;
	my $comment     = shift || '';
	my $noa         = scalar(@$atoms_list)-1;
	my $xyz         = "$noa\n# $comment\n";
	for my $i (1..$noa){
		my $atom      = $atoms_list->[$i];
		my $atom_name = $atom->{atom_name};
		$atom_name=~s/^([A-Z][a-z]?)[A-Z0-9]+/$1/;
		$xyz    .= sprintf "%-4s%10s%10s%10s\n",$atom_name,$atom->{X},$atom->{Y},$atom->{Z};
	}
	return $xyz;
}	# ----------  end of subroutine atoms_list2xyz   ----------

1;
