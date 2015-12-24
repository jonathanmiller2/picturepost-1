#!/usr/bin/perl

=comment

This script sends batch emails to users and support if a post is updated or a new comment is posted.

To install it, add a crontab to run it every 10 minutes.

crontab -e

# run every 10 minutes
0,10,20,30,40,50 * * * * /path/picturepost/bin/auto_notify_picturepost_update.pl

=cut

use strict;
use warnings;
use DBI();
use Mail::Sendmail;
use FindBin qw($Bin);

sub log_message {
    my ($mess, $log_fh);
    ($mess, $log_fh) = @_;
    print $log_fh $mess;
}

#puts config file into a hash table for easy access to variables
sub parse_config_file {
    my ($config_line, $Name, $Value, $Config, $fh, $fn, $log_fh);
    ($fn, $Config, $log_fh) = @_;

    if (!open ($fh, "$fn")) {
        log_message("ERROR: Config file not found : $fn\n", $log_fh);
        exit(0);
    }
    
    while (<$fh>) {
        $config_line=$_;
        chop ($config_line);          # Get rid of the trailing \n
        $config_line =~ s/^\s*//;     # Remove spaces at the start of the line
        $config_line =~ s/\s*$//;     # Remove spaces at the end of the line
        if ( ($config_line !~ /^#/) && ($config_line ne "") ){    # Ignore lines starting with # and blank lines
            my ($name, $val) = split /\s+/, $config_line;
            ($Name, $Value) = split (" ", $config_line);          # Split each line into name value pairs
            $$Config{$Name} = $Value;                             # Create a hash of the name value pairs
        }
    }
    close($fh);
}

#sends email to specified email address with specified body and support email from config file
sub sendEmail {
  my ($to, $body, $support_email, %mail, $log_fh);
  ($to, $body, $support_email, $log_fh) = @_;
  %mail = ( To      => $to,
	    From    => $support_email,
            Message => $body,
	    Subject => "New Picturepost Activity"
           );
  sendmail(%mail) or log_message("Error sending email to $to!\n",$log_fh);
  my $my_mail_log=$Mail::Sendmail::log;
  log_message("Log says:\n$my_mail_log\n", $log_fh);
}




# returns last timestamp this program ran
# if data file does not exist, this function returns undef
sub getDateTimeLastRun {
  my ($dbh, $last_run_path, $log_fh);
  ($dbh, $last_run_path, $log_fh) = @_;
  
  open my $last_run_fh, '<', $last_run_path;
  if (!$last_run_fh || !(-e $last_run_path)) {
    my $current_timestamp = $dbh->selectrow_array("SELECT current_timestamp");
    open($last_run_fh, "> $last_run_path");
    if (!$last_run_fh) { log_message("could not write $last_run_path; $!\n",$log_fh); }
    print $last_run_fh $current_timestamp;
    close $last_run_fh;
    open $last_run_fh, "< $last_run_path" or log_message("could not read $last_run_path; $!\n",$log_fh);
    close $last_run_fh;
    return undef;
  }
  else {
    my $lastrun;
    while (<$last_run_fh>) {
      $lastrun=$_;
      chop ($lastrun);          # Get rid of the trailling \n
      $lastrun =~ s/^\s*//;     # Remove spaces at the start of the line
      $lastrun =~ s/\s*$//;     # Remove spaces at the end of the line
    }
    close $last_run_fh;
    return $lastrun;
  }
}

#returns the current time minus 5 minutes to catch slow processes
sub getDateTimeThisRun {
  my ($dbh, $log_fh);
  ($dbh, $log_fh) = @_;
  my $time = $dbh->selectrow_array("SELECT current_timestamp - interval '5 minutes'");
  log_message("\n----Post and comment check run at $time----\n",$log_fh);
  return $time;
}

#writes the specified time to the date and time file
sub updateDateTimeFile {
  my ($last_run_path, $new_time);
  ($last_run_path, $new_time) = @_;

  open my $last_run_fh, '>', $last_run_path;
  print $last_run_fh $new_time;
  close $last_run_fh;
}




#open logs file
my $log_path="$Bin/../logs/emails.log";
open my $log_fh, '>>', $log_path;

#define variables and populate config hash
my $last_run_path="$Bin/../data/auto_notify_picturepost_update_last_run.dat";
my $path_and_filename="$Bin/../conf/picturepost.cfg";
my %Config;
&parse_config_file ($path_and_filename, \%Config, $log_fh);

my $support = $Config{SUPPORT_EMAIL};
my $url = $Config{URL};
my $mode = $Config{MODE};

#connect to database
my $dsn = "dbi:Pg:dbname=$Config{DATABASE};host=$Config{DB_HOST_IP};port=$Config{DB_PORT}";
my $dbh = DBI->connect($dsn, $Config{DB_USER}, $Config{DB_PASSWORD}, { PrintError => 1, RaiseError => 1 }) or log_message("Could not connect to database; $DBI::errstr\n",$log_fh);

#test database connection
my ($test) = $dbh->selectrow_array("SELECT count(*) FROM picturepost.post LIMIT 1");
if ($test eq '') {
  log_message("WARNING: Could not execute query in database as user $Config{DB_USER}.\n",$log_fh);
  exit(-1);
}

my $time_last_ran = getDateTimeLastRun($dbh, $last_run_path, $log_fh);

my $current_time = getDateTimeThisRun($dbh, $log_fh);
updateDateTimeFile($last_run_path, $current_time);
if(defined $time_last_ran) {
  log_message("Last run at $time_last_ran\n",$log_fh);
}
else {
  log_message("Data from a previous run not found.\n",$log_fh);
  $time_last_ran=$current_time; #essentially does nothing but set up for the next run
  #$time_last_ran="2000-04-01 12:00:00.700119-04"; #use this for instant mass emails for everything that's ever happened ever
}

#create SQL queries

my $getComments="SELECT post.post_id,
	person.email,
	picture_comment.person_id,
	picture_comment_id,
	comment_timestamp,
	post.name,
	picture_comment.picture_id,
	picture_comment.comment_text
FROM picture_comment
JOIN picture ON (picture_comment.picture_id=picture.picture_id)
JOIN picture_set ON (picture.picture_set_id=picture_set.picture_set_id)
JOIN post ON (picture_set.post_id=post.post_id)
JOIN person ON (post.person_id=person.person_id)
WHERE comment_timestamp  >= ? AND comment_timestamp < ?";

my $getUpdated="
SELECT post.post_id, person.email, post.name, picture_set.person_id, picture_set.record_timestamp, picture_set.picture_set_id
FROM picture_set
JOIN post ON (picture_set.post_id=post.post_id)
JOIN person ON (post.person_id=person.person_id)
WHERE picture_set.record_timestamp  >= ? AND picture_set.record_timestamp < ?";

my $getPersonInfo="SELECT first_name, last_name, email FROM person WHERE person_id=?";
my $getPictureInfo="SELECT orientation FROM picture WHERE picture_id=?";

#prepare and execute queries, add emails and messages to hash
my ($post_id, $email, $comment_id, $person_id, $timestamp, $postname, %hasComment, %emails, %updated, $key, $picture_set_id);
my ($person_firstname, $person_lastname, $person_email, $picture_orientation, $picture_id, $comment_text);
my $handler = $dbh->prepare($getComments);
$handler->bind_param(1,$time_last_ran);
$handler->bind_param(2,$current_time);
$handler->execute();
$handler->bind_columns(\$post_id, \$email, \$person_id, \$comment_id, \$timestamp, \$postname, \$picture_id, \$comment_text);
log_message("Executing getComments...\n",$log_fh);
my $empty=1; #variable set to 0 if any messages are found

while($handler->fetch()) {
  #log_message("Fetched ID $post_id\n",$log_fh);
  if (!(defined $hasComment{$post_id}) || $hasComment{$post_id}!=1) {
    $empty=0;
    log_message("ID $post_id has a new comment.\n",$log_fh);

    my $handler2 = $dbh->prepare($getPersonInfo);
    $handler2->bind_param(1,$person_id);
    $handler2->execute();
    $handler2->bind_columns(\$person_firstname, \$person_lastname, \$person_email);
    $handler2->fetch();

    $handler2 = $dbh->prepare($getPictureInfo);
    $handler2->bind_param(1,$picture_id);
    $handler2->execute();
    $handler2->bind_columns(\$picture_orientation);
    $handler2->fetch();

    my $message="Post $postname has a new comment! Click here to view: $url/post.jsp?postId=$post_id
\t\"$comment_text\"
\tPost ID:\t\t $post_id
\tTime of comment:\t $timestamp
\tUser:\t\t\t $person_firstname $person_lastname
\tEmail:\t\t\t $person_email
\tPicture Orientation:\t $picture_orientation\n\n";
    $emails{$email} .= $message;
    if($email ne $support) { #prevent duplicate messages
      $emails{$support} .= $message;
    }
    $hasComment{$post_id}=1;
  }
}

$handler = $dbh->prepare($getUpdated);
$handler->bind_param(1,$time_last_ran);
$handler->bind_param(2,$current_time);
$handler->execute();
$handler->bind_columns(undef, \$post_id, \$email, \$postname, \$person_id, \$timestamp, \$picture_set_id);
log_message("Executing getUpdated...\n",$log_fh);
while($handler->fetch()) {
  if (!($updated{$post_id}) || $updated{$post_id}!=1) {
    $empty=0;
    log_message("ID $post_id was updated\n",$log_fh);

    my $handler2 = $dbh->prepare($getPersonInfo);
    $handler2->bind_param(1,$person_id);
    $handler2->execute();
    $handler2->bind_columns(\$person_firstname, \$person_lastname, \$person_email);
    $handler2->fetch();

    my $message="Post $postname has been updated! Click here to view: $url/post.jsp?postId=$post_id#picset=$picture_set_id
\tPost ID:\t\t $post_id
\tTime of update:\t\t $timestamp
\tUser:\t\t\t $person_firstname $person_lastname
\tEmail:\t\t\t $person_email\n\n";
    $emails{$email} .= $message;
    if($email ne $support) { #prevent duplicate messages
      $emails{$support} .= $message;
    }
    $updated{$post_id}=1;
  }
}

#if the site is live, send emails to all of the email addresses in the hash
if($empty==0) {
if ($mode eq 'live') {
  log_message("Sending LIVE email:\n",$log_fh);
  foreach $key (keys %emails) {
    log_message("$key: $emails{$key}\n\n",$log_fh);
    sendEmail($key, $emails{$key}, $support, $log_fh);
  }
}

#if the site is a development server, send an email to support with a list of all the
#messages and emails that were going to be sent
else {
  log_message("Sending DEVELOPMENT email:\n",$log_fh);
  my $message="";
  foreach $key (keys %emails) {
    $message .= "To $key:\n";
    $message .= "$emails{$key}\n\n";
    log_message("$key: $emails{$key}\n\n",$log_fh);
  }
  sendEmail($support, $message, $support, $log_fh);
}
}
else {
  log_message("No events found!\n",$log_fh);
}

close $log_fh;

