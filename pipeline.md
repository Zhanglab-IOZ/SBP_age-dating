SBP dating process
===
#### human/hg38 as an example

yuanhao
2019-8-27



## Data preparation

1.  ensembl core api ftp://ftp.ensembl.org/pub/ensembl-api.tar.gz 

    #still you should check the version of api on the ensembl website. my version is 95, and the latest release is 97.

2.  ensembl hg38 mysql core ftp://ftp.ensembl.org/pub/release-97/mysql/homo_sapiens_core_97_38/*
3.  a gene-transcript list of human from ensembl biomart
4.  human genome and annotation from ensembl
5.  hg38.OUTGROUP.net.axt.gz & OUTGROUP.hg38.net.axt.gz files from UCSC. http://hgdownload.soe.ucsc.edu/downloads.html
6.  repeat element file from repeat masker in UCSC

    #take human and chimp for example
    
    #http://hgdownload.soe.ucsc.edu/goldenPath/hg38/vsPanTro6/hg38.panTro6.net.axt.gz
    #http://hgdownload.soe.ucsc.edu/goldenPath/panTro6/vsHg38/panTro6.hg38.net.axt.gz

    #if there were no .net.axt.gz files, you should download the .net files and converted to .axt files. please refer to http://genomewiki.ucsc.edu/index.php/HowTo:_Syntenic_Net_or_Reciprocal_Best
    
    #.net files can be also converted from OUTGROUP.hg38.net to hg38.OUTGROUP.net, so you can just download one of the file and convert to another if one is not provided in UCSC.


## The formation of gene, transcript, exon lists

1.  create the core database
    ```bash
    $ mysql -u yuanh '-e create database homo_sapiens_core_95_38 ' -p
    $ mysql -u yuanh homo_sapiens_core_95_38 < ./core/homo_sapiens_core_95_38.sql -p
    $ mysqlimport -u yuanh  --fields_escaped_by=\\ homo_sapiens_core_95_38  -L ./core/*.txt  -p
    ```

2.  gene, transcript, exon list files formation
    ```bash
    $ sed '1d' mart_export-Human.txt |cut -f 1|sort -u >mart_hg38_geneID.txt 
    #(gene ID list)

    $ perl ~/Gentree/scripts/dating_process/ens_transcript.pl homo_sapiens_core_95_38 mart_hg38_geneID.txt 
    #ens_transcript.pl need to be modified
    #output files: mart_hg38_geneID.txt.gene, mart_hg38_geneID.txt.exon, mart_hg38_geneID.txt.transcript
    ```
    `ens_transcript.pl` need to be modified that *lib* directs to *module* directory of ensembl core, change the *username* and *password*, and comment out the colume *status* because it is of no need anymore.

3.  convert the format of chr/assembly from ensembl to UCSC

    for the  name format of assemblies, please refer to https://genome-asia.ucsc.edu/cgi-bin/hgTracks?chromInfoPage=&
    
    we only need to convert names for matched assemblies, and just delete those assemblies whose names are total different.
    I almost converted manually.

## Data for age-dating database
1.  import data into dating database
    ```bash
    $ mysql -u yuanh '-e create database age_dating_homo_sapiens_core_95_38' -p
    $ mysql -u yuanh age_dating_homo_sapiens_core_95_38 < ../scripts/dating_process/in1.pl -p 
    ```
    modify the structure of table *axt_synteny* in scripts `in1.pl`, and change the species and order to your outgroup species before this step
    
    the order of species matters! you'd better keep the order of species in the pipeline
    ```bash
    $ perl ../scripts/dating_process/alignment_gene_exon_transcript_input.pl age_dating_homo_sapiens_core_95_38 mart_hg38_geneID.txt.gene mart_hg38_geneID.txt.exon.mdfyd mart_hg38_geneID.txt.transcript.mdfyd 
    # It works as same as:
    # mysql> load data local infile '/home/yuanh/rd/gentree/human/mart_hg38_geneID.txt.exon(or gene, transcript).mdfyd' into table exon(or gene, transcript) field terminated by '\t' lines terminated by '\n';
    ```
