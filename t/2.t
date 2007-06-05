use Test::Simple 'no_plan';
use strict;
use lib './lib';
use Image::Magick::Thumbnail::PDF ':all';
use Cwd;
use Smart::Comments '###';
use File::Path;
use File::Copy;
use File::Which 'which';


### seek convert
ok( which('convert'), 'which convert bin found');

Image::Magick::Thumbnail::PDF::DEBUG = 1;


#setup

my @pdfs;

for (qw(test1 test2 test3)){

	mkdir cwd()."/t/$_";
	File::Copy::cp(cwd().'/t/ap.pdf', cwd()."/t/$_/ap.pdf");
	push @pdfs,  cwd()."/t/$_/ap.pdf";
}



### ONE PAGE

my $out = create_thumbnail($pdfs[0],{ restriction => 200});
ok(-f $out, "$out exists" );


### ALL PAGES
my $out = create_thumbnail($pdfs[1],'all_pages',{ restriction => 200});
for(@$out){
	ok(-f $_, "out $_ exists");
}



### ALL OUT 

my $out2 = create_thumbnail($pdfs[2],'all_pages',{ restriction => 125, frame=>4, normalize => 1 });
for(@$out2){
	ok(-f $_, "out $_ exists");
}



