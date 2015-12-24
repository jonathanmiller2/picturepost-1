#!/usr/bin/perl

=comment

This script sends batch emails to users and support if a pictureset is flagged.

To install it, add a crontab to run it once per day.

crontab -e

# runs at noon
0 12 * * * perl /path/picturepost/bin/auto_notify_picturepost_flagged_posts.pl

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
        log_message("ERROR: Config file not found: $fn\n", $log_fh);
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
	    Subject => "Flagged Pictureposts"
           );
  sendmail(%mail) or log_message("Error sending email to $to!\n",$log_fh);
  my $my_mail_log=$Mail::Sendmail::log;
  log_message("Log says:\n$my_mail_log\n", $log_fh);
}

sub logTimeRun {
  my ($dbh, $log_fh);
  ($dbh, $log_fh) = @_;
  my $time = $dbh->selectrow_array("SELECT current_timestamp - interval '5 minutes'");
  log_message("\n----Flagged post check run at $time----\n",$log_fh);
}


#open logs file
my $log_path="$Bin/../logs/emails.log";
open my $log_fh, '>>', $log_path;

#define variables and populate config hash
my $path_and_filename="$Bin/../conf/picturepost.cfg";
my %Config;
&parse_config_file ($path_and_filename, \%Config, $log_fh);

my $support = $Config{SUPPORT_EMAIL};
my $url = $Config{URL};
my $mode = $Config{MODE};

#connect to database
my $dsn = "dbi:Pg:dbname=$Config{DATABASE};host=$Config{DB_HOST_IP};port=$Config{DB_PORT}";
my $dbh = DBI->connect($dsn, $Config{DB_USER}, $Config{DB_PASSWORD}, { PrintError => 1, RaiseError => 1 }) or log_message("Could not connect to database; $DBI::errstr\n",$log_fh);

logTimeRun($dbh, $log_fh);

#test database connection
my ($test) = $dbh->selectrow_array("SELECT count(*) FROM picturepost.post LIMIT 1");
if ($test eq '') {
  log_message("WARNING: Could not execute query in database as user $Config{DB_USER}.\n",$log_fh);
  exit(-1);
}

#create SQL query
my $getFlagged="
SELECT DISTINCT post.post_id, person.email, post.name, picture_set.person_id, picture_set.picture_set_timestamp, picture_set.picture_set_id
FROM picture_set
JOIN post ON (picture_set.post_id=post.post_id)
JOIN person ON (post.person_id=person.person_id)
WHERE picture_set.flagged = 't'";

my $getPersonInfo="SELECT first_name, last_name, email FROM person WHERE person_id=?";

#prepare and execute queries, add emails and messages to hash
my ($post_id, $email, $photographer_id, $timestamp, $post_name, %emails, $key, $picture_set_id);
my ($person_firstname, $person_lastname, $person_email);
my $handler = $dbh->prepare($getFlagged);
$handler->execute();
$handler->bind_columns(\$post_id, \$email, \$post_name, \$photographer_id, \$timestamp, \$picture_set_id);
log_message("Executing getFlagged...\n",$log_fh);
my $empty=1; #variable set to 0 if any messages are found

while($handler->fetch()) {
  log_message("$post_id has a flagged picture set\n",$log_fh);

    my $handler2 = $dbh->prepare($getPersonInfo);
    $handler2->bind_param(1,$photographer_id);
    $handler2->execute();
    $handler2->bind_columns(\$person_firstname, \$person_lastname, \$person_email);
    $handler2->fetch();

  my $message="Post $post_name has a flagged picture set! Please view the pictures and either delete or unflag them. Click here to review: $url/picset.jsp?id=$picture_set_id
\tPost ID:\t $post_id
\tTime of set:\t $timestamp
\tUser:\t\t $person_firstname $person_lastname
\tEmail:\t\t $person_email\n\n";
  $empty=0;
  if($email ne $support)  { #prevent duplicate messages
    $emails{$email} .= $message;
    $message="Post $post_name has a flagged picture set! Please view the pictures and either delete or unflag them. Click here to review: $url/picset.jsp?id=$picture_set_id
\tPost ID:\t $post_id
\tTime of set:\t $timestamp
\tUser:\t\t $person_firstname $person_lastname
\tEmail:\t\t $person_email\n\n";
    $emails{$support} .= $message;
  }
  else {
    $message="Post $post_name has a flagged picture set! Please view the pictures and either delete or unflag them. Click here to review: $url/picset.jsp?id=$picture_set_id
\tPost ID:\t $post_id
\tTime of set:\t $timestamp
\tUser:\t\t $person_firstname $person_lastname
\tEmail:\t\t $person_email\n\n";
    $emails{$support} .= $message;
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
  log_message("No flagged posts found!\n",$log_fh);
}

close $log_fh;
