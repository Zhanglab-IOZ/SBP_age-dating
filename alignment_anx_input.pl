#! /usr/bin/perl  -w

use DBI;
use IO::File;

$mysql_database =$ARGV[0];
$mysql_user= "yuanh";                      # $ARGV[1];
$mysql_passwd="YOURPASSWD";    #$ARGV[2];
#open(FILE,"pair_name_table")||die("Coudn't not open file");
#while($line=<FILE>)
#{
# @a=split(/\t/,$line);
# print" $a[0] \t";
 #print "$a[1]\t";
 #print" $a[2]\t";
 #print "\n";
 #$sub_files_dir=$a[0];
 #$other_files_dir=$a[1];
 #$org=$a[2];

$sub_files_dir = $ARGV[1];
$other_files_dir = $ARGV[2];
$org = $ARGV[3];

$string="DBI:mysql:database=".$mysql_database.";host=localhost:1998";
#$string="DBI:mysql:database=".$mysql_database.";host=localhost";

$dbh = DBI->connect($string,$mysql_user, $mysql_passwd,{'RaiseError' => 1});

#$dbh->do("DELETE FROM axt_sub_other WHERE ref_species = '".$org."'");

#open (FILE,"/home/chency/gene_dating/software/scripts/pair_name_table")|| die ("Coudn't not open file");
#while($line=<FILE>)
#{
#	@a=split(/\t/,$line);
#	$sub_files_dir=$a[0];
#	$other_files_dir=$a[1];
#	$org=$a[2];
#	&data_deal;
#print "$sub_files_dir \n";
#print "$other_files_dir \n";
#}
$dbh->do("DELETE FROM axt_hs_other WHERE ref_species = '".$org."'");
#$sth = $dbh->prepare("select count(*) from axt_sub_other");
$sth = $dbh->prepare("select count(*) from axt_hs_other");
$sth -> execute();
$ref=$sth->fetchrow_hashref();
$count=$ref->{"count(*)"}+1;

opendir(DIR,$sub_files_dir);
while(my $file = readdir(DIR))
{
   if($file=~/axt/)
   {
     chomp($file);
     @words=split(/\./,$file);
#	if(@words>4)
#     {
#	$tag_chr=$words[0];
#	$sub_species=$words[1];
#	$ref_species=$words[2];
#     }     
#     else
#     {     
        $tag_chr="chr";     
	$sub_species=$words[0];	        
	$ref_species=$words[1];
#     }				     
  #   $sub_chr=$words[0];
  #   $sub_species=$words[1];
  #   $ref_species=$words[2];
     print ">>".$sub_species." to ".$ref_species." in ".$tag_chr."\n";
     $in = new IO::File "<".$sub_files_dir."/".$file."";
     while($line=$in->getline)
     {
       @uuwords=split(/\s/,$line);
       if($line=~/\#/)
       { next; }
       elsif(@uuwords==9)
       {
          chomp($line);
	  @words=split(/\s/,$line);
	  $sub_chr=$words[1];
	  $sub_start=$words[2];
	  $sub_end=$words[3];
	  $ref_chr=$words[4];
	  $ref_start=$words[5];
	  $ref_end=$words[6];
	  $strand=$words[7];
          $score=$words[8];
	  $list_id="sub".$count;
	  $count+=1;
#	  $dbh->do(INSERT INTO axt_sub_other  (sub,sub_start,sub_end,ref,tmp_ref_start,tmp_ref_end,strand,score,sub_species,ref_species,id) VALUES 
	  $dbh->do("INSERT INTO axt_hs_other  (sub,sub_start,sub_end,ref,tmp_ref_start,tmp_ref_end,strand,score,sub_species,ref_species,id) VALUES 
	  (".$dbh->quote($sub_chr).",".$sub_start.",".$sub_end.",".$dbh->quote($ref_chr).",".$ref_start.",".$ref_end.",".$dbh->quote($strand).",".$score.",".$dbh->quote($sub_species).",".$dbh->quote($ref_species).",".$dbh->quote($list_id).")");
       }
       else
       { next; }
     }
   }

}

closedir(DIR);

#$dbh->do("DELETE FROM axt_other_sub WHERE sub_species = '".$org."'");
$dbh->do("DELETE FROM axt_other_hs WHERE sub_species = '".$org."'");
#$sth = $dbh->prepare("select count(*) from axt_other_sub");
$sth = $dbh->prepare("select count(*) from axt_other_hs");
$sth -> execute();
$ref=$sth->fetchrow_hashref();
$count=$ref->{"count(*)"}+1;
opendir(DIR,$other_files_dir);

while(my $file = readdir(DIR))
{
   if($file=~/axt/)
   {
     chomp($file);
     @words=split(/\./,$file);
#     if(@words>4)
#     {
#     $tag_chr=$words[0];
#     $sub_species=$words[1];
#     $ref_species=$words[2];
#     }
#     else
#     {
     $tag_chr="chr";
     $sub_species=$words[0];
     $ref_species=$words[1];
#     }
     print ">>".$sub_species." to ".$ref_species." in ".$tag_chr."\n";
     $in = new IO::File "<".$other_files_dir."/".$file."";
     while($line=$in->getline)
     {
       
       @uuwords=split(/\s/,$line);
       if($line=~/\#/)
       { next; }
       elsif(@uuwords==9)
       {
          chomp($line);
	  @words=split(/\s/,$line);
	  $sub_chr=$words[1];
	  $sub_start=$words[2];
	  $sub_end=$words[3];
	  $ref_chr=$words[4];
	  $ref_start=$words[5];
	  $ref_end=$words[6];
	  $strand=$words[7];
          $score=$words[8];
	  $list_id="ref".$count;
	  $count+=1;
#	  print join("\t",@words)."\n";
#	  $dbh->do("INSERT INTO axt_other_sub  (sub,sub_start,sub_end,ref,tmp_ref_start,tmp_ref_end,strand,score,sub_species,ref_species,id) VALUES 
	  $dbh->do("INSERT INTO axt_other_hs  (sub,sub_start,sub_end,ref,tmp_ref_start,tmp_ref_end,strand,score,sub_species,ref_species,id) VALUES 
	  (".$dbh->quote($sub_chr).",".$sub_start.",".$sub_end.",".$dbh->quote($ref_chr).",".$ref_start.",".$ref_end.",".$dbh->quote($strand).",".$score.",".$dbh->quote($sub_species).",".$dbh->quote($ref_species).",".$dbh->quote($list_id).")");
       }
       else
       {  next; }
     }
   }

}

closedir(DIR);

