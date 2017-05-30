#!/usr/bin/perl

use strict;
use URI::Escape qw( uri_escape );
use JSON qw( to_json );

sub escape_html {
  local ($_) = @_;
  s{&}{&amp;}gso;
  s{<}{&lt;}gso;
  s{>}{&gt;}gso;
  s{"}{&quot;}gso;
  s{'}{&#39;}gso;
  s{\x8b}{&#8249;}gso;
  s{\x9b}{&#8250;}gso;
  return $_;
}

my %args = @_;

$args{"-incrementer"} ||= 30;
$args{"-days"} ||= $args{"-incrementer"} * 80;
$args{"-years"} ||= 5;

my $t = $args{"-days"}; 

sub trim {
  my $v = join(' ', @_);
  $v =~ s/^\s+//s;
  $v =~ s/\s+$//s;
  return $v;
}



$args{'-title'} ||= trim(`hostname`).':'.trim(`pwd`).' Disk Usage';

my @lines = `ls -alR --time-style='+%Y%m'`;

my (%sizes, $min_date, $max_date, $size, $ym);
foreach my $line (@lines) {
  next if $line =~ /\s+\.+\s*/ || $line =~ /^d/;
  (undef, undef, undef, undef, $size, $ym) = split /\ +/, $line;
  $min_date = $ym if ! defined $min_date || $ym < $min_date;
  $max_date = $ym if ! defined $max_date || $ym > $max_date;
  $sizes{$ym} += $size;
}

my $minSize;
my $maxSize;
my $data; {
  my @data;
  my $totalSize = 0;
  foreach my $ym (sort keys %sizes) {
    $totalSize += $sizes{$ym}; 
    my $totalGB = $totalSize/1073741824;
    next unless $totalGB > 0;
    $totalGB =~ s/(\.\d).*/$1/;
    $minSize = $totalGB if ! defined $minSize || $minSize==0 || $totalGB < $minSize;
    $maxSize = $totalGB if ! defined $maxSize || $totalGB > $maxSize;
    push @data, "$ym:$totalGB"; 
  }
  $data=join(',',@data);
}

my $totalMonths = 0;
if ($min_date =~ /^(\d\d\d\d)(\d+)/) {
  my $y0 = $1;  
  my $m0 = $2;  
  if ($max_date =~ /^(\d\d\d\d)(\d+)/) {
    my $y1 = $1;  
    my $m1 = $2;  
    $totalMonths = (12 * ($y1 - $y0)) + (12 - $m0) + $m1;
  } else {
    die "bad parse max_date: $max_date";
  }
} else {
  die "bad parse min_date: $min_date";
}

my $averageGrowthMonth = ($maxSize - $minSize) / $totalMonths;
my $projectedSize5Years = $maxSize + ($averageGrowthMonth * 5 * 12);

  
my $buf =
'<html>
<head>
<title>'.escape_html($args{"-title"}).'</title>
<script src="https://www.gstatic.com/charts/loader.js"></script>
</head>
<body>
<div id=chart></div>
<script>
var today = new Date();
var maxDate = new Date(today.getFullYear()+5, today.getMonth()+1);
google.charts.load("current", {packages: ["corechart"]});
google.charts.setOnLoadCallback(function(){
  var data = new google.visualization.DataTable();
  data.addColumn("date", "month");
  data.addColumn("number", "GB");
  "'.$data.'".split(/,/).forEach(function(x){
    if (/(\d\d\d\d)(\d+)\:(.+)$/.test(x)) {
      var y = parseInt(RegExp.$1,10);
      var m = parseInt(RegExp.$2,10);
      var gb = parseFloat(RegExp.$3);
      data.addRow([new Date(y,m), gb]);
    }
  });
  var opts = {
    title: "'.$args{"-title"}.'",
    width: 900,
    height: 500,
    hAxis: {
      title: "Days",
      scaleType: null,
      maxValue: maxDate
    },
    vAxis: {
      title: "Disk Size (GB)",
      minValue: '.$minSize.',
      maxValue: '.$projectedSize5Years.'
    },
    trendlines: { 0: {} }    // Draw a trendline for data series 0.
  };
  var chart = new google.visualization.LineChart(document.getElementById("chart"));
  chart.draw(data, opts);
});
</script>
</body>
</html>';
print $buf;

exit(0);

