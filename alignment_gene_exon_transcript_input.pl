#! /usr/bin/perl  -w

use DBI;
use IO::File;

$mysql_align_database = $ARGV[0];
$mysql_user = "yuanh";
$mysql_passwd = "YOURPASSWD";
$file_gene = $ARGV[1];
$file_exon = $ARGV[2];
$file_transcript = $ARGV[3];


$string="DBI:mysql:database=".$mysql_align_database.";host=localhost";
$dbh = DBI->connect($string,$mysql_user, $mysql_passwd,{'RaiseError' => 1});

$dbh->do("DELETE FROM gene WHERE 1");
$dbh->do("DELETE FROM exon WHERE 1");
$dbh->do("DELETE FROM transcript WHERE 1");
$in = new IO::File "<".$file_exon;
$count=0;
while($line=$in->getline)
{
     chomp($line);
     @words=split(/\t/,$line);
     $transcript=$words[0];
     $exon=$words[1];
     $rank=$words[2];
     $phase=$words[3];
     $cds_start=$words[4];
     $cds_end=$words[5];
     $pep_start=$words[6];
     $pep_end=$words[7];
     $chrom_start=$words[8];
     $chrom_end=$words[9];
     $count=$count+1;
     $id=$count;
     if(!$rank){ $rank=0; }
     if(!$cds_start) { $cds_start=0; }
     if(!$cds_end)   { $cds_end=0; }
     if(!$pep_start) { $pep_start=0; }
     if(!$pep_end)   { $pep_end=0;  }
     $dbh->do("INSERT INTO exon  (transcript,exon,rank,phase,cds_start,cds_end,pep_start,pep_end,chrom_start,chrom_end,id) VALUES 
	  (".$dbh->quote($transcript).",".$dbh->quote($exon).",".$rank.",".$dbh->quote($phase).",".$cds_start.",".$cds_end.",".$pep_start.",".$pep_end.",".$chrom_start.",".$chrom_end.",".$id.")");

}


$in = new IO::File "<".$file_gene;
while($line=$in->getline)
{
     chomp($line);
     @words=split(/\t/,$line);
     $gene=$words[0];
     $description=$words[1];
     $status=$words[2];
     $biotype=$words[3];
     $dbh->do("INSERT INTO gene  (gene,description,status,biotype) VALUES 
	  (".$dbh->quote($gene).",".$dbh->quote($description).",".$dbh->quote($status).",".$dbh->quote($biotype).")");

}


$in = new IO::File "<".$file_transcript;
$count=0;
while($line=$in->getline)
{
     chomp($line);
     @words=split(/\t/,$line);
     $gene=$words[0];
     $transcript=$words[1];
     $t_length=$words[2];
     $peptide=$words[3];
     $p_length=$words[4];
     $t_start=$words[5];
     $t_end=$words[6];
     $cc_start=$words[7];
     $cc_end=$words[8];
     $chrom=$words[9];
     $chrom_start=$words[10];
     $chrom_end=$words[11];
     $strand=$words[12];
     $t_seq=$words[13];
     $cds_seq=$words[14];
     $pep_seq=$words[15];
     $count+=1;
     $rowid=$count;  
     if(!$t_length) { $t_length=0; }
     if(!$p_length) { $p_length=0; }
     if(!$t_start) { $t_start=0; }
     if(!$t_end) { $t_end=0; }
     if(!$cc_start) { $cc_start=0; }
     if(!$cc_end) { $cc_end=0; }
     if(!$t_seq) { $t_seq=""; }
     if(!$cds_seq) { $cds_seq=""; }
     if(!$pep_seq) { $pep_seq=""; }

     $dbh->do("INSERT INTO transcript  (gene,transcript,t_length,peptide,p_length,t_start,t_end,cc_start,cc_end,chrom,chrom_start,chrom_end,strand,t_seq,cds_seq,pep_seq,rowid) VALUES 
	  (".$dbh->quote($gene).",".$dbh->quote($transcript).",".$t_length.",".$dbh->quote($peptide).",".$p_length.",".$t_start.",".$t_end.",".$cc_start.",".$cc_end.",".$dbh->quote($chrom).",".$chrom_start.",".$chrom_end.",".$dbh->quote($strand).",".$dbh->quote($t_seq).",".$dbh->quote($cds_seq).",".$dbh->quote($pep_seq).",".$rowid.")");

}
