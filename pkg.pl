#!/usr/bin/perl

package pkg;

$txt = "pkg ";

sub speak {
  print "$txt Success!\n";
}

package main;

print $pkg::txt, "\n";
pkg::speak();
$pkg::txt = "main ";
print $pkg::txt, "\n";
pkg::speak();

