#!/usr/bin/perl
# @(#)fold_sql.pl
#4800 perl path: /export/home/zhangy/programs/perl/bin/perl
#ibm perl path: /gpfs/chenyj/program/perl/bin/perl

=head1 Usage, parameters of input and output

 Usage: 
 @ARGV: 
 Output: 

=head1 Copyright

 Author: Zhangy
 URL: http://pak.cbi.pku.edu.cn
 Date: 2008-08-14

=cut
$part=int($ARGV[1]/25);
for ($i=1;$i<=26;$i++) {
#    $cmd="exon_dating.pl ".$ARGV[0]." ".(($i-1)*$part+1)." ".($i*$part)." > exon.$i &";
#   $cmd="bed_dating_dm.pl ".$ARGV[0]." ".(($i-1)*$part+1)." ".($i*$part)." > exon.$i &";
   $cmd="perl /rd/yuanh/gentree/scripts/dating_process/hs_dating.pl ".$ARGV[0]." ".(($i-1)*$part+1)." ".($i*$part)." > /rd/yuanh/gentree/human/exon.$i &";
#     $cmd="retro_best_check.pl pp 2 ".(($i-1)*$part+1)." ".($i*$part)." &";
#     $cmd="roi_exon.pl hs2  ".(($i-1)*$part+1)." ".($i*$part)." > $i.roi &";
     print $cmd,"\n";
     system($cmd);
}
