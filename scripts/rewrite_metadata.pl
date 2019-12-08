use strict;
use warnings;

my %mdata_samples = ();
my %mdata_pmids = ();

sub load_Mdata_Samples {
  my $file = './mdata_spl.tsv';
  open my $fd, "<", $file or die "Could not open $file: $!";
  while( my $line = <$fd>)  {
    my @columns = split /[\t\n\r]/ , $line;
    my $mdata = $columns[0];
    $mdata =~ s/\r\n//;
    my $spl = $columns[1];
    if (! exists $mdata_samples{$mdata}) {
      $mdata_samples{$mdata} = ();
    }
    push @{$mdata_samples{$mdata}} , $spl;
  }
  close $fd;
}

sub formatSampleArray {
  my $arr_ref = $_[0];
  my $mycnt = scalar @$arr_ref;
  # print "$mycnt \n";
  my @sorted = sort { $a <=> $b } @$arr_ref;
  my $output = join ('; ', @sorted);
  return 'CC   PeptideAtlas sampleID(s): ' . $output . ".\n";
}

sub showMdataSamples() {
  while (my ($k, $v) = each %mdata_samples) {
    my $cnt = scalar @{$v};
    my $samples = formatSampleArray( \@{$v} );
    print "$k , $cnt = $samples";
  }
}

sub load_Mdata_Pmids {
  my $file = './mdata_pmid.tsv';
  open my $fd, "<", $file or die "Could not open $file: $!";
  while( my $line = <$fd>)  {
    my @columns = split /[\t\n\r]/ , $line;
    my $mdata = $columns[0];
    $mdata =~ s/\r\n//;
    my $pmid = $columns[1];
    if (! exists $mdata_pmids{$mdata}) {
      $mdata_pmids{$mdata} = ();
    }
    push @{$mdata_pmids{$mdata}} , $pmid;
  }
  close $fd;
}

sub formatPmidArray {
  my $arr_ref = $_[0];
  my $mycnt = scalar @$arr_ref;
  # print "$mycnt \n";
  my @sorted = sort { $a <=> $b } @$arr_ref;
  my $output = '';
  foreach my $el (@$arr_ref) {
    $output .= 'DR   PubMed; ' . $el . ".\n";
  }
  return $output;
}

sub showMdataPmids() {
  while (my ($k, $v) = each %mdata_pmids) {
    my $cnt = scalar @{$v};
    my $pmids = formatPmidArray( \@{$v} );
    print "$k , $cnt = $pmids \n";
  }  
}

sub readMetadata {
  my $file = './metadata.txt';
  open my $fd, "<", $file or die "Could not open $file: $!";
  my $outfile = './metadata.txt.new';
  open my $fo, ">", $outfile or die "Could not open $outfile: $!";

  my @record = ();
  while( my $line = <$fd>)  {
    push @record , $line;
    if (substr($line, 0, 2) eq '//') {  
      my @new_record = update_record( \@record );
      foreach my $el (@new_record) {
        print $fo $el;
      }
      showRec( \@new_record );
      @record = ();
    }
  }
  close $fd; 
  close $fo;
}

sub getMdata {
  my $rec_ref = $_[0];
  foreach my $el (@$rec_ref) {
    if (substr($el, 0, 2) eq 'AC') {
      my $key = substr($el,5);
      $key =~ s/\r\n//;     
      if (exists $mdata_samples{$key}) {
        return $key;
      } else {
        return undef;
      }
    }
  }
  return undef;
}


sub update_record {
  my $rec_ref = $_[0];
  my @new_rec = (); 
 
  my $mdata = getMdata($rec_ref);
  if (defined $mdata) {
    print " ------ $mdata ------\n";
    my $DRtodo = 1;
    foreach my $el (@$rec_ref) {
      print $el;
      if (substr($el, 0, 2) eq 'DR') {
        if ($DRtodo) {
          push @new_rec, formatPmidArray( $mdata_pmids{$mdata} ); 
          $DRtodo=0;
        }
      } elsif (substr($el, 0, 26) eq 'CC   PeptideAtlas sampleID') {
        push @new_rec, formatSampleArray( $mdata_samples{$mdata} );  
      } else {
        push @new_rec, $el;
      }
    }
  } else {
    print " ------ undefined mdata ------\n";
    foreach my $el (@$rec_ref) {
      print $el;
     push @new_rec, $el;
    }  
  }
  return @new_rec; 
}

sub showRec {
  my $arr_ref = $_[0];
  print " ------ new element  ------\n";
  foreach my $el (@$arr_ref) {
    print $el;
  } 
}


load_Mdata_Samples();
#showMdataSamples();
load_Mdata_Pmids();
#showMdataPmids();
readMetadata();



print "END\n";