2.  correct the strand in table transcript accprding to gtf file
    ```bash
    $ grep 'transcript_id' Homo_sapiens.GRCh38.95.gtf | cut -f 1,7,9 | sed 's/gene_id.*transcript_id "//g'|sed 's/"; transcript_version.*//g' |sort -u >> hg38_transcript_strand_chrom
    ```
    don't forget to convert the chr/assembly names into UCSC format
    ```sql
    mysql> CREATE TABLE `trans_gtf` (`chrom` varchar(30) NOT NULL, `strand` char(1) NOT NULL, `transcript` varchar(30) NOT NULL, PRIMARY KEY (`transcript`)) ;
    mysql> load data local infile "/rd/yuanh/gentree/human/hg38_transcript_strand_chrom" into table trans_gtf;
    mysql> update transcript t1, trans_gtf t2 set t1.strand= t2.strand where t1.transcript =t2.transcript; 
    ```
3.  input the axt files into dating-database
    ```bash
    $ perl pair_data_deal.pl >pair_input_bash
    ```
    modify `pair_data_deal.pl`, array *@a* contains all the outgroup species, *\$c[\$i]* contains all the hg38 and outgroup axt file names, and *print()* direct to the directory of axt files

    ```bash
    $ bash pair_input_bash
    ```
    each part of `pair_input_bash`, it looks like:
    
    >perl alignment_axt_input.pl AGE_DATING_DATABASE directory/to/hg38vsOUTGROUP directory/to/OUTGROUPvshg38 OUTGROUPspecies

4.  input chr-size for each species
    ```bash
    $ cat hg38.chrom.sizes | while read LINE1; do echo -e "$LINE1""\t""hg38" >> hg38_size.sql; done

    $ for i in `ls`; do cat ./"$i"/"$i".chrom.sizes | while read LINE1; do echo -e "$LINE1""\t""$i" >> ./"$i"/"$i"_size.sql; done; cat ./"$i"/"$i"_size.sql >> species_size.sql; done
    # `ls` here is for the list of outgroup species and human 
    ```
    ```sql
    mysql> load data local infile '/rd/yuanh/gentree/human/species_size.sql' INTO TABLE xref_chr_length FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n';
    ```

    ```bash 
    $ perl alignment_ref_positions_change.pl age_dating_homo_sapiens_core_95_38 yuanh YOURPASSWD
    ```

