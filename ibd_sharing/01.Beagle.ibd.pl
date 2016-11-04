my $out="$0.out";
`mkdir $out`;
open(O,"> $0.sh");
my @vcf=<00.Pruned.SNP/*vcf.gz>;
foreach my $vcf(@vcf){
    $vcf =~ /\/(.*).vcf.gz/;
    my $chr=$1;
    print O "date;export JAVAHOME=/ifshk4/BC_PUB/biosoft/PIPE_RD/Package/java/jre1.8.0_45; /ifshk4/BC_PUB/biosoft/PIPE_RD/Package/java/jre1.8.0_45/bin/java -jar /ifshk5/PC_HUMAN_EU/USER/wanglizhong/software/beagle/4.1/beagle.27Jul16.86a.jar ibd=true impute=false window=7000 overlap=3000 ibdlod=3 ibdtrim=180 gt=$vcf out=$out/$chr; date;\n";
}
close O;
