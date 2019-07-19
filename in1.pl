-- MySQL dump 10.13  Distrib 5.1.61, for pc-linux-gnu (x86_64)
--
-- Host: localhost    Database: hs4
-- ------------------------------------------------------
-- Server version	5.0.45-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Not dumping tablespaces as no INFORMATION_SCHEMA.FILES table on this server
--

--
-- Table structure for table `ann_exon_repeats`
--

DROP TABLE IF EXISTS `ann_exon_repeats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ann_exon_repeats` (
  `exon` varchar(30) NOT NULL,
  `proportion` float NOT NULL,
  `overlap` int(11) NOT NULL,
  `exonLength` int(11) NOT NULL,
  PRIMARY KEY  (`exon`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `axt_branch`
--

DROP TABLE IF EXISTS `axt_branch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `axt_branch` (
  `transcript` varchar(30) NOT NULL,
  `branch` tinyint(4) NOT NULL,
  `pre` tinyint(4) NOT NULL,
  `post` tinyint(4) NOT NULL,
  `note` varchar(30) NOT NULL,
  `gene` varchar(30) NOT NULL,
  `bias` varchar(10) NOT NULL,
  `chrom` varchar(50) NOT NULL,
  KEY `gene` (`gene`),
  KEY `transcript` (`transcript`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `axt_branch_final`
--

DROP TABLE IF EXISTS `axt_branch_final`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `axt_branch_final` (
  `transcript` varchar(30) NOT NULL,
  `branch` tinyint(4) NOT NULL,
  `pre` tinyint(4) NOT NULL,
  `post` tinyint(4) NOT NULL,
  `note` varchar(30) NOT NULL,
  `gene` varchar(30) NOT NULL,
  `bias` varchar(10) NOT NULL,
  `chrom` varchar(50) NOT NULL,
  `rowid` int(11) NOT NULL auto_increment,
  UNIQUE KEY `rowid` (`rowid`),
  KEY `gene` (`gene`),
  KEY `transcript` (`transcript`)
) ENGINE=MyISAM AUTO_INCREMENT=48011 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `axt_branch_gene`
--

DROP TABLE IF EXISTS `axt_branch_gene`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `axt_branch_gene` (
  `transcript` varchar(30) NOT NULL,
  `branch` tinyint(4) NOT NULL,
  `pre` tinyint(4) NOT NULL,
  `post` tinyint(4) NOT NULL,
  `note` varchar(30) NOT NULL,
  `gene` varchar(30) NOT NULL,
  `bias` varchar(10) NOT NULL,
  `chrom` varchar(50) NOT NULL,
  `rowid` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`transcript`),
  UNIQUE KEY `gene` (`gene`),
  UNIQUE KEY `rowid` (`rowid`)
) ENGINE=MyISAM AUTO_INCREMENT=19990 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `axt_exon_refid`
--

DROP TABLE IF EXISTS `axt_exon_refid`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `axt_exon_refid` (
  `exon` varchar(30) NOT NULL,
  `id` varchar(30) NOT NULL,
  KEY `id` (`id`),
  KEY `exon` (`exon`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `axt_exon_subid`
--

DROP TABLE IF EXISTS `axt_exon_subid`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `axt_exon_subid` (
  `exon` varchar(30) NOT NULL,
  `id` varchar(30) NOT NULL,
  KEY `id` (`id`),
  KEY `exon` (`exon`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `axt_hs_other`
--

DROP TABLE IF EXISTS `axt_hs_other`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `axt_hs_other` (
  `sub` varchar(50) NOT NULL,
  `sub_start` int(11) NOT NULL,
  `sub_end` int(11) NOT NULL,
  `ref` varchar(50) NOT NULL,
  `ref_start` int(11) NOT NULL,
  `ref_end` int(11) NOT NULL,
  `strand` char(1) NOT NULL,
  `score` float NOT NULL,
  `sub_species` varchar(10) NOT NULL,
  `ref_species` varchar(10) NOT NULL,
  `id` varchar(30) NOT NULL,
  `tmp_ref_start` int(11) NOT NULL,
  `tmp_ref_end` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `axt_hs_other_filtered`
--

DROP TABLE IF EXISTS `axt_hs_other_filtered`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `axt_hs_other_filtered` (
  `sub` varchar(50) NOT NULL,
  `sub_start` int(11) NOT NULL,
  `sub_end` int(11) NOT NULL,
  `ref` varchar(50) NOT NULL,
  `ref_start` int(11) NOT NULL,
  `ref_end` int(11) NOT NULL,
  `strand` char(1) NOT NULL,
  `score` float NOT NULL,
  `sub_species` varchar(10) NOT NULL,
  `ref_species` varchar(10) NOT NULL,
  `id` varchar(30) NOT NULL,
  `tmp_ref_start` int(11) NOT NULL,
  `tmp_ref_end` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `ref_species` (`ref_species`,`ref`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `axt_other_hs`
--

DROP TABLE IF EXISTS `axt_other_hs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `axt_other_hs` (
  `sub` varchar(50) NOT NULL,
  `sub_start` int(11) NOT NULL,
  `sub_end` int(11) NOT NULL,
  `ref` varchar(50) NOT NULL,
  `ref_start` int(11) NOT NULL,
  `ref_end` int(11) NOT NULL,
  `strand` char(1) NOT NULL,
  `score` float NOT NULL,
  `sub_species` varchar(10) NOT NULL,
  `ref_species` varchar(10) NOT NULL,
  `id` varchar(30) NOT NULL,
  `tmp_ref_start` int(11) NOT NULL,
  `tmp_ref_end` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `axt_other_hs_filtered`
--

DROP TABLE IF EXISTS `axt_other_hs_filtered`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `axt_other_hs_filtered` (
  `sub` varchar(50) NOT NULL,
  `sub_start` int(11) NOT NULL,
  `sub_end` int(11) NOT NULL,
  `ref` varchar(50) NOT NULL,
  `ref_start` int(11) NOT NULL,
  `ref_end` int(11) NOT NULL,
  `strand` char(1) NOT NULL,
  `score` float NOT NULL,
  `sub_species` varchar(10) NOT NULL,
  `ref_species` varchar(10) NOT NULL,
  `id` varchar(30) NOT NULL,
  `tmp_ref_start` int(11) NOT NULL,
  `tmp_ref_end` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

#--
#-- Table structure for table `axt_ref_filtered`
#--

#DROP TABLE IF EXISTS `axt_ref_filtered`;
#/*!40101 SET @saved_cs_client     = @@character_set_client */;
#/*!40101 SET character_set_client = utf8 */;
#CREATE TABLE `axt_ref_filtered` (
# `sub` varchar(30) NOT NULL,
# `sub_start` int(11) NOT NULL,
# `sub_end` int(11) NOT NULL,
# `ref` varchar(30) NOT NULL,
# `ref_start` int(11) NOT NULL,
# `ref_end` int(11) NOT NULL,
# `strand` char(1) NOT NULL,
# `score` float NOT NULL,
# `sub_species` varchar(10) NOT NULL,
# `ref_species` varchar(10) NOT NULL,
# `id` varchar(30) NOT NULL,
# `tmp_ref_start` int(11) NOT NULL,
# `tmp_ref_end` int(11) NOT NULL,
# PRIMARY KEY  (`id`)
#) ENGINE=MyISAM DEFAULT CHARSET=latin1;
#/*!40101 SET character_set_client = @saved_cs_client */;

#--
#-- Table structure for table `axt_sub_filtered`
#--

#DROP TABLE IF EXISTS `axt_sub_filtered`;
#/*!40101 SET @saved_cs_client     = @@character_set_client */;
#/*!40101 SET character_set_client = utf8 */;
#CREATE TABLE `axt_sub_filtered` (
#  `sub` varchar(30) NOT NULL,
#  `sub_start` int(11) NOT NULL,
#  `sub_end` int(11) NOT NULL,
#  `ref` varchar(30) NOT NULL,
#  `ref_start` int(11) NOT NULL,
#  `ref_end` int(11) NOT NULL,
#  `strand` char(1) NOT NULL,
#  `score` float NOT NULL,
#  `sub_species` varchar(10) NOT NULL,
#  `ref_species` varchar(10) NOT NULL,
#  `id` varchar(30) NOT NULL,
#  `tmp_ref_start` int(11) NOT NULL,
#  `tmp_ref_end` int(11) NOT NULL,
#  PRIMARY KEY  (`id`),
#  KEY `ref_species` (`ref_species`,`ref`)
#) ENGINE=MyISAM DEFAULT CHARSET=latin1;
#/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `axt_synteny`
--

DROP TABLE IF EXISTS `axt_synteny`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `axt_synteny` (
  `transcript` varchar(30) NOT NULL,
  `panTro6` varchar(100) NOT NULL,
  `ponAbe3` varchar(100) NOT NULL,
  `nomLeu3` varchar(100) NOT NULL,
  `rheMac8` varchar(100) NOT NULL,
  `calJac3` varchar(100) NOT NULL,
  `oryCun2` varchar(100) NOT NULL,
  `cavPor3` varchar(100) NOT NULL,
  `rn6` varchar(100) NOT NULL,
  `mm10` varchar(100) NOT NULL,
  `oviAri4` varchar(100) NOT NULL,
  `canFam3` varchar(100) NOT NULL,
  `bosTau8` varchar(100) NOT NULL,
  `loxAfr3` varchar(100) NOT NULL,
  `monDom5` varchar(100) NOT NULL,
  `ornAna2` varchar(100) NOT NULL,
  `galGal6` varchar(100) NOT NULL,
  `taeGut2` varchar(100) NOT NULL,
  `anoCar2` varchar(100) NOT NULL,
  `xenTro9` varchar(100) NOT NULL,
  `gasAcu1` varchar(100) NOT NULL,
  `tetNig2` varchar(100) NOT NULL,
  `danRer11` varchar(100) NOT NULL,
  PRIMARY KEY  (`transcript`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exon`
--

DROP TABLE IF EXISTS `exon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exon` (
  `transcript` varchar(30) NOT NULL,
  `exon` varchar(30) NOT NULL,
  `rank` int(11) NOT NULL,
  `phase` varchar(2) NOT NULL,
  `cds_start` int(11) NOT NULL,
  `cds_end` int(11) NOT NULL,
  `pep_start` int(11) NOT NULL,
  `pep_end` int(11) NOT NULL,
  `chrom_start` int(11) NOT NULL,
  `chrom_end` int(11) NOT NULL,
  `cDNA_start` int(11) NOT NULL,
  `cDNA_end` int(11) NOT NULL,
  `chrom` varchar(40) NOT NULL,
  `id` int(11) NOT NULL auto_increment,
  UNIQUE KEY `id` (`id`),
  KEY `exon` (`exon`),
  KEY `transcript` (`transcript`),
  KEY `chrom` (`chrom`,`chrom_start`,`chrom_end`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gene`
--

DROP TABLE IF EXISTS `gene`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gene` (
  `gene` varchar(30) NOT NULL,
  `description` text NOT NULL,
  `status` varchar(30) NOT NULL,
  `biotype` varchar(30) NOT NULL,
  PRIMARY KEY  (`gene`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transcript`
--

DROP TABLE IF EXISTS `transcript`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transcript` (
  `gene` varchar(30) NOT NULL,
  `transcript` varchar(30) NOT NULL,
  `t_length` int(11) NOT NULL,
  `peptide` varchar(30) NOT NULL,
  `p_length` int(11) NOT NULL,
  `t_start` int(11) NOT NULL,
  `t_end` int(11) NOT NULL,
  `cc_start` int(11) NOT NULL,
  `cc_end` int(11) NOT NULL,
  `chrom` varchar(40) NOT NULL,
  `chrom_start` int(11) NOT NULL,
  `chrom_end` int(11) NOT NULL,
  `strand` char(1) NOT NULL,
  `t_seq` mediumtext NOT NULL,
  `cds_seq` mediumtext NOT NULL,
  `pep_seq` text NOT NULL,
  `rowid` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`transcript`),
  UNIQUE KEY `rowid` (`rowid`),
  KEY `gene` (`gene`),
  KEY `peptide` (`peptide`)
) ENGINE=MyISAM AUTO_INCREMENT=205280 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `xref_chr_length`
--

DROP TABLE IF EXISTS `xref_chr_length`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `xref_chr_length` (
  `tName` varchar(255) NOT NULL default '',
  `tSize` int(10) unsigned NOT NULL default '0',
  `species` varchar(10) NOT NULL,
  KEY `tName` (`tName`,`species`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-09-08  0:44:01
