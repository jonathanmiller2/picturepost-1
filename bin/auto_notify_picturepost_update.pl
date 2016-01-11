#!/usr/bin/perl

=comment

This script sends batch emails to users and support if a post is updated or a new comment is posted.

To install it, add a crontab to run it every 10 minutes.

crontab -e

# run every 10 minutes
0,10,20,30,40,50 * * * * /path/picturepost/bin/auto_notify_picturepost_update.pl

=cut

use strict;
use DBI();
use Data::Dumper;
use Mail::Sendmail();
use FindBin qw($Bin);

sub isEmail { $_[0] =~ /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/ ? 1 : 0 }

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


#connect to database
my $dbh = DBI->connect(
  "dbi:Pg:dbname=$Config{DATABASE};host=$Config{DB_HOST_IP};port=$Config{DB_PORT}",
  $Config{DB_USER}, $Config{DB_PASSWORD},
    { PrintError => 1, RaiseError => 1 })
      or die "could not connect to db; $DBI::errstr\n";


# get current_time (subtract one minute for fudge)
my ($current_time) = $dbh->selectrow_array("SELECT current_timestamp - interval '1 minutes'");


# get/set time_last_ran
my $time_last_ran;
{ my $fn = "$Bin/../data/auto_notify_picturepost_update_last_run.dat";
  if (-f $fn && -w $fn) {
    open my $fh, "< $fn" or die "could not open $fn\n";
    $time_last_ran = <$fh>;
    $time_last_ran =~ s/^\s+//s;
    $time_last_ran =~ s/\s+$//s;
  }
  $time_last_ran ||= $current_time;

  # write time
  { open my $fh, "> $fn" or die "could not write $fn\n";
    print $fh $time_last_ran;
  }
}

print "starting... time_last_ran: $time_last_ran; current_time: $current_time\n";


# emails to send; key is email address; value is email body
my %emails;

# find new picturesets
{ my $sth = $dbh->prepare("
    SELECT
      post.post_id,
      person.email post_owner_email,
      post.name,
      picture_set.picture_set_id,
      picture_set.annotation,
      COALESCE(uploader.username, CONCAT(uploader.first_name,' ',uploader.last_name)) uploader_name,
      uploader.email uploader_email
    FROM picture_set
    JOIN post ON (picture_set.post_id=post.post_id)
    JOIN person ON (post.person_id=person.person_id)
    JOIN person uploader ON (picture_set.person_id=uploader.person_id)
    WHERE picture_set.record_timestamp >= ?
    AND picture_set.record_timestamp < ?
    ORDER BY post.name");
  $sth->execute($time_last_ran,$current_time);
  while (my $h = $sth->fetchrow_hashref()) {
    my $msg = "
New Picture Set for $$h{name}
       URL: $Config{URL}/post.jsp?postId=$$h{post_id}#picset=$$h{picture_set_id}
  Uploader: $$h{uploader_name}
     Email: $$h{uploader_email}";
    $msg .= "
   Comment: $$h{comment_text}" if $$h{comment_text};
    $msg .= "\n";
    $emails{$Config{SUPPORT_EMAIL}} .= $msg;
    $emails{$$h{post_owner_email}} .= $msg if $$h{post_owner_email} && $$h{post_owner_email} ne $Config{SUPPORT_EMAIL};
  }
}


# find new comments
{ my $sth = $dbh->prepare("
    SELECT
      post.post_id,
      person.email post_owner_email,
      COALESCE(comment_person.username, CONCAT(comment_person.first_name,' ',comment_person.last_name)) person_name,
      comment_person.email,
      post.name,
      picture_comment.picture_id,
      picture_comment.comment_text
FROM picture_comment
JOIN picture ON (picture_comment.picture_id=picture.picture_id)
JOIN picture_set ON (picture.picture_set_id=picture_set.picture_set_id)
JOIN post ON (picture_set.post_id=post.post_id)
JOIN person ON (post.person_id=person.person_id)
JOIN person comment_person ON (picture_comment.person_id=comment_person.person_id)
WHERE comment_timestamp >= ?
AND comment_timestamp < ?
ORDER BY post.name, comment_timestamp");
  $sth->execute($time_last_ran,$current_time);
  while (my $h = $sth->fetchrow_hashref()) {
    my $msg = "
New Comment for $$h{name}
       URL: $Config{URL}/post.jsp?pic=$$h{picture_id}
      User: $$h{person_name}
     Email: $$h{email}
   Comment: $$h{comment_text}\n";
    $emails{$Config{SUPPORT_EMAIL}} .= $msg;
    $emails{$$h{post_owner_email}} .= $msg if $$h{post_owner_email} && $$h{post_owner_email} ne $Config{SUPPORT_EMAIL};
  }
}


# find new added posts, send email to SUPPORT_EMAIL
{ my $sth = $dbh->prepare("
    SELECT
      post.post_id,
      post.name,
      COALESCE(person.username, CONCAT(person.first_name,' ',person.last_name)) person_name,
      person.email,
      post.description
    FROM post
    JOIN person ON (post.person_id=person.person_id)
    WHERE post.record_timestamp >= ?
    AND post.record_timestamp < ?
    ORDER BY post.name");
  $sth->execute($time_last_ran,$current_time);
  while (my $h = $sth->fetchrow_hashref()) {
    $emails{$Config{SUPPORT_EMAIL}} .= "
New Post - $$h{name}
       URL: $Config{URL}/post.jsp?postId=$$h{post_id}
     Owner: $$h{first_name} $$h{last_name}
     Email: $$h{email}
     Descr: $$h{description}\n";
  }
}

# sendemail
if ($Config{MODE} eq 'live') {
  while (my ($to,$body) = each %emails) {
    next unless isEmail($to);
    print "sending email: $to\n";

    my $rv = sendmail(
      to => $to,
      from => $Config{SUPPORT_EMAIL},
      subject => "Picture Post Updates",
      body => $body
    );
    if (! $rv) {
      print "sendmail error: ".$Mail::Sendmail::log."\n";
    }
  }
}
else {
  print "dev mode emails:\n".Dumper(\%emails);
}

$dbh->disconnect();

print "normal termination\n";
