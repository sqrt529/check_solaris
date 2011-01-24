#!/usr/bin/perl
# check_solaris_swap.pl - Checks free swap space on Sun Solaris
#
# Copyright (C) 2010 Joachim "Joe" Stiegler <blablabla@trullowitsch.de>
# 
# This program is free software; you can redistribute it and/or modify it under the terms
# of the GNU General Public License as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program;
# if not, see <http://www.gnu.org/licenses/>.
#
# --
# 
# Version: 1.0 - 2010-10-13

use warnings;
use strict;
use Getopt::Std;

our ($opt_c, $opt_w, $opt_h, $opt_p);

sub usage {
	if (defined($opt_h)) {
		print "Usage: $0 -c CRITICAL (1-100) -w WARNING (1-100) [-p (+perf data)]\n";
	}
	else {
		print "Usage: $0 -c <1-100> -w <1-100> [-p]\n";
	}
	exit (1);
}

sub is_numeric {
	my $number = shift(@_);
	if ($number =~ /[^\d]/) {
		usage();
	}
	else {
		return (1);
	}
}

if (!getopts("c:w:hp")) {
	usage();
}

if ( (defined($opt_c)) && (defined($opt_w)) ) {
	if ( (is_numeric($opt_c)) && (is_numeric($opt_w)) ) {
		my @INPUT = split(/ +/, `/usr/sbin/swap -s`);

		my $used = $INPUT[8];
		my $available = $INPUT[10];

		$used =~ tr/[0-9]//cd;
		$available =~ tr/[0-9]//cd;

		my $swap_mb = int($available / 1024);
		my $swaptotal_mb = int(($used + $available) / 1024);

		my $swap_pt = int(($available / ($used + $available)) * 100);

		my $text = "$swap_pt% ($swap_mb MB of $swaptotal_mb MB) free";

		if (defined($opt_p)) {
			$text = $text."|used=".(100 - $swap_pt);
		}

		if ($swap_pt <= $opt_c) {
			print "CRITICAL: $text\n";
			exit (2);
		}
		elsif ($swap_pt <= $opt_w) {
			print "WARNING: $text\n";
			exit (1);
		}
		else {
			print "OK: $text\n";
			exit (0);
		}
	}
}
else {
	usage();
}
