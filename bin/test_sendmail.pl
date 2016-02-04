#!/usr/bin/perl

use strict;
use Mail::Sendmail();
use FindBin qw($Bin);

# load config
my %Config;
{ open my $fh, "< $Bin/../conf/picturepost.cfg" or die "could not read picturepost.cfg; $!";
  while (<$fh>) {
    s/\#.*//g;
    if (/(\w+)\s+(.*)/) {
      my $name = uc($1);
      my $val = $2;
      $val =~ s/^\s+//; $val =~ s/\s+$//;
      $Config{$name} = $val;
    }
  }
}

my $rv = Mail::Sendmail::sendmail(
  to => $Config{SUPPORT_EMAIL},
  from => $Config{SUPPORT_EMAIL},
  subject => "test email",
  body => "test email, please ignore"
);
if (! $rv) {
  print "sendmail error: ".$Mail::Sendmail::log."\n";
}
