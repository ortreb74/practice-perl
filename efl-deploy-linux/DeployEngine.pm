package DeployEngine;    # Nom du package, de notre classe

use warnings;        # Avertissement des messages d'erreurs
use strict;          # Vérification des déclarations

use LWP::Simple;

my $repwork = "/u/progs/wdeploy";

sub new {
  my ( $class, $urlSource ) = @_;
  my $this = {};  

  system ("rm -r $repwork 2>/dev/null");
  system ("mkdir $repwork");
  chdir $repwork;

  my $ua = LWP::UserAgent->new();
  my $response = $ua->get($urlSource);

  print "url : $urlSource \n";
  
  if (! $response->is_success) {
    die "Error: " . $response->status_line;
  }    
			
  my $filename = "tmp.tar.gz";

  unless(open SAVE, '>' . $filename) {
    die "\nCannot create save file '$filename'\n";
  }

  print SAVE $response->decoded_content;
  close SAVE;

  # print "Saved " . length($response->decoded_content) . " bytes of data to $filename\n";

  mkdir "extract";
  chdir "extract";
  system "tar xf ../$filename";
  
   bless $this, $class;
}

sub getExtractDir {
	return $repwork . "/extract";
}

sub deploy {
	my ($self, $r_programBackOffice) = @_;
	
	my $program = $r_programBackOffice->get("program");
	my $env = $r_programBackOffice->get("env");
	
	# le lanceur
	my $idNamespace = ($env ne "prod") ? "-" . $env : "";

	my $command_line = "ls " . $self->getExtractDir() . "/*-local 2>/dev/null";	
	my @shells = qx($command_line);	
	
	if ($#shells ne 0) {
		print "$command_line\n";	
		system ($command_line);	
		die "le package doit contenir un et exactement un lanceur (fichier -local)" ;	
	}
	
	my $shellSrcName = $shells[0];
	chomp($shellSrcName);
	my $shellTargetName = "/usr/local/eip/shells/" . $program . $idNamespace;		
	
	system("cp " . $shellSrcName . " " . $shellTargetName);
	system("rm " . $shellSrcName);	
	
	# le programme
	my $directoryTargetName = ($env ne "dev") ? "/usr/local/eip/bin" . $idNamespace : "/u/progs/eip/bin";	
	$directoryTargetName .= "/" . $program;
	
	system("rm -r $directoryTargetName");
	system("mkdir $directoryTargetName");
	
	system("cp -rp * " . $directoryTargetName);
	
	# cette ligne permet de donner le droit d'écrire au groupe wheel dans les répertoires qui ont la chaine tmp dans le nom
	system("find $directoryTargetName" . ' -type d -name \*tmp\* -exec chmod g+w {} \;');
}

sub deployHtmlTransformation {
	my ($self, $r_programBackOffice) = @_;
	
	my $program = $r_programBackOffice->get("program");
	my $env = $r_programBackOffice->get("env");
	
	# le programme
	my $idNamespaceTransfo = ($env ne "prod") ? $env : "";
	
	my $directoryTargetName = ($env ne "dev") ? "/e8/webbu" . $idNamespaceTransfo . "/uaur/xsl" : "/u/progs/webbudev/uaur";			
	
	#--links                 copie les liens symboliques comme liens symboliques
	#--times                 préserve les dates
	#--whole-file            le fichier entier est envoyé tel quel. Le transfert peut être plus rapide...
	#--recursive             visite récursive des répertoires
	
	my $command_line = "rsync --checksum --links --times --whole-file --recursive xsl $directoryTargetName";	
	system($command_line);
	$command_line = "rsync --checksum --links --times --whole-file --recursive css $directoryTargetName/www";	
	system($command_line);
}

sub deployWindows {	
	my ($self, $name, $value) = @_;
	foreach my $subdir ("jar","css","xslt","vba") { system "rm -r //nas003/EFLPROD/Navis/mem2doc/$subdir" };	
	system 'cp -r . //nas003/EFLPROD/Navis/mem2doc';	
	system 'rm -r //nas003/EFLPROD/Navis/mem2doc/tmp';
}

1;                # Important, à ne pas oublier