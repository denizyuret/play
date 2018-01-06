#!/usr/bin/perl -w
# Read pbn game notation, count bids
# Based on http://www.tistis.nl/pbn/pbn_v21.txt
use strict;
use Data::Dumper;

my %bid;
my %bad;
my $auction = 0;
my @history = ();
while(<>) {
    push(@history, $_);
    shift @history if scalar(@history) > 10;
    if (/^\[Auction/) {
	$auction = 1;
    } elsif (/^\[/ or /^\{/) {
	$auction = 0;
    } elsif ($auction) {
	for my $b (split) {
	    if ($b eq 'Pass' or
		$b eq 'X' or
		$b eq 'XX' or
		$b eq 'AP' or
		$b =~ /^[1234567][SHDC]$/ or
		$b =~ /^[1234567]NT$/ or
		$b =~ /^[*+-]$/
		) {
		$bid{$b}++;
	    } else {
		# print STDERR @history;
		# die "Bad bid: $b";
		$bad{$b}++;
	    }
	}
    }
}

warn Dumper(\%bad);

for my $b (sort { $bid{$b} <=> $bid{$a} } keys(%bid)) {
    print "$bid{$b}\t$b\n";
}
