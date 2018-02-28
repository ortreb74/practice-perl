package SystemFileMeta;    # Nom du package, de notre classe

use warnings;        # Avertissement des messages d'erreurs
use strict;          # Vérification des déclarations

sub new {
	my ( $class, $directory ) = @_; # passage des paramètres
	my $this = {}; # création d'une référence vers un hachage  

	$this->{"flag_readg"} = $1;
	$this->{"flag_writeg"} = $2;
	$this->{"user"} = $3;
	$this->{"file_group"} = $4;
	$this->{"file_name"} = $directory eq "" ? $5 : $directory . "/" . $5;

	bless $this, $class; # pour rendre le hachage différent
}

sub display {
	my $this = shift; # pour se retrouver soi même
	
	my %properties = %{$this};
	
	foreach my $key (keys(%properties)) {
		printf "%-30s : %s\n", $key, $properties{$key};
	}
}

1;                # Important, à ne pas oublier
