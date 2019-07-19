#!/usr/bin/perl
# @(#)hs_dating.pl
#4800 perl path: /export/home/zhangy/programs/perl/bin/perl
#ibm perl path: /gpfs/chenyj/program/perl/bin/perl

=head1 Usage, parameters of input and output

 Usage: 
 @ARGV: 
 Output: 

=head1 Copyright

 Author: Zhangy
 URL: http://pak.cbi.pku.edu.cn
 Date: 2008-08-13

=cut

#use lib "/home/zhangy/lib/lib/perl5/site_perl/5.8.5";   这句不需要了 环境中有相符合的版本了
use DBI;   #这个也有
use Data::Dumper; #这个模块的作用是改变变量打印的格式而已

$ratio_cutoff_initial=0.5;
$overlap_cutoff_initial=50;

$overlap_cutoff=100;
$ratio_cutoff=0.5;
$ratio_bb_cutoff=0.5;
$score_cutoff=0;
$block_cutoff=100;



$org=$ARGV[0];
$db=$org;
#$link="DBI:mysql:database=".$db.";host=localhost";
#$ENV{MYSQL_UNIX_PORT} = "/home/zhangy/tmp/mysql.sock";
#$dbh = DBI->connect($link,"zhangy", "newstart123",{'RaiseError' => 1}); #这个上面为什么这么进入数据库呢改成之前的那样不行吗？
#下面这个会更简单一点吧
#$mysql_align_database = $ARGV[0];
$mysql_user = "yuanh";
$mysql_passwd = "yuanhao123";
$string="DBI:mysql:database=".$db.";host=localhost";
$dbh = DBI->connect($string,$mysql_user, $mysql_passwd,{'RaiseError' => 1});

#



#$sql="select distinct species from mm2.xref_chr_length where species = 'rn4'";
$sql="select distinct ref_species from axt_hs_other";
$sth = $dbh->prepare($sql);
$sth -> execute();
while ($ref=$sth->fetchrow_hashref()) {
    push @orgs, $ref->{ref_species};
#    push @orgs, $ref->{species};
# print "$ref->{ref_species}\n";
}
$sth->finish();
#print join "\t",@orgs;

