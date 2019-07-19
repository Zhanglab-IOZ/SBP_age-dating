#! /usr/bin/perl  -w

use DBI;
use IO::File;

$mysql_align_database = $ARGV[0];
$mysql_user = $ARGV[1];
$mysql_passwd = $ARGV[2];


system("mysql --password='".$mysql_passwd."' -e \"select tName,tSize,species from xref_chr_length\" ".$mysql_align_database."> ./temp_chr_lengths");
#system("mysql --password='".$mysql_passwd."' -e \"select id,ref,ref_species,strand,tmp_ref_start,tmp_ref_end from axt_sub_other \" ".$mysql_align_database."> ./temp_ref_list_1");
system("mysql --password='".$mysql_passwd."' -e \"select id,ref,ref_species,strand,tmp_ref_start,tmp_ref_end from axt_hs_other \" ".$mysql_align_database."> ./temp_ref_list_1");
#system("mysql --password='".$mysql_passwd."' -e \"select id,ref,ref_species,strand,tmp_ref_start,tmp_ref_end from axt_other_sub \" ".$mysql_align_database."> ./temp_ref_list_2");
system("mysql --password='".$mysql_passwd."' -e \"select id,ref,ref_species,strand,tmp_ref_start,tmp_ref_end from axt_other_hs \" ".$mysql_align_database."> ./temp_ref_list_2");

$in = new IO::File ("< ./temp_chr_lengths");
while($line=$in->getline)
{
   chomp($line);
   @words=split(/\t/,$line);
   $len{$words[2]}{$words[0]}=$words[1];
}
$string="DBI:mysql:database=".$mysql_align_database.";host=localhost";
$dbh = DBI->connect($string,$mysql_user, $mysql_passwd,{'RaiseError' => 1});

$in = new IO::File ("< ./temp_ref_list_1");
#$line=$in->getline;
while($line=$in->getline)
{
   chomp($line);
   @words=split(/\t/,$line);
   $id=$words[0];
   $ref=$words[1];
   $ref_species= $words[2];
   $strand=$words[3];
   $start=$words[4];
   $end=$words[5];
   if($strand eq '-')
   {
#       print $ref_species."\t".$ref."\t".$len{$ref_species}{$ref}."\n";
      $new_start=$len{$ref_species}{$ref}-$end+1;
      $new_end=$len{$ref_species}{$ref}-$start+1;
   }
   else
   {
      $new_start=$start;
      $new_end=$end;
   }
   #$dbh->do("UPDATE axt_sub_other SET `ref_start` = ".$new_start.", `ref_end` = ".$new_end." WHERE id='".$id."';");
   $dbh->do("UPDATE axt_hs_other SET `ref_start` = ".$new_start.", `ref_end` = ".$new_end." WHERE id='".$id."';");
}

$in = new IO::File ("< ./temp_ref_list_2");
#$line=$in->getline;
while($line=$in->getline)
{
   chomp($line);
   @words=split(/\t/,$line);
   $id=$words[0];
   $ref=$words[1];
   $ref_species= $words[2];
   $strand=$words[3];
   $start=$words[4];
   $end=$words[5];
   if($strand eq '-')
   {
      $new_start=$len{$ref_species}{$ref}-$end+1;
      $new_end=$len{$ref_species}{$ref}-$start+1;
   }
   else
   {
      $new_start=$start;
      $new_end=$end;
   }
   #$dbh->do("UPDATE axt_other_sub SET `ref_start` = ".$new_start.", `ref_end` = ".$new_end." WHERE id='".$id."';");
   $dbh->do("UPDATE axt_other_hs SET `ref_start` = ".$new_start.", `ref_end` = ".$new_end." WHERE id='".$id."';");
}


#system("rm ./temp_chr_lengths; rm ./temp_ref_list_1; rm ./temp_ref_list_2");
