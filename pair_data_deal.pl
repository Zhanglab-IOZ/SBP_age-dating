#!/usr/bin/perl -w
#$mysql_database="";
#$username="";
#$passwd="";
@a=("panTro6","ponAbe3","nomLeu3","rheMac8","calJac3","oryCun2","cavPor3","rn6","mm10","oviAri4","canFam3","bosTau8","loxAfr3","monDom5","ornAna2","galGal6","taeGut2","anoCar2","xenTro9","gasAcu1","tetNig2","danRer11");


#$count=length(@a);
#print "@a \n";
for ($i=0;$i<@a;$i++)
{
	#print "$a[$i] \n";
	#    	$c[$i]=("mm10vs".$a[$i],$a[$i],"vsmm10",$a[$i]);
	$c[$i]=(["hg38vs$a[$i]","$a[$i]vshg38","$a[$i]"]);
	# print @c[$i];
	#print "$c[$i][0] \t";
	#print "$c[$i][1] \t";
	# print "$c[$i][2] \t";

#open(FILE,"/home/chency/gene_dating/software/scripts/pair_name_table")|| die("Coudn't not open file");
#@while ($line=<FILE>) 
#{
# @a=split(/\t/,$line);
# print " $a[3] \n";
print ("echo $a[$i] \n perl ~/rd/gentree/scripts/dating_process/alignment_anx_input.pl age_dating_homo_sapiens_core_95_38  ~/rd/gentree/species/$a[$i]/$c[$i][0] ~/rd/gentree/species/$a[$i]/$c[$i][1] $c[$i][2] \n sleep 5 \n") ;
}
	


	
#close FILE or die "can not close FILE";
