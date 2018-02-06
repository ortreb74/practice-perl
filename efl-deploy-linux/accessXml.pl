#!/usr/bin/env perl

# package ProgramConfiguration;  

use strict;
use warnings;


use XML::LibXML;

my $program = $ARGV[1];

my $xmlDocument = XML::LibXML->load_xml(location => $ARGV[0]);

my $xmlRoot = $xmlDocument->documentElement();

my $nodes = ($xmlRoot->findnodes('//configuration[programId="' . $program . '"]'))[0];

die "impossible de trouver la configuration pour le program $program dans $ARGV[0]" if (! defined $nodes);

my %h;

$h{"g"}  = ($nodes->getChildrenByTagName('group'))[0]->textContent;
$h{"e"}  = ($nodes->getChildrenByTagName('extension'))[0]->textContent;
$h{"c"}  = ($nodes->getChildrenByTagName('classifier'))[0]->textContent;

print "$_ $h{$_}\n" for (keys %h);

print $h{"g"};

