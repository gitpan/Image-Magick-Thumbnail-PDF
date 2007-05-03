use Test::Simple 'no_plan';
use strict;
use lib './lib';
use Image::Magick::Thumbnail::PDF 'create_thumbnail';
use Cwd;
use Smart::Comments '###';
use File::Path;
use File::Copy;



### seek convert

my $convert_bin = `which convert`; chomp $convert_bin;

ok($convert_bin!~/no convert in/ , 'convert bin found');



Image::Magick::Thumbnail::PDF::DEBUG = 1;
my $abs_pdf = cwd().'/t/test/linux_quickref.pdf';



File::Path::rmtree(cwd().'/t/test');
ok( mkdir (cwd.'/t/test'),'made test dir');

ok( File::Copy::cp( cwd().'/t/linux_quickref.pdf', $abs_pdf), 'copied test file to test dir' );



my $out ;

ok( $out = create_thumbnail($abs_pdf),'create_thumbnail()');
### $out

ok( $out eq cwd().'/t/test/linux_quickref-0.png','create_thumbnail() returns as expected');




### variations

ok( $out = create_thumbnail($abs_pdf,5),'create_thumbnail() 1');
### $out
ok( $out eq  cwd().'/t/test/linux_quickref-5.png','create_thumbnail() returns as expected 1');


ok( $out = create_thumbnail($abs_pdf,cwd().'/t/test/haha.gif'),'create_thumbnail() 2');
### $out
ok( $out eq  cwd().'/t/test/haha.gif','create_thumbnail() returns as expected 2');




ok( $out = create_thumbnail($abs_pdf,cwd().'/t/test/haha.png',2),'create_thumbnail() 3');
### $out
ok( $out eq  cwd().'/t/test/haha.png','create_thumbnail() returns as expected 3');



ok( $out = create_thumbnail($abs_pdf, { restriction => 50, frame => 2, },5),'create_thumbnail() 4');
### $out
ok( $out eq  cwd().'/t/test/linux_quickref-5.png','create_thumbnail() returns as expected 4');


### other examples

ok(
 create_thumbnail(
	$abs_pdf,
	cwd().'/t/test/big.png',
	{ 
		restriction => 350, 
		frame => 6, 
		normalize => 0,
	},
	5,
),'create_thumbnail()');




ok(
 create_thumbnail(
	$abs_pdf,
	cwd().'/t/test/bigger.png',
	{ 
		restriction => 800, 
		frame => 6, 
		normalize => 0,
	},
	5,
),'create_thumbnail()');

