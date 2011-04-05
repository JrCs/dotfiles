#!/usr/bin/perl

use strict;

open(my $fh, "LC_ALL=C git show --name-only  68d001f62a521c14a |") or die $!;

my %changes;
my $current_change;
my $current_filename;
my $header;
while (<$fh>) {
	chomp;
	if (/^\s+\*\s+/) {
		if ($current_change) {
			push @changes, $current_change;
		}
		$current_change=$_;
		$current_change =~ s/\s+$//;
		next;
	}
	if (/^\s+./) {
		if ($current_change) {
			$current_change .= $/ . $_;	
		} else {
			$header .= $/ . $_;
		}
	}
}
push @changes, $current_change if $current_change;


print "Header:".$header,$/;
foreach my $line (@changes) {
	print ">>",$line,$/;
}
