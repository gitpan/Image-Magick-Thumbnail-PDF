use Test::Simple 'no_plan';
use strict;
use lib './lib';
use Image::Magick::Thumbnail::PDF 'create_thumbnail';
use Cwd;
use Smart::Comments '###';
use File::Path;
use File::Copy;

$Image::Magick::Thumbnail::PDF::DEBUG = 1;
my $abs_pdf = cwd().'/t/test0/file1.pdf';

File::Path::rmtree(cwd().'/t/test0');
File::Path::rmtree(cwd().'/t/test1');
File::Path::rmtree(cwd().'/t/test2');
File::Path::rmtree(cwd().'/t/test3');

ok( mkdir (cwd.'/t/test0'),'made test dir');
ok( File::Copy::cp( cwd().'/t/file1.pdf', $abs_pdf), 'copied test file to test dir' );



my $out;

ok( $out = create_thumbnail($abs_pdf,1),'create_thumbnail()');
### $out
ok( $out eq cwd().'/t/test0/file1-001.png','create_thumbnail() returns as expected');











### variations

ok( $out = create_thumbnail($abs_pdf,2),'create_thumbnail() 1');
### $out
ok( $out eq  cwd().'/t/test0/file1-002.png','create_thumbnail() returns as expected 1');





#ok( $out = create_thumbnail($abs_pdf, $abs_pdf.'.gif', 2),'create_thumbnail() b');
## $out
#ok( $out eq $abs_pdf.'-002.gif','create_thumbnail() returns as expected b');



#my $outw= cwd().'/t/test0/haha.png';
#ok( $out = create_thumbnail($abs_pdf, $outw,2),'create_thumbnail() 3');
## $out
#ok( $out eq  $outw,'create_thumbnail() returns as expected 3');



ok( $out = create_thumbnail($abs_pdf, { restriction => 50, frame => 2, },2),'create_thumbnail() 4');
### $out
ok( $out eq  cwd().'/t/test0/file1-002.png','create_thumbnail() returns as expected 4');


### other examples

ok(
 create_thumbnail(
	$abs_pdf,
	{ 
		restriction => 350, 
		frame => 6, 
		normalize => 0,
	},
	2,
),'create_thumbnail()');




ok(
 create_thumbnail(
	$abs_pdf,
	{ 
		restriction => 800, 
		frame => 6, 
		normalize => 0,
	},
	1,
),'create_thumbnail()');

