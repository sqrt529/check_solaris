#!/usr/bin/perl
# check_disk_usage.pl - Checks free disk space on Sun Solaris
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

my $df = "/usr/bin/df";

our ($opt_c, $opt_w, $opt_f, $opt_p);

sub usage {
	print "Usage: $0 -f <Mountpoint> -c <Critical size MB> -w <Warning size MB> [-p (+perf data)]\n";
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

if (!getopts("c:w:f:p")) {
	usage();
}

if ( (defined($opt_c)) && (defined($opt_w)) ) {
	if ( (is_numeric($opt_c)) && (is_numeric($opt_w)) ) {
		my @df_out = `$df -k $opt_f`;

		my $waste;

		foreach my $ln (@df_out) {
			if ($ln =~ /.[\d]./) {

				(my $device, my $size, my $used, $waste, $waste, my $mountpoint) = split (' ', $ln);
		
				$size = int($size / 1024);
				$used = int($used / 1024);
		
				my $avail = $size - $used;
		
				my $pt = 0;
				$pt = int((100 / $size) * $used) if ($size > 0);
		
				my $text = "$pt% ($avail MB of $size MB free on $mountpoint [$device])";

				if (defined($opt_p)) {
					$text = $text."|free=".$pt;
				}
	
				if ($avail <= $opt_c) {
					print "CRITICAL: $text\n";
					exit (2);
				}
				elsif ($avail <= $opt_w) {
					print "WARNING: $text\n";
					exit (1);
				}
				else {
					print "OK: $text\n";
					exit (0);
				}
			}
		}
	}
}
else {
	usage();
}
