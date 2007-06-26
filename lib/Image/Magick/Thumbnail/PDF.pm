package Image::Magick::Thumbnail::PDF;
use strict;
use Carp;
require Exporter;
#use Smart::Comments '###';
use File::Which;

use vars qw{$VERSION @ISA @EXPORT_OK %EXPORT_TAGS};
$VERSION = sprintf "%d.%02d", q$Revision: 1.9 $ =~ /(\d+)/g;

@ISA = qw(Exporter);
@EXPORT_OK = qw(create_thumbnail);
%EXPORT_TAGS = (
	all => \@EXPORT_OK,
);


$Image::Magick::Thumbnail::PDF::DEBUG = 0;
sub DEBUG : lvalue { $Image::Magick::Thumbnail::PDF::DEBUG }

sub create_thumbnail {

	# BEGIN GET PARAMS
	
	my ($abs_pdf,$abs_out,$page_number,$arg,$all);
	$abs_pdf = shift; $abs_pdf or croak(__PACKAGE__."::create_thumbnail() missing abs pdf argument");
	

	my $name_of_outfile_in_arguments=0;
	
	for (@_){
		my $val = $_;
		print " val [$val]\n" if DEBUG;

		if (ref $val eq 'HASH'){
			$arg = $val; print STDERR " got args hash ref\n" if DEBUG;
		}
		elsif ($val=~/^\d+$/){
			$page_number = $val; print STDERR " got page number $val\n" if DEBUG;			
		}		
		elsif ($val eq 'all_pages'){
			$all=1; print STDERR " got flag to do all pages\n" if DEBUG;
		}
		elsif ($val=~/[^\/]+\.\w{2,4}$/){
			$abs_out = $val; print STDERR " got abs out [$val]\n" if DEBUG;
			$name_of_outfile_in_arguments=1;
		}
		else { croak(__PACKAGE__."::create_thumbnail() bogus argument [$val]"); }	
	}

	$arg ||={};
	$arg->{restriction} ||= 125;
	unless( defined $arg->{frame} ){ $arg->{frame} = 6; }
	unless( defined $arg->{normalize}){ $arg->{normalize} = 1; }


	# if we are putting a border, we still want the restriction asked for to be obeyed
	if ($arg->{frame}){
		$arg->{restriction} = ($arg->{restriction} - ($arg->{frame}  * 2) );
	}
	
	$all ||= 0;
	$page_number ||= 1;
		
	unless( $name_of_outfile_in_arguments ){		
		$abs_out = $abs_pdf; 
		$abs_out=~s/\.\w{3,5}$/\.png/;
	}

	$arg->{frame}=~/^\d+$/ or croak(__PACKAGE__."::create_thumbnail() argument 'frame' is not a number");

	$arg->{restriction}=~/^\d+$/ or 
		croak(__PACKAGE__."::create_thumbnail() argument 'restriction' is invalid");

	if (DEBUG){ 
		printf STDERR __PACKAGE__."::create_thumbnail() debug.. \n";
		printf STDERR " abs_pdf %s\n page_number %s\n abs_out %s, all? %s\n", $abs_pdf, $page_number, $abs_out, $all;
		### $arg
	}

	# END GET PARAMS








	require Image::Magick::Thumbnail;

	my $src = new Image::Magick;
	my $err = $src->Read($abs_pdf);#	warn("92 ++++ $err") if $err;
	print STDERR "ok read $abs_pdf\n" if DEBUG;
	
	
	if (!$all){			
			my $image = $src->[($page_number-1)];
			defined $image or warn("file [$abs_pdf] page number [$page_number] does not exist?") and return;
			my $out = _dopage($image,$abs_out,$page_number,$arg,$name_of_outfile_in_arguments);		
			return $out;
		}
	else {
			print STDERR "Do all pages\n" if DEBUG;
			my $pagenum = 1;
			my @outs;
			for ( @$src ){			
				my $out = _dopage($_,$abs_out,$pagenum,$arg);			
				push @outs, $out;
				$pagenum++;
			}
			return \@outs;
	}



	sub _dopage {
			my ($image,$abs_out,$pagenum,$arg,$name_of_outfile_in_arguments) = @_;
			$pagenum = sprintf "%03d", $pagenum;
			
			unless( $name_of_outfile_in_arguments ){
				$abs_out=~s/(\.\w{3,5})$/-$pagenum$1/;
			}	
			
		


			if ( $arg->{normalize} ){
				my $step = $arg->{restriction} * 2;	
				my ($i,$x,$y) = Image::Magick::Thumbnail::create($image,$step);
				$i->Normalize;
				$image = $i;
				print STDERR "Normalized\n" if DEBUG;
			}

			
			my($thumb,$x,$y) = Image::Magick::Thumbnail::create($image,$arg->{restriction});



			if ($arg->{frame}){
				$image->Frame($arg->{frame}.'x'.$arg->{frame});
				print STDERR "framing $$arg{frame}\n" if DEBUG;
			}

			my $err= $thumb->Write($abs_out); #warn("141 +++ $err") if $err;
			return $abs_out;		
	}

}




