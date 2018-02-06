package DeployProgramArgument;    # Nom du package, de notre classe

use warnings;        # Avertissement des messages d'erreurs
use strict;          # Vérification des déclarations

# use DateTime;

use POSIX;
use File::Basename;

use JIRA::REST;

# use File::Basename;

my $deployLogFileName = "/usr/local/eip/deploy.log";

sub new {
  my ( $class, $r_argv) = @_;
  my $this = {};  
  
  my @env = ("dev", "int", "recette", "chaine", "prodbackup", "test", "prod");
  my @snap_env = ("dev", "int");
  
  die "le programme doit avoir en paramètre le nom du program à déployer" unless @{$r_argv};
  
  if (@{$r_argv} == 1) {
    $this->{"program"} = @{$r_argv}[0];
    $this->{"env"} = "dev";
    $this->{"version"} = "LATEST";
    $this->{"isSnapshot"} = 1;
	$this->{"jira"} = "undef"; 
  } else {
	my @debugLines;
    for my $word (@{$r_argv}) {		
		if ($word =~ /^(sie[a-z]+-)?\d+$/i) {
			if ($1)  {
				push @debugLines, "$word est interprété comme la JIRA \n";
				$this->{"jira"} = $word;
			} else {				
				push @debugLines, "$word est interprété comme le numéro de JIRA du projet siechaine\n";
				$this->{"jira"} = "siechaine-" . $word;
			}
		} elsif ($word =~ /^\d+\.\d+\.\d+.*?(-snapshot)?$/i) {
			$this->{"version"} = $word;	            		    
			
			if ($1)  {
				push @debugLines, "$word est interprété comme la version : numéro de snapshot \n";
				$this->{"isSnapshot"} = 1;
			} else {
				push @debugLines, "$word est interprété comme la version : numéro de release \n";
				$this->{"isSnapshot"} = 0;
			}
		} elsif (grep( /^$word$/, @env)) { # 
		  $this->{"env"} = $word;
		  push @debugLines, "$word est interprété comme l'environnement\n";
		} else {
		  $this->{"program"} = $word;
		  push @debugLines, "$word est interprété comme le nom du programme \n";
		}
	}  	
	
	$this->{"env"} = "dev" if (!exists $this->{"env"});

    if (!exists $this->{"version"}) {            
      $this->{"version"} = "LATEST";
      $this->{"isSnapshot"} = 1;
    }
	
	if (!exists $this->{"jira"}) {            
      $this->{"jira"} = "undef";      
    }
	
	if (keys %{$this} != 5) {
		for my $line (@debugLines) { print $line};
	  die "impossible d'interpréter la ligne de commande pour déterminer le programme à déployer, sa version, et l'environnement cible";
	}
	
  }
  
  print "A déployer\n";
  print "----------\n";
  print "programme     : $this->{'program'} \n";
  print "version       : $this->{'version'}\n";
  print "environnement : $this->{'env'}\n";
  
  if ($this->{"jira"} ne "undef") {
	print "jira : $this->{'jira'}\n";
  }
  
  #print "snapshot      : " . $this->{'isSnapshot'} . "\n";
  #print "snap_env      : " . grep( /^$this->{env}$/, @snap_env) . "\n";

  if ($this->{"isSnapshot"} && ! grep( /^$this->{env}$/, @snap_env) ) {
    die "ce programme ne déploie pas de version snapshot en $this->{'env'}";
  }    
  
  bless $this, $class;
  
}

# sub set {
#    my ($self, $name, $value) = @_;
#   $self->{$name} = $value;
# }

sub get {
  my ($self, $name)  = @_;
  return $self->{$name};
}

sub isSnapshot {
  my $self = shift;
  return $self->{'isSnapshot'};
}

sub logDeploy {
  my $self = shift;
  
  open (my $fh, ">>", $deployLogFileName);
  
  #{Time.now.strftime('%Y/%m/%d %H:%M:%S')}|#{to_env.to_s}|#{prog_name}|#{version}|
  #echo $(date "+%Y-%m-%d %H:%M:%S")
  #my $dt   = DateTime->now;   # Stores current date and time as datetime object
  #print $fh, "$dt->hms $dt->ymd|$self->{'program'}|$self->{'version'}";
  
  my $dt = strftime "%F %T", localtime;  
  print $fh "$dt|$self->{'env'}|$self->{'program'}|$self->{'version'}|\n";  
  close $fh;

  # ggl : script directory perl ; 84932
  my $command_line = dirname($0) . "/liste-versions-deployees.sh" ;
  print "$command_line\n";
  system($command_line);
  $command_line = "scp /usr/local/eip/deploy-summary.log srvic:/var/www/sites/tb/statsdeploy.csv";
  print "Veuillez lancer la commande suivante depuis fedora02 pour mettre à jour le tableau des déploiements $command_line\n";
  system($command_line);
}

sub textJira() {
  my $self = shift;
  
  my %color = ("dev"=>"#FFFFFF", "int"=>"#FFB700", "recette"=>"#D0E09D", "chaine"=>"#3A8EBA", "prodbackup"=>"#D0D0D0", "test"=>"#FFFFCE", "prod"=>"#9EC9EC");
  
  my $text =  '{panel:title=Livraison en ' . $self->{'env'} . ' - ' . $self->{'program'} . '|titleBGColor=' . $color{$self->{'env'}} . "}\n";
  $text .= "||Script Shell||Version||\n";
  $text .= '|' . $self->{'program'} . '-' . $self->{'env'} . '| ' . $self->{'version'} . "||\n";  
  
  if ($self->{"jira"} ne "undef") {
	my $jira = JIRA::REST->new('https://jira.els-gestion.eu', 'ext-pdonzel', 'January12;');

	my $issue = $jira->POST('/issue/' . $self->{"jira"} . '/comment', undef, { body  =>  $text });
  } else {
    print $text;
  }
  
}  
  


1;  # Important, à ne pas oublier
