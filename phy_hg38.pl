#!/usr/bin/perl

=head1 Program Name
 
  @(#)fasta_dbi.pl

=head1 Usage, parameters of input and output

 Usage: Extract sequences from a fasta table of mysql
 @ARGV: 
 Output: Redirect to a fasta file

=head1 Copyright

 Author: Zhangy
 URL: http://pak.cbi.pku.edu.cn
 Date: 2004-04-03

=cut

#delete from axt_branch_gene; delete from axt_branch;load data infile '/home/zhangy/fly/phy/dm.branch' into table axt_branch;update axt_branch set id = substring_index(gene,'-',1);insert into axt_branch_gene select *from (select * from axt_branch order by id, distance asc) tmp group by id;
#scan three outgroups and check two ingroups (or the current group)

#use lib "/home/zhangy/lib/lib/perl5/site_perl/5.8.5";
use DBI;
use Data::Dumper;

#$org=$ARGV[0];
#$db=$org;
#$link="DBI:mysql:database=".$db.";host=localhost";
#$ENV{MYSQL_UNIX_PORT} = "/home/chency/tmp/mysql.sock";
#$dbh = DBI->connect($link,"chency", "newstart123",{'RaiseError' => 1});

$mysql_align_database = $ARGV[0];
$mysql_user = "yuanh";
$mysql_passwd = "yuanhao123";
$string="DBI:mysql:database=".$mysql_align_database.";host=localhost";
$dbh = DBI->connect($string,$mysql_user, $mysql_passwd,{'RaiseError' => 1});


$sql="select distinct species from xref_chr_length";
$sth = $dbh->prepare($sql);
$sth -> execute();
while ($ref=$sth->fetchrow_hashref()) {
    if ($ref->{species} ne 'hg38') {     
        push @orgs, $ref->{species};
    } 
}
$sth->finish();

#$sql="select * from flyBaseGene where name like '".$ARGV[1]."%'";
#$sth = $dbh->prepare("select * from axt_synteny where transcript = 'ENSMUST00000002344'");
#$sth = $dbh->prepare("select t1.*, chrom from axt_synteny t1, transcript t2 where t1.transcript = t2.transcript");
$sth=$dbh->prepare("select t1.*,chrom from axt_synteny t1,transcript t2 where t2.transcript=t1.transcript");
$sth -> execute();
while ($ref=$sth->fetchrow_hashref()) {
    $branch=-1;
    foreach $species(@orgs) {
        @array=split(/:/,$ref->{$species});
#	print $array[2]."\t";
        if ($array[2]==2) {
#			print $array[2]."\t";
            $ref->{$species}=1;
#	     print $ref->{$species}."\n";
        } else {
            $ref->{$species}=0;
        }
	# print  $array[0]."\t".$species."\t".$array[2]."\t".$ref->{$species}."\n";
    }
    if (
        $ref->{panTro6}==0 && 
        $ref->{gorGor5}==0 &&
        $ref->{ponAbe3}==0
    ) {
        $branch="14\t0\t0";
    }
    elsif (
        $ref->{panTro6}>0 && 
        $ref->{gorGor5}==0 &&
        $ref->{ponAbe3}==0 && 
        $ref->{nomLeu3}==0
    ) {
        $branch="13\t0\t0";
    }
    elsif (
        $ref->{gorGor5}>0 &&
        $ref->{ponAbe3}==0 && 
        $ref->{nomLeu3}==0 && 
        $ref->{rheMac8}==0
    ) {
        $branch="12\t".(
            $ref->{panTro6}
            )."\t0";
    }
    elsif (
        $ref->{ponAbe3}>0 && 
        $ref->{nomLeu3}==0 && 
        $ref->{rheMac8}==0 && 
        $ref->{calJac3}==0
    ) {
        $branch="11\t".(
            $ref->{panTro6}+
            $ref->{gorGor5}
            )."\t0";
    }
    elsif (
        $ref->{nomLeu3}>0 && 
        $ref->{rheMac8}==0 && 
        $ref->{calJac3}==0 && 
        $ref->{oryCun2}+$ref->{cavPor3}+$ref->{rn6}+$ref->{mm10}<=1
    ) {
        $branch="10\t".(
            $ref->{gorGor5}+
            $ref->{ponAbe3}
        )."\t".(
            $ref->{rheMac8}+
            $ref->{calJac3}+
            $ref->{oryCun2}+$ref->{cavPor3}+$ref->{rn6}+$ref->{mm10}
        );
    }
    elsif (
        $ref->{rheMac8}>0 && 
        $ref->{calJac3}==0 && 
        $ref->{oryCun2}+$ref->{cavPor3}+$ref->{rn6}+$ref->{mm10}<=1 && 
        $ref->{bosTau8}+$ref->{oviAri3}+$ref->{canFam3}<=1
    ) {
        $branch="9\t".(
            $ref->{ponAbe3}+
            $ref->{nomLeu3}
        )."\t".(
            $ref->{calJac3}+
            $ref->{oryCun2}+$ref->{cavPor3}+$ref->{rn6}+$ref->{mm10}+
            $ref->{bosTau8}+$ref->{oviAri3}+$ref->{canFam3}
        );
    }
    elsif (
        $ref->{calJac3}>0 && 
        $ref->{oryCun2}+$ref->{cavPor3}+$ref->{rn6}+$ref->{mm10}<=1 && 
        $ref->{bosTau8}+$ref->{oviAri3}+$ref->{canFam3}<=1 && 
        $ref->{loxAfr3}==0
    ) {
        $branch="8\t".(
            $ref->{nomLeu3}+
            $ref->{rheMac8}
        )."\t".(
            $ref->{oryCun2}+$ref->{cavPor3}+$ref->{rn6}+$ref->{mm10}+
            $ref->{bosTau8}+$ref->{oviAri3}+$ref->{canFam3}+
            $ref->{loxAfr3}
        );
    }
    elsif (
        $ref->{oryCun2}+$ref->{cavPor3}+$ref->{rn6}+$ref->{mm10}>=2 &&
        $ref->{bosTau8}+$ref->{oviAri3}+$ref->{canFam3}<=1 &&
        $ref->{loxAfr3}==0 &&
        $ref->{monDom5}==0
    ) {
        $branch="7\t".(
            $ref->{rheMac8}+
            $ref->{calJac3}+
            $ref->{oryCun2}+$ref->{cavPor3}+$ref->{rn6}+$ref->{mm10}
        )."\t".(
            $ref->{bosTau8}+$ref->{oviAri3}+$ref->{canFam3}+
            $ref->{loxAfr3}+
            $ref->{monDom5}
        );
    }
    elsif (
        $ref->{bosTau8}+$ref->{oviAri3}+$ref->{canFam3}>=2 &&
        $ref->{loxAfr3}==0 &&
        $ref->{monDom5}==0 &&
        $ref->{ornAna2}==0
    ) {
        $branch="6\t".(
            $ref->{calJac3}+
            $ref->{oryCun2}+$ref->{cavPor3}+$ref->{rn6}+$ref->{mm10}+
            $ref->{bosTau8}+$ref->{oviAri3}+$ref->{canFam3}
        )."\t".(
            $ref->{loxAfr3}+$ref->{monDom5}+$ref->{ornAna2}
        );
    }
    elsif (
        $ref->{loxAfr3}>0 &&
        $ref->{monDom5}==0 &&
        $ref->{ornAna2}==0 &&
        $ref->{galGal6}+$ref->{taeGut2}+$ref->{anoCar2}<=1
    ) {
        $branch="5\t".(
            $ref->{oryCun2}+$ref->{cavPor3}+$ref->{rn6}+$ref->{mm10}+
            $ref->{bosTau8}+$ref->{oviAri3}+$ref->{canFam3}
        )."\t".(
            $ref->{monDom5}+
            $ref->{ornAna2}+
            $ref->{galGal6}+$ref->{taeGut2}+$ref->{anoCar2}
        );
    }
    elsif (
        $ref->{monDom5}>0 &&
        $ref->{ornAna2}==0 &&
        $ref->{galGal6}+$ref->{taeGut2}+$ref->{anoCar2}<=1 &&
        $ref->{xenTro9}==0
    ) {
        $branch="4\t".(
            $ref->{bosTau8}+$ref->{oviAri3}+$ref->{canFam3}+
            $ref->{loxAfr3}
        )."\t".(
            $ref->{ornAna2}+
            $ref->{galGal6}+$ref->{taeGut2}+$ref->{anoCar2}+
            $ref->{xenTro9}
        );
    }
    elsif (
        $ref->{ornAna2}>0 &&
        $ref->{galGal6}+$ref->{taeGut2}+$ref->{anoCar2}<=1 &&
        $ref->{xenTro9}==0 &&
        $ref->{gasAcu1}+$ref->{tetNig2}+$ref->{danRer11}<=1
    ) {
        $branch="3\t".(
            $ref->{loxAfr3}+
            $ref->{monDom5}
        )."\t".(
            $ref->{galGal6}+$ref->{taeGut2}+$ref->{anoCar2}+
            $ref->{xenTro9}+
            $ref->{gasAcu1}+$ref->{tetNig2}+$ref->{danRer11}
        );
    }
    elsif (
        $ref->{galGal6}+$ref->{taeGut2}+$ref->{anoCar2}>=2 &&
        $ref->{xenTro9}==0 &&
        $ref->{gasAcu1}+$ref->{tetNig2}+$ref->{danRer11}<=1
    ) {
        $branch="2\t".(
            $ref->{monDom5}+
            $ref->{ornAna2}+
            $ref->{galGal6}+$ref->{taeGut2}+$ref->{anoCar2}
        )."\t".(
            $ref->{xenTro9}+
            $ref->{gasAcu1}+$ref->{tetNig2}+$ref->{danRer11}
        );
    }
    elsif (
        $ref->{xenTro9}>0 &&
        $ref->{gasAcu1}+$ref->{tetNig2}+$ref->{danRer11}<=1
    ) {
        $branch="1\t".(
            $ref->{ornAna2}+
            $ref->{galGal6}+$ref->{taeGut2}+$ref->{anoCar2}
        )."\t".(
            $ref->{gasAcu1}+$ref->{tetNig2}+$ref->{danRer11}
        );
    }
    elsif (
        $ref->{gasAcu1}+$ref->{tetNig2}+$ref->{danRer11}>=2
    ) {
        $branch="0\t".(
            $ref->{galGal6}+$ref->{taeGut2}+$ref->{anoCar2}+
            $ref->{xenTro9}
        )."\t0";
    }
    else {
        ;
    }


    #difficult to different some branches
    #         if ($ref->{vi}+$ref->{mo}+$ref->{gr}==1 && $branch==7) {
    # #        if ($ref->{vi}+$ref->{mo}+$ref->{gr}==1) {
    #             $branch="7_0\t1";
    #         }
    #         if ($ref->{vi}+$ref->{mo}+$ref->{gr}>=2 && $branch>0 && !($branch=~m/^7/)) {
    # #        if ($ref->{vi}+$ref->{mo}+$ref->{gr}==1) {
    #             $branch=$branch.":7_0_".($ref->{vi}+$ref->{mo}+$ref->{gr});
    #         }

    if (length($ref->{chrom})>5) {
        $note="lowChr";
    } else {
        $note="NA";
    }


    #transposon-related
    $sql="select t2.chrom, t2.transcript, sum(overlap)/t_length ratio from ann_exon_repeats t1, exon t2, transcript t3 where t3.transcript = t2.transcript and t2.transcript = '$ref->{transcript}' and t1.exon = t2.exon group by transcript";
    $sth2 = $dbh->prepare($sql);
    $sth2 -> execute();
    if ($ref2=$sth2->fetchrow_hashref()) {
        if ($ref2->{ratio}>0.7) {
            $note.="transposon";
        }
    }
    $sth2->finish();
        
    #        "update dm3_centromere t1, flyBaseGene_unique t2, axt_branch_test t3 set t3.note = 'Centromere' where t2.gene = t3.id and (txStart between tStart and tEnd or txEnd between tStart and tEnd) and tName = chrom and branch > 0 ;";
        
    #heterochromatin or low-quality chromosome associated
    #         if ($ref->{chrom}=~m/Het/i or $ref->{chrom}=~m/ChrU/i) {
    #             $note.="lowChr";
    #         }
    #heterochromatin or low-quality chromosome associated
    print join("\t",$ref->{transcript},$branch,$note,"","",""),"\n";
       # print ($branch."\t");
}
$sth->finish();

$dbh->disconnect();
