#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Std;
use Data::Dumper;

use FileHandle;

# Ensembl modules
use lib "/rd/yuanh/gentree/ensembl-95-api/ensembl/modules";
#use lib "/home/chency/gene_dating/software/ensembl$ARGV[2]/modules";
use Bio::EnsEMBL::DBSQL::DBAdaptor;

# process Options
my %options;
getopts('h:d:u:p:v', \%options);

my $opt_verbose = $options{'v'};

# Initializing the EnsEMBL API
my $opt_host = $options{'h'} || 'localhost';
my $opt_user = $options{'u'} || 'yuanh';
my $opt_password = $options{'p'} || 'PASSWORD';

my $arg_dbname = $ARGV[0];

die "A database should be given" unless $arg_dbname;


my $db = new Bio::EnsEMBL::DBSQL::DBAdaptor(-host => $opt_host,
                                            -user => $opt_user,
                                            -dbname => $arg_dbname,
                                            -port=> 1998,
                                            -pass => $opt_password);

my $transcript_fh=new FileHandle(">$ARGV[1].transcript");
my $exon_fh=new FileHandle(">$ARGV[1].exon");
my $gene_fh=new FileHandle(">$ARGV[1].gene");

my $gene_adaptor=$db->get_GeneAdaptor();
my $slice_adaptor=$db->get_SliceAdaptor();
my $genes=new FileHandle($ARGV[1]);
while (<$genes>) {
    if ($_=~m/(ENS\S+)/ or $_=~m/(FBgn\d+)/) {
        my $gene = $gene_adaptor->fetch_by_stable_id($1);
        next if(!(defined $gene));
	my $status='NULL';
#        my $status='';
#        if (defined $gene->status) {
#            $status=$gene->status;
#        }
        my $biotype='';
        if (defined $gene->biotype) {
            $biotype=$gene->biotype;
        }
        my $description='';
        if (defined $gene->description) {
            $description=$gene->description;
        }


        print $gene_fh join("\t",$1,$description,$status,$biotype,
                           ),"\n";
        my $strand;
        $strand=map { $gene->$_ } qw(strand);
        foreach my $transcript (@{$gene->get_all_Transcripts()}) {
            my $pep=$transcript->translate;
            my $slice=$slice_adaptor->fetch_by_transcript_stable_id($transcript->stable_id);
            if ($slice->strand==1) {
                $strand='+';
            } else {
                $strand='-';
            }
            if (defined $pep) {
                print $transcript_fh join("\t",$gene->display_id,$transcript->display_id,$transcript->length,
                                          $pep->display_id,
                                          $pep->length,
                                          $transcript->cdna_coding_start,$transcript->cdna_coding_end,
                                          $transcript->coding_region_start,$transcript->coding_region_end,
                                          $slice->seq_region_name,$slice->start,$slice->end,$strand,
                                          $transcript->seq->seq,$transcript->translateable_seq,$pep->seq),"\n";
            } else {
                print $transcript_fh join("\t",$gene->display_id,$transcript->display_id,$transcript->length,
                                          '',
                                          0,0,0,0,0,
                                          $slice->seq_region_name,$slice->start,$slice->end,$strand,
                                          $transcript->seq->seq,'',''),"\n";
            }

            my $rank=0;
            my $sum=0;
            foreach my $exon (@{$transcript->get_all_Exons()}) {
                $rank++;
                my $pep=$exon->peptide($transcript);
                my $slice=$slice_adaptor->fetch_by_exon_stable_id($exon->stable_id);
                if ($pep->length) {
                    my $phase='';
                    if (defined $exon->phase) {
                        $phase=$exon->phase;
                    }
                    print $exon_fh join("\t",$transcript->display_id,$exon->display_id,$rank,$phase,
                                        $exon->cdna_coding_start($transcript),
                                        $exon->cdna_coding_end($transcript),
                                        $sum+1,$sum+$pep->length,$slice->start,$slice->end,
                                        $exon->cdna_start($transcript),$exon->cdna_end($transcript),
                                        $slice->seq_region_name),"\n";
                    $sum+=$pep->length;
                } else {
                    print $exon_fh join("\t",$transcript->display_id,$exon->display_id,$rank,'',
                                        0,0,
                                        0,0,$slice->start,$slice->end,
                                        $exon->cdna_start($transcript),$exon->cdna_end($transcript),
                                        $slice->seq_region_name),"\n";
                }
            }
        }
    }
}

close $exon_fh;
close $gene_fh;
close $transcript_fh;
close $genes;
