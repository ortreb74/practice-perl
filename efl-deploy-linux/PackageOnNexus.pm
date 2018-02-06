package PackageOnNexus;    # Nom du package, de notre classe

use warnings;        # Avertissement des messages d'erreurs
use strict;          # Vérification des déclarations

my $nexus_url = "http://srvic/nexus/service/local/artifact/maven/redirect";

sub new {
  my ( $class, $r_parameters) = @_;
  my $this = {};  
  
  my %parameters = %{$r_parameters};
  
  foreach my $key (keys(%parameters)) {
	$this->{$key} = $parameters{$key};
  }
  my $parameters = join("&", map { "$_=$parameters{$_}" } keys %parameters);  
  $this->{"parameters"} = $parameters;
  bless $this, $class;
}

sub set {
   my ($self, $name, $value) = @_;
   $self->{$name} = $value;
}

sub get {
	my ($self, $name)  = @_;
	return $self->{$name};
}

sub getUrl() {
	my $self = shift;		
	return"http://srvic/nexus/service/local/artifact/maven/redirect?" . join("&",$self->{"parameters"});
}

1;                # Important, à ne pas oublier
