#!/usr/bin/perl
use strict; 
use warnings; 

use PackageOnNexus;
use MavenProgram;
use DeployProgramArgument;
use DeployEngine;

# former l'URL
die "le programme prend le nom du programme à déployer en premier paramètre" if (scalar @ARGV == 0);

my $arguments = DeployProgramArgument->new(\@ARGV);

my $mavenProgram = MavenPackage->new($arguments);
my $package = PackageOnNexus->new($mavenProgram->getHashRef());
my $deployEngine = DeployEngine->new($package->getUrl());

if ($mavenProgram->getFlavor() eq "other") {
	$deployEngine->otherDeployment($arguments);
	exit 0;
}

my $program = $arguments->get("program");
my $env = $arguments->get("env");

if ($mavenProgram->getFlavor() eq "manual") {
	print "$program dépackagé en $deployEngine->getExtractDir() ; le reste de l'installation doit être réalisé manuellement\n";
	exit 0;
}

if ($mavenProgram->getFlavor() eq "Transformation HTML") {
	print "deploiement du program de transformationHtml $program en $env\n";
	$deployEngine->deployHtmlTransformation($arguments);
	$arguments->logDeploy();
	$arguments->textJira();
	exit 0;
}

print "deploiement du program $program en $env\n";
$deployEngine->deploy($arguments);

$arguments->logDeploy();
$arguments->textJira();