1;

__END__

=pod

=head1 NAME

Image::Magick::Thumbnail::PDF - make thumbnail of a page in a pdf document

=head1 SYNOPSIS

	use Image::Magick::Thumbnail::PDF 'create_thumbnail';

	my $out = create_thumbnail('/home/myself/mypdfile.pdf');
	
=head1 DESCRIPTION

I wanted a quick sub to make a thumbnail of a pdf.
The goal of this module is to make a quick thumbnail of a page in a pdf.

They give the viewer an idea of what is inside the document, but is not meant as a replacement
for the actual file.

This module is a quick interface to a predetermined use of convert.
There are a ton of ways to do this via ImageMagick and convert, etc. I took what seemed to make most
sense from various suggestions/ideas, and slapped this together. If you think something can be 
better, please contact the L<AUTHOR>.

No subroutines are exported by default.

=head1 create_thumbnail()

argument is absolute path to pdf file

Will not check if the thumbnail exists already ot not.
The first argument must be the abs path to the pdf file.

optional argument is destination, default is same as abs_pdf but a .png extension instead.
The name of the file(s) saved will be argument (pdf) as png

optional argument is a hash ref with following options
	restriction frame normalize

returns abs path to thumbnail file created.
If the subroutine is provided really dumb arguments, it croaks. Otherwise it carps and returns undef on
failures.

=head2 Options

'normalize' must be true or false (default is true). This increases contrast a bit.

'restriction' is a pixel ammount, the mzx widht and height for the thumgnail, the default is 125.

'frame' is a frame border around the iamge, since the pdf is usually white, this helps a lot
for making sense to the user. default is 6.
	
The first optional argument can be an absolute path to a filename (which will be your thumbnail).
By default this will make a simple thumbnail of the first page (page 0).

If you ask to make a thumbnail of all pages, it returns an array ref of the absolute paths to the files created.

=head2 Examples

The following example creates /abs/file-000.png 125x125 thumbnail image of first page.

	create_thumbnail('/abs/file.pdf');

To create a thumb for page 5 instead:
	
	create_thumbnail('/abs/file.pdf',5); # creates '/abs/file-005.png'

To create a thumb for page 6 with restriction 200, a frame of 2 px, and no normalize:

	create_thumbnail('/abs/file.pdf',6,
		{ restriction => 200, frame => 2, normalize => 0 
	}); # creates '/abs/file-006.png' 

To save a thumbnial of page 3 named differently, in another palce

	create_thumbnail('/abs/file.pdf','/abs/another/page3.png',3,
		{ restriction => 200, frame => 2, normalize => 0 
	}); # creates '/abs/file-006.png' 



=head2 Making All Thumbnails

This can be slow! This can be useful offline, but I don't suggest it real-time. You try it out.

The following examples makes  '/abs/f-001.png',  '/abs/f-002.png',  '/abs/f-003.png', etc.

	my $all = create_thumbnail('/abs/file.pdf','all_pages');

The returned value is an array ref holding ['/abs/file-001.png',  '/abs/file-002.png',  '/abs/file-003.png'].

=head3 PAGE NUMBERS

The first page is page #1
If you ask for page 0, croaks.

=head3 GIF

TODO: spit out all thumbs of all pages into one gif.
NOT IMPLEMENTED presently.

The following example makes '/abs/file.gif', which is an animated gif with heach frame being a page in the document.

	create_thumbnail('/abs/file.pdf','all_pages','/abs/file.gif');




=head3 Please Note

If you make all thumbnails and specify as output a .gif file, the output image is an animated gif, with 
each page in its own frame. This may or may not be what you desire.

=head2 Using Normalize

A lot of scans are typed pages, written pages. When you make a thumbnail of this, you can't see anything.
By default normalize is used to accentuate lines. This creates an extra step in the process, the image is sized
down about halfway between the target size and the original size, the filter is applied, and then resized down
again. So- if you do or do not use normalize (on by default) you will see a large change in time taken.

=head2 Return Value

If you tell create_thumbnail() what page you want, it returns a string
If you do not tell it, it assumes you want all pages, and it will return an array ref instead
in all cases, the returned are absolute paths to the thubmnail created

=head1 DEBUGGING

Note that if you enable debugger 

	$Image::Magick::Thumbnail::PDF::DEBUG = 1;

You will see that a restriction of 125 changes to 113.. how come? Because we compensate for the frame size.
Asking for a thumbnail no wider or taller then 125 px gives you just that. 

=head1 PREREQUISITES

Image::Magick 
Image::Magick::Thumbnail
Smart::Comments
File::Which
Carp

=head1 SEE ALSO

ImageMagick on the web, convert.
L<Image::Magick::Thumbnail>

=head1 AUTHOR

Leo Charre leocharre at cpan dot org

=cut




