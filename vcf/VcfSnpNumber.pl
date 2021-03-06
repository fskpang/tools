#!/usr/bin/perl
my $f=shift;
my $num=0;
open(IN, "$f");
open(OUT, "> $f.snpNum");

while(<IN>){
    chomp;
    next if (/^#/);
    my @a=split (/\s+/);
    next if (length($a[3])>1 || length($a[4]>1));
    next if ($a[7] =~ /^INDEL/);
    $a[7] =~ /;AF1=([\.\d]+);/;
    next if($1==1);
    $num++;
}
close IN;
print OUT "$f snp number:\t$num\n";
close OUT;
