use strict;
use warnings;


package OpSym::Cut::ByAmino_N_CA_C_O;

use strict;
use warnings;
use OpSym::AminoAcid;
use Data::Dumper;
use parent 'OpSym::Cut::Cut';



my $_dbg	= 0;
my $Version	="0.0.3";
sub dbg { print @_,"\n" if $_dbg == 1 }


#sub pass_the_filter {
#
#	my $self         = shift;
#	my $atoms_list	 = shift;
#	dbg  Dumper $atoms_list; 
#	return 1 	 if $atoms_list->[1]->{resname}  eq $self->{filter_pattern}; 
#	return undef;
#
#}

sub grep_N_C_C_O{
	my $self = shift;
	for my $res_index ( 0..scalar(@{$self->{cutting_list}})-1){
		my @full_res =@{$self->{cutting_list}->[$res_index]};
		my @greped_res=();
		for my $atom_record (@full_res){
			push @greped_res,$atom_record if $atom_record->{atom_name}=~/^(N|CA|C|O)$/;
		}
		$self->{cutting_list}->[$res_index]=\@greped_res;

	}
}

sub cut {
	my $self         = shift;
	my $cutting_list = [];
	my $amino_acider = OpSym::AminoAcid->new($self->get_peptide());
	my $cutting 	 = $amino_acider->get_amino_list();
	$self->{cutting_list} = $self->remove_gap_edges($cutting);
	shift @{$self->{cutting_list} };
	pop   @{$self->{cutting_list} };	

	$self->grep_N_C_C_O();
#	print Dumper  $self->{cutting_list};exit;
	$self->{STATUS} = $amino_acider->get_status();
	$self->filter($self->{cutting_list});
	return $self->{cutting_list};
}	# ----------  end of subroutine cut   ----------
1;

