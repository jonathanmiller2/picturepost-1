#!/usr/bin/perl

use strict;
use CGI qw(:cgi);
use FindBin qw($Bin);

# Get the parameters from the query string.
my $image = CGI::param("image") or die "missing image param";
my $algorithm = CGI::param("algorithm") or die "missing algorithm param";

# no funny business
die "invalid image param" if $image =~ /\.\./;

print CGI::header("image/jpeg");
exec("$Bin/../bin/colorMod", "-i", "$Bin/../data/pictures/$image", "-a", $algorithm);