# foreach $org(@orgs) {
#     print "$org varchar(100) not null,"
# }
#$sql="select transcript,chrom_start,chrom_end,chrom,gene,t_length from transcript ";
$sql="select transcript, chrom_start, chrom_end, chrom, gene,t_length from transcript where rowid between $ARGV[1] and $ARGV[2]"; #这两个全局变量是哪些呢？不是说只输入一个数据库名变量吗？
#$sql="select transcript, chrom_start, chrom_end, chrom, gene,t_length from transcript where transcript = 'ENST00000326183'";
#$sql="select transcript, chrom_start, chrom_end, chrom, gene,t_length from transcript where gene in (select gene from xref_pb_mouse_hs)";
#$sql="select * from flyBaseGene where gene in (select distinct gene from xref_gb_parental union select distinct gene from xref_gb_retro union select distinct gene from xref_roman union select distinct cid from xref_wenwang)";
$sth = $dbh->prepare($sql);
$sth -> execute();
while ($ref=$sth->fetchrow_hashref()) {
    $txEnd=$ref->{chrom_end};
    $txStart=$ref->{chrom_start};
    $length=$txEnd-$txStart;
    $rna=$ref->{gene};
    $exonLength=$ref->{t_length};
    undef @exist;
    undef @exon; undef @exonStart; undef @exonEnd;
    undef $exon_sql;

    $sql="select * from exon where transcript = '$ref->{transcript}' order by rank asc";
    $sth1 = $dbh->prepare($sql);
    $sth1 -> execute();
    while ($ref1=$sth1->fetchrow_hashref()) {
        push @exon,"'".$ref1->{exon}."'"; #这句话怎么理解呢？是数组中按照'分割吗？
        push @exonStart,$ref1->{chrom_start};
        push @exonEnd,$ref1->{chrom_end};
    }
    $sth1->finish();
    $exon_sql="(".join(",",@exon).")";
#    print Dumper(@exonEnd);

#scan exons in dm_VS_si table then in si_VS_dm table to look for reciprocal best relationships
    foreach $species(@orgs) {
        $sub_table="axt_hs_other_filtered";
#        $sub_table="axt_sub_filtered";
        $ref_table="axt_other_hs_filtered";
#        $ref_table="axt_ref_filtered";
        foreach ($i=0;$i<=$#exonStart;$i++) {
            $tmp="select sub, sub_start, sub_end, ref, ref_start, ref_end, score, strand, (if($exonEnd[$i]<=sub_end,$exonEnd[$i],sub_end)-if($exonStart[$i]>=sub_start, $exonStart[$i], sub_start)) as overlap from $sub_table t1, axt_exon_subid t2 where t1.id = t2.id and t2.exon = $exon[$i] and ((if($exonEnd[$i]<=sub_end,$exonEnd[$i],sub_end)-if($exonStart[$i]>=sub_start, $exonStart[$i], sub_start))/($exonEnd[$i]-$exonStart[$i]) >= $ratio_cutoff_initial or (if($exonEnd[$i]<=sub_end,$exonEnd[$i],sub_end)-if($exonStart[$i]>=sub_start, $exonStart[$i], sub_start))>=$overlap_cutoff_initial) and ref_species = '$species' and score > -2000 group by t1.id";
#            print $tmp,"\n";
            if ($i==0) {
                $sql="create temporary table tmp0 $tmp";
            } else {
                $sql="insert into tmp0 $tmp";
            }
            $dbh->do($sql);
        }
        $sql="alter table tmp0 add rowid int not null auto_increment, add primary key(rowid)";
        $dbh->do($sql);
        $sql="create temporary table tmp1 select t1.* from tmp0 t1, $ref_table t2, axt_exon_refid t3 where t3.exon in $exon_sql and t3.id = t2.id and t2.sub_end - t2.sub_start >= $block_cutoff and t2.score > $score_cutoff and sub_species = '$species' and t1.strand = t2.strand and t1.ref = t2.sub and t1.sub = t2.ref and ((t1.ref_start between t2.sub_start and t2.sub_end) or (t1.ref_end between t2.sub_start and t2.sub_end) or (t1.ref_start < t2.sub_start and t2.sub_end<t1.ref_end)) and ((t2.ref_start between t1.sub_start and t1.sub_end) or (t2.ref_end between t1.sub_start and t1.sub_end) or (t2.ref_start < t1.sub_start and t1.sub_end<t2.ref_end)) group by t1.rowid;";
        $dbh->do($sql);

 #        $sql="insert into tmp_tmp0 select *,'$species','$rna' from tmp0";
#         $dbh->do($sql);
#         $sql="insert into tmp_tmp1 select *,'$species','$rna' from tmp1";
#         $dbh->do($sql);

        @table=qw(tmp0 tmp1);
        undef @chr;
        foreach $table(@table) {
            $sql="select *, round(overlap/$exonLength,2) as ratio from (select ref, tSize, strand, sum(overlap) overlap, count(*) number, min(sub_start) sub_start, max(sub_end) sub_end, min(ref_start) ref_start, max(ref_end) ref_end, sum(distinct score) score from $table, xref_chr_length t2 where ref = tName and t2.species = '$species' group by ref, strand) tmp where overlap/$exonLength >= $ratio_cutoff or overlap>=$overlap_cutoff order by overlap desc";
            $sth2 = $dbh->prepare($sql);
            $sth2 -> execute();
            $ref2=$sth2->fetchrow_hashref();
            push @chr,$ref2;
            $sth2->finish();
            $sql="drop table $table";
            $dbh->do($sql);
        }
#        print Dumper(@chr);
        if ($chr[1]->{tSize} && ($chr[1]->{overlap}/$chr[0]->{overlap}>$ratio_bb_cutoff)) {
            $exist=join(":",2,$chr[1]->{ratio},$chr[1]->{ref},sprintf('%.2f',$chr[1]->{tSize}/1000000),$chr[1]->{ref_start},$chr[1]->{ref_end});
        } elsif ($chr[0]->{tSize}) {
            $exist=join(":",1,$chr[0]->{ratio},$chr[0]->{ref},sprintf('%.2f',$chr[0]->{tSize}/1000000),$chr[0]->{ref_start},$chr[0]->{ref_end});
        } else {
            $exist=0;
        }
        push @exist,$species.":".sprintf('%.1f',$length/1000).":".$exist;

    }
    print join("\t",$ref->{transcript},@exist),"\n";
}

$sth->finish();

$dbh->disconnect();
