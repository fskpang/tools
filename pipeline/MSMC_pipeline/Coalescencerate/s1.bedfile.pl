#!/usr/bin/perl
use warnings;
use strict;
#tongji
if (@ARGV !=6) {
	print "perl $0 <poplist><bamlist><ref><depth><chrlist><outdir>\n";
	exit 0;
}
my ($poplist,$bamlist,$ref,$depth,$chrlist,$outdir)=@ARGV;
open IN,$poplist or die $!;
my %intersting_pop=();
while(<IN>){
    chomp;
    my @a=split;
    my $i=1;
    my $num=scalar@a;
    while($i<$num){
        my $sam=$a[$i];
        $intersting_pop{$sam}=1;
        $i++;
    }
}
close IN;
if($bamlist=~/.gz/) {open IN,"zcat $bamlist|" or die $!;}  else{open IN,$bamlist or die $!;}
open T,$chrlist or die $!;
my %chrome=();while(<T>){chomp;$chrome{$_}=1;}
close T;
if( ! -e "$outdir") {`mkdir $outdir`;}
open BED,'>',"$outdir/step1_bedfile.sh" or die $!;
my %hash=();
my $sh=<<Script;
export LD_LIBRARY_PATH=/opt/blc/python-3.1.2/lib:\$LD_LIBRARY_PATH;
python='/opt/blc/python-3.1.2/bin/python3.1'
samtools='/ifshk5/BC_COM_P11/F16RD04012/ICEmmrD/bin/software/samtools-0.1.19/samtools'
bcftools='/ifshk5/BC_COM_P11/F16RD04012/ICEmmrD/bin/software/samtools-0.1.19/bcftools/bcftools'
tools='/ifshk5/BC_COM_P11/F16RD04012/ICEmmrD/bin/software/history/MSMC/msmc-master/tools'
ref=$ref
Script
my $ave_depth=$depth;
while(<IN>){
    chomp;
    my ($sample,$bam,$bool)=(split)[0,1,2];
    next unless($intersting_pop{$sample});
    my $sam_outdir="$outdir/MSMCinputfile/$sample";
    if( ! -e "$outdir/MSMCinputfile") {`mkdir "$outdir/MSMCinputfile"`;}
    if( ! -e "$sam_outdir") {`mkdir $sam_outdir`;}
    if($bool ne "ALLchr") {
        my $chr=$bool;
        open T,">$sam_outdir/msmc_bed_$chr.sh" or die $!;
my $sh2=<<Script;
cd $sam_outdir
date
echo start
\$samtools mpileup -q 20 -Q 20 -C 50 -u -r $chr -P ILLUMINA -f \$ref $bam|\$bcftools view -cgI - |\$python \$tools/bamCaller.py $ave_depth $sample.$chr.mask.bed > $sample.$chr.raw.vcf
date
echo end
Script
        print T "$sh\n$sh2\n";
        close T;
        print BED "cd $sam_outdir;sh msmc_bed_$chr.sh\n";
        next;
    }
#==============bam including all chromosome=========    
    foreach my $chr(sort keys %chrome){
#        `ln -s /ifshk5/BC_COM_P11/F16RD04012/ICEmmrD/work/Yao90/history/new_MSMC/1KG_Coalescence_rate_8haplotype/bin/1KG_bed/chr$chr.mask.bed $sam_outdir/$sample.$chr.mask.bed`;
#        `ln -s /ifshk5/BC_COM_P11/F16RD04012/ICEmmrD/work/Yao90/history/new_MSMC/Coalescence_rate/bin/1KG/chr$chr.mask.bed $sam_outdir/$sample.$chr.mask.bed`;
        open T,">$sam_outdir/msmc_bed_$chr.sh" or die $!;
my $sh2=<<Script;
cd $sam_outdir
date
echo start
\$samtools mpileup -q 20 -Q 20 -C 50 -u -r $chr -P ILLUMINA -f \$ref $bam|\$bcftools view -cgI - |\$python \$tools/bamCaller.py $ave_depth $sample.$chr.mask.bed > $sample.$chr.raw.vcf
date
echo end

Script
        print T "$sh\n$sh2\n";
        close T;
        print BED "cd $sam_outdir;sh msmc_bed_$chr.sh\n";
    }
}

close BED;
close IN;   