5.  dating-pipeline
    1.  find the exons overlapping with axt blocks
        ```bash
        $ mysql -u yuanh age_dating_homo_sapiens_core_95_38 -e "select t1.chrom, t1.chrom_start, t1.chrom_end, exon, t1.chrom_end-t1.chrom_start+1, strand from exon t1, transcript t2 where t1.transcript = t2.transcript;" -p > hg38_exon.bed
        $ sed '1d' hg38_exon.bed > hg38_exon_1.bed
        $ mysql -u yuanh age_dating_homo_sapiens_core_95_38 -e "select sub, sub_start, sub_end, id, round(score), strand from axt_hs_other;" -p > hg38_sub.bed
        $ sed '1d' hg38_sub.bed > hg38_sub_1.bed
        $ mysql -u yuanh age_dating_homo_sapiens_core_95_38 -e "select ref, ref_start, ref_end, id, round(score), strand from axt_other_hs;" -p > hg38_ref.bed
        $ sed '1d' hg38_ref.bed > hg38_ref_1.bed

        $ ../UCSC_tools/overlapSelect -idOutput hg38_sub_1.bed hg38_exon_1.bed hg38_sub.exon
        $ ../UCSC_tools/overlapSelect -idOutput hg38_ref_1.bed hg38_exon_1.bed hg38_ref.exon

        $ less hg38_sub.exon | sed '1d' | sort -u > hg38_sub_1.exon 
        $ less hg38_ref.exon | sed '1d' | sort -u > hg38_ref_1.exon 
        ```

        ```sql
        mysql> load data local infile "/home/yuanh/rd/gentree/human/hg38_sub_1.exon" into table axt_exon_subid;
        mysql> load data local infile "/home/yuanh/rd/gentree/human/hg38_ref_1.exon" into table axt_exon_refid;

        mysql>  insert into axt_hs_other_filtered select t1.* from axt_hs_other t1, axt_exon_subid t2 where t1.id = t2.id group by t1.id;
        mysql>  insert into axt_other_hs_filtered select t1.* from axt_other_hs t1, axt_exon_refid t2 where t1.id = t2.id group by t1.id;
        ```
    
    2.  input repeats loci
        ```bash
        $ less Galaxy1-\[UCSC_Main_on_Human__rmsk_\(genome\)\].interval | cut -f 6-8 | sort -u > hg38_repeat.bed
        $ sed '$d' hg38_repeat.bed | sort -u > hg38_repeat_1.bed

        $ ../UCSC_tools/overlapSelect -aggregate -statsOutput hg38_repeat_1.bed hg38_exon_1.bed hg38_exon.repeats
        $ sed '1d' hg38_exon.repeats | sort -u > hg38_exon_1.repeats 
        ```
        ```sql
        mysql> load data local infile "/rd/yuanh/gentree/human/hg38_exon_1.repeats" into table ann_exon_repeats;
        ```
    3.  judge whether the transcript best hit between 2 species
        ```sql
        mysql> select count(*) from transcript;
        +----------+
        | count(*) |
        +----------+
        |   206601 |
        +----------+
        1 row in set (0.00 sec)
        ```

        ```bash
        $ perl fold_sql.pl age_dating_homo_sapiens_core_95_38 206601 > exon_bash
        $ bash exon_bash
        # in this script, hs_dating.pl will be called so you should modify mysql information in advance
        ```
        several .exon files will appear in the directory

        `hs_dating.pl` judge whether the exon were best hit across 2 species

        **if there were severe problems in the former steps, all the lines in .exon files will be "0".** if that happens, you must check each tables if they were well intergrated especially the name and order of outgroup spcies.
    4.  dating
        ```
        mysql> select distinct ref_species from axt_hs_other;
        mysql>  desc axt_synteny ;
        ```
        the order of the species must be same! if not, you should recreate the table `axt_synteny`.
        ```bash
        $ for i in {1..26}; do cat exon."$i" >> hg38_transcript.axt; done
        ```
        ```sql
        mysql> load data local infile '/rd/yuanh/gentree/human/hg38_transcript.axt' into table axt_synteny;
        ```
        ```bash
        $ perl ../scripts/dating_process/phy_hg38.pl age_dating_homo_sapiens_core_95_38 > hg38_axt.branch
        ```
        `phy_hg38.pl` finds the best hits of each transcript across 2 species, and find the branch which the best hit could reach. the branch with longest distince will be determined as the origin of the transcript. this script will also note repeats in the genome from repeat informations provided in table.
        ```bash
        $ less hg38_axt.branch | cut -f 2 | sort | uniq -c
        # check the overview of the age(transcript) distribution in branches
        ```

        ```sql
        mysql> load data local infile '/rd/yuanh/gentree/human/hg38_axt.branch' into table axt_branch;

        mysql> update axt_branch t1, transcript t2 set t1.gene = t2.gene, t1.chrom = t2.chrom where t1.transcript =t2.transcript;

        mysql> alter table axt_branch_final drop rowid;

        mysql> insert into axt_branch_final select * from (select t1.* from axt_branch t1,gene t2,transcript t3 where pep_seq!='' and t1.transcript=t3.transcript and t1.gene=t2.gene and biotype='protein_coding' and note='NA' order by gene ,branch asc,pre desc,post asc )t1 group by gene;
        mysql> insert into axt_branch_final  select * from (select t1.* from axt_branch t1,gene t2  where  t1.gene=t2.gene and biotype!='protein_coding' and note='NA' order by gene ,branch asc,pre desc,post asc )t1 group by gene;
        # filetered all the genes on chrs and not in repeat elements

        mysql> alter table axt_branch_gene drop rowid;
        mysql> insert into axt_branch_gene select t1.* from axt_branch_final t1, gene t2 where t1.gene = t2.gene and biotype = 'protein_coding' and chrom not in ('chrY','chrM','chrUn_GL000219v1','chrUn_GL000195v1','chrUn_GL000213v1','chrUn_GL000218v1','chrUn_GL000220v1','chrUn_GL000216v2','chrUn_KI270442v1');
        # because of a bug in phy_hg38.pl, there are chrUns in the table. check if by "mysql> select distinct chrom from axt_branch_final;", and filter them out

        mysql> select count(*) from axt_branch_gene;
        +----------+
        | count(*) |
        +----------+
        |    19850 |
        +----------+
        mysql> select count(*) from gene where biotype="protein_coding";
        +----------+
        | count(*) |
        +----------+
        |    22686 |
        +----------+

        #we can see that there were 816 genes were filtered out

        mysql> select branch,count(*) from axt_branch_gene group by branch;
        +--------+----------+
        | branch | count(*) |
        +--------+----------+
        |      0 |    12345 |
        |      1 |     2625 |
        |      2 |      950 |
        |      3 |      931 |
        |      4 |     1005 |
        |      5 |      923 |
        |      6 |      113 |
        |      7 |       84 |
        |      8 |      226 |
        |      9 |      150 |
        |     10 |       74 |
        |     11 |       66 |
        |     12 |      105 |
        |     13 |       49 |
        |     14 |      204 |
        +--------+----------+
        # a blur overview of dating process
6.  a modify step invented by Y.Shao.
    1.  prepare .net files of each outgroup species, hg38.OUTGROUP.net and OUTGROUP.hg38.net from UCSC
    2.  filter out nonsyteny net blocks through information provieded in .net files, which can improve the accuracy of dating
        ```bash
        $ for i in panTro6 gorGor5 ponAbe3 nomLeu3 rheMac8 calJac3 oryCun2 cavPor3 rn6 mm10 bosTau9 oviAri4 canFam3 loxAfr3 monDom5 ornAna2 galGal6 taeGut2 anoCar2 xenTro9 gasAcu1 tetNig2 danRer11; do sh trans_hg38.sh ${i}; done |& tee trans_hg38.log

        $ for i in panTro6 gorGor5 ponAbe3 nomLeu3 rheMac8 calJac3 oryCun2 cavPor3 rn6 mm10 bosTau9 oviAri4 canFam3 loxAfr3 monDom5 ornAna2 galGal6 taeGut2 anoCar2 xenTro9 gasAcu1 tetNig2 danRer11; do awk '{if($14=='1') print $0}' hg38."$i".net.mysql.labeled.axt > hg38."$i".net.mysql.labeled.no-nonsyn.axt; awk '{if($14=='1') print $0}' "$i".hg38.net.mysql.labeled.axt > "$i".hg38.net.mysql.labeled.no-nonsyn.axt; wc -l hg38."$i".net.mysql.labeled.no-nonsyn.axt; wc -l "$i".hg38.net.mysql.labeled.no-nonsyn.axt; done

        $ for i in panTro6 gorGor5 ponAbe3 nomLeu3 rheMac8 calJac3 oryCun2 cavPor3 rn6 mm10 bosTau9 oviAri4 canFam3 loxAfr3 monDom5 ornAna2 galGal6 taeGut2 anoCar2 xenTro9 gasAcu1 tetNig2 danRer11; do cat hg38."$i".net.mysql.labeled.no-nonsyn.axt >> hs.other.labeled.axt; cat "$i".hg38.net.mysql.labeled.no-nonsyn.axt >>  other.hs.labeled.axt; done
        ```
    3.  dating

        almost the same as raw dating process
        ```sql
        mysql> create table axt_hs_other_modify like axt_hs_other_filtered;
        mysql> create table axt_other_hs_modify like axt_other_hs_filtered;

        mysql> alter table axt_hs_other_modify add column netType int(8);
        mysql> alter table axt_other_hs_modify add column netType int(8);

        mysql> load data local infile "/rd/yuanh/gentree/modify/hs.other.labeled.axt" into table axt_hs_other_modify;
        mysql> load data local infile "/rd/yuanh/gentree/modify/other.hs.labeled.axt" into table axt_other_hs_modify;
        ```
        ```baash
        $ perl fold_sql_modify.pl age_dating_homo_sapiens_core_95_38 206601 > exon_bash_modify
        $ bash exon_bash_modify

        $ for i in {1..26}; do cat exon."$i" >> hg38_transcript_modify.axt; done
        ```
        ```sql
        mysql> CREATE TABLE axt_synteny_modify like axt_synteny;

        mysql> load data local infile '/rd/yuanh/gentree/modify/hg38_transcript_modify.axt' into table axt_synteny_modify;
        ```
        ```bash
        $ perl ../scripts/dating_process/phy_hg38_modify.pl age_dating_homo_sapiens_core_95_38 > hg38_modify_axt.branch
        $ less hg38_modify_axt.branch | cut -f 2 | sort | uniq -c
        ```
        ```sql
        mysql> create table axt_branch_modify like axt_branch;

        mysql> load data local infile '/rd/yuanh/gentree/modify/hg38_modify_axt.branch' into table axt_branch_modify;

        mysql> update axt_branch_modify t1, transcript t2 set t1.gene = t2.gene, t1.chrom = t2.chrom where t1.transcript = t2.transcript;

        mysql> create table axt_branch_final_modify like axt_branch_final;

        mysql>  insert into axt_branch_final_modify select * from (select t1.* from axt_branch_modify t1, gene t2, transcript t3 where pep_seq != '' and t1.transcript = t3.transcript and t1.gene = t2.gene and biotype = 'protein_coding' and note = 'NA' order by gene, branch asc) t1 group by gene;

        mysql>  insert into axt_branch_final_modify select * from (select t1.* from axt_branch_modify t1, gene t2 where t1.gene = t2.gene and biotype != 'protein_coding' and note = 'NA' order by gene, branch asc) t1 group by gene; 

        mysql> create table axt_branch_gene_modify like axt_branch_gene;

        mysql> insert into axt_branch_gene_modify select t1.* from axt_branch_final_modify t1, gene t2 where t1.gene = t2.gene and biotype = 'protein_coding' and chrom not in ('chrY','chrM','chrUn_GL000219v1','chrUn_GL000195v1','chrUn_GL000213v1','chrUn_GL000218v1','chrUn_GL000220v1','chrUn_GL000216v2','chrUn_KI270442v1' );

        mysql> select branch,count(*) from axt_branch_gene_modify  group by branch;
        +--------+----------+
        | branch | count(*) |
        +--------+----------+
        |      0 |    11563 |
        |      1 |     2909 |
        |      2 |      990 |
        |      3 |      914 |
        |      4 |     1030 |
        |      5 |     1288 |
        |      6 |      141 |
        |      7 |       82 |
        |      8 |      228 |
        |      9 |      169 |
        |     10 |       59 |
        |     11 |       94 |
        |     12 |      106 |
        |     13 |       59 |
        |     14 |      218 |
        +--------+----------+
        15 rows in set (0.01 sec)
        ```
7.  remove the unreliable branches and genes
    ```
    mysql> select * from  axt_branch_final_modify limit 5;
    +-----------------+--------+-----+------+------+-----------------+------+-------+
    | transcript      | branch | pre | post | note | gene            | bias | chrom |
    +-----------------+--------+-----+------+------+-----------------+------+-------+
    | ENST00000373020 |      0 |   2 |    0 | NA   | ENSG00000000003 |      | chrX  |
    | ENST00000373031 |      0 |   3 |    0 | NA   | ENSG00000000005 |      | chrX  |
    | ENST00000413082 |      0 |   4 |    0 | NA   | ENSG00000000419 |      | chr20 |
    | ENST00000367772 |      0 |   4 |    0 | NA   | ENSG00000000457 |      | chr1  |
    | ENST00000496973 |      0 |   3 |    0 | NA   | ENSG00000000460 |      | chr1  |
    +-----------------+--------+-----+------+------+-----------------+------+-------+
    ```
    *branch* represent the branch gene originated, *pre* represent the sum of relative branches that have the orthlog of gene, and *post* reperesent the sum of distant branches. in general, the higher the pre and the lower the psot, the higher reliability of the result for the transcript.
    
    ```bash
    $ mysql -u yuanh -e "select * from  age_dating_homo_sapiens_core_95_38.axt_branch_gene_modify" > hg38_axt_branch_gene_modify -p
    $ less hg38_axt_branch_gene_modify | cut -f 2,3,4 | sort -n | uniq -c
    # a general view for transcript, branch, pre and post
    ```
    you'd better discuss with prof. for it before you decide to remove the branches.

    ```sql
    mysql> create table axt_branch_gene_modify_select1 like axt_branch_gene_modify;
    mysql>  insert into axt_branch_gene_modify_select1 select t1.* from axt_branch_final_modify_select1 t1, gene t2 where t1.gene = t2.gene and biotype = 'protein_coding';
    ```
    ```sql
    mysql> select branch, count(*) from axt_branch_gene_modify_select1 group by branch;
    # the primary results of age-dating
    ```
