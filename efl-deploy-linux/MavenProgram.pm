package MavenPackage;    # Nom du package, de la classe

use warnings;        # Avertissement des messages d'erreurs
use strict;          # Vérification des déclarations

use XML::LibXML;

# j'utilise une globale, pourquoi pas ?
my $flavor = "normal";

sub new {
  my ( $class, $r_programBo ) = @_;
  my $this = {};  
  
  my $config_file_name = "/usr/local/eip/share/config/program.conf.xml";
  
  my $programName = $r_programBo->get("program");
  
  my $xmlDocument = XML::LibXML->load_xml(location => $config_file_name);
  my $xmlRoot = $xmlDocument->documentElement(); 
  my $nodes = ($xmlRoot->findnodes('//configuration[programId="' . $programName . '"]'))[0];  

  die "impossible de trouver la configuration pour le program $programName dans $config_file_name" if (! defined $nodes);  
  
  $this->{"g"} = ($nodes->getChildrenByTagName('group'))[0]->textContent;
  $this->{"e"} = ($nodes->getChildrenByTagName('extension'))[0]->textContent;
  $this->{"c"} = ($nodes->getChildrenByTagName('classifier'))[0]->textContent;
  $this->{"a"} = $programName;
  $this->{"v"} = $r_programBo->get("version");
  $this->{"r"} = $r_programBo->isSnapshot() ? "snapshots" : "releases";

  my @flavorNodes = $nodes->getChildrenByTagName('flavor');
  
  if (@flavorNodes) {
	$flavor = $flavorNodes[0]->textContent();
  }  
  
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

sub getFlavor {
	return $flavor;
}

sub getHashRef() {
	# passons la Ref
	my $self = shift;	
	return $self;
}

1;                # Important, à ne pas oublier

