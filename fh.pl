#!/usr/bin/perl

use strict;
use fh;

open( FF, ">fht" ) or die "Failed creating fht: $!";
print FF "One\n";
close FF;

print "getx: ", fh::getx(), "\n";

fh::putx "Two\n";

print "getx: ", fh::getx(), "\n";

fh::putx "Three\n";

system "cat fht";
