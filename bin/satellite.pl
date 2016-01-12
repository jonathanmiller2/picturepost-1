#!/usr/bin/perl

use strict;
use FindBin qw($Bin);

chdir "$Bin/../";

my $SRC_DIR = "/net/nfs/leghorn/raid2/archive/MODIS_images";

if (! -d $SRC_DIR) {
  die "could not find modis images\n";
}

my $GDALTINDEX_CMD = (-f "/usr/local/gdal/bin/gdaltindex")
  ? "/usr/local/gdal/bin/gdaltindex" : "gdaltindex";

open(my $MAPFILE, "> data/modis_layers.map") or die $!;

opendir(DIR, $SRC_DIR) or die $!;
foreach my $subdir (sort readdir(DIR)) {
  print $subdir."\n";
  next unless $subdir =~ /^\d{7}\.terra\.250m\.truecolor$/
           || $subdir =~ /^\d{7}\.terra\.250m\.ndvi$/;

  if (! -d "data/satellite/".$subdir.".index") {
    my $cmd = "$GDALTINDEX_CMD data/satellite/$subdir.index $SRC_DIR/$subdir/*.jpg";
    print $cmd."\n";
    system($cmd);
  }

  print $MAPFILE ' 
      LAYER
        NAME "'.$subdir.'"
        TILEINDEX "../data/satellite/'.$subdir.'.index/'.$subdir.'.shp"
        TYPE RASTER
        STATUS on
        PROJECTION
            "init=epsg:4326"
        END
        METADATA
            WMS_TITLE "'.$subdir.'"
            WMS_SRS "EPSG:4326"
        END
      END';
}
closedir DIR;
close $MAPFILE;
