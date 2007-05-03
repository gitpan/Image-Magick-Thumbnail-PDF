package Image::Magick::Thumbnail::PDF;
use strict;
use Carp;
require Exporter;
use Smart::Comments '###';

use vars qw{$VERSION @ISA @EXPORT_OK %EXPORT_TAGS};
$VERSION = sprintf "%d.%02d", q$Revision: 1.5 $ =~ /(\d+)/g;

@ISA = qw(Exporter);
@EXPORT_OK = qw(create_thumbnail);
%EXPORT_TAGS = (
	all => \@EXPORT_OK,
);



my $DEBUG = 0;
sub DEBUG : lvalue { $DEBUG }


sub create_thumbnail {
	my ($abs_pdf,$abs_out,$page_number,$arg,$all);
	$abs_pdf = shift; 

	print STDERR "============== create_thumbnail() ==\n" if DEBUG;
	$abs_pdf or croak(__PACKAGE__."::create_thumbnail() missing abs pdf argument");
	
	for (@_){
		my $val = $_;
		print " val [$val]\n" if DEBUG;

		if (ref $val eq 'HASH'){
			$arg = $val;
			print STDERR " got args hash ref\n" if DEBUG;
		}

		elsif ($val=~/^\d+$/){
			$page_number = $val;
			print STDERR " got page number $val\n" if DEBUG;
		}
		
		elsif ($val eq 'all_pages'){
			$all=1;
			print STDERR " got flag to do all pages\n" if DEBUG;
		}

		elsif ($val=~/[^\/]+\.\w{2,4}$/){
			$abs_out = $val;
			print STDERR " got abs out [$val]\n" if DEBUG;
		}
		else {
			croak(__PACKAGE__."::create_thumbnail() bogus argument [$val]");
		}	
	}

	$arg ||={};
	$arg->{restriction} ||= 125;
	unless( defined $arg->{frame} ){ $arg->{frame} = 6; }
	unless( defined $arg->{normalize}){ $arg->{normalize} = 1; }

	if ($arg->{frame}){
		$arg->{restriction} = ($arg->{restriction} - ($arg->{frame}  * 2) );
	}
	
	$all ||= 0;
	$page_number ||= 0;	

	$abs_out ||= $abs_pdf;
	if( $abs_out eq $abs_pdf ){
		if (!$all){
			$abs_out=~s/\.\w{3}$/\-$page_number\.png/
				or carp(__PACKAGE__."Is this a pdf? Cannot match file extension (3 \\w) ")
				and return;
		}
		else {
			$abs_out=~s/\.\w{3}$/\.png/
				or carp(__PACKAGE__."Is this a pdf? Cannot match file extension (3 \\w) ")
				and return;
		}
	}

	$arg->{frame}=~/^\d+$/ or croak(__PACKAGE__."::create_thumbnail() argument 'frame' is not a number");

	$arg->{restriction}=~/^\d+$/ or 
		croak(__PACKAGE__."::create_thumbnail() argument 'restriction' is invalid");

		
	if (DEBUG){ 
		printf STDERR __PACKAGE__."::create_thumbnail() debug.. \n";
		printf STDERR " abs_pdf %s\n page_number %s\n abs_out %s, all? %s\n", $abs_pdf, $page_number, $abs_out, $all;
		### $arg
	}


	my $convert_bin = `which convert`;
	chomp $convert_bin;
	$convert_bin!~/no convert in/ or die(__PACKAGE__."::create_thumbnail() missing convert when doing 'which convert', "
		."is imagemagick installed on this system?");

	my @command = ($convert_bin,'-colorspace','rgb');
	
	if (!$all){
		push @command , $abs_pdf."[$page_number]";
	}
	else {	
		push @command , $abs_pdf;
	}	
	
	push @command, '-antialias','-label','%f';


	if ( $arg->{normalize} ){
		my $step = $arg->{restriction} * 2;	
		push @command, '-thumbnail',  $step.'x'.$step, '-normalize';
	}


	push @command, '-thumbnail', $arg->{restriction}.'x'.$arg->{restriction};
	
	if ($arg->{frame}){
		push @command, '-frame', $arg->{frame}.'x'.$arg->{frame};
	}
	
	push @command, '-quality', '90', $abs_out;

	unless( system(@command) == 0 ){
		carp(__PACKAGE__." system [@command] failed: $?");
		return;	
	}
	
	return $abs_out;
# convert  ./rec.pdf[0] -label %f -thumbnail 400x400 -normalize -thumbnail 125x125 -frame 6x6 ./rec.gif

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
second optional argument is a hash ref with following options
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

=head2 Examples

The following example creates /abs/file-0.png 125x125 thumbnail image of first page.

	create_thumbnail('/abs/file.pdf');

This example creates a thumbnail to /abs/path/to/thumbs/haha.gif instead:

	create_thumbnail('/abs/file.pdf','/abs/path/to/thumbs/haha.gif');

To create a thumb for page 5 instead:
	
	create_thumbnail('/abs/file.pdf', '/abs/path/to/thumbs/haha_page_five.gif',5);

	create_thumbnail('/abs/file.pdf',5); # creates '/abs/file-5.png'

To create a thumb for page 6 with restriction 200, a frame of 2 px, and no normalize:

	create_thumbnail('/abs/file.pdf',6,
		{ restriction => 200, frame => 2, normalize => 0 
	}); # creates '/abs/file-6.png' 

	create_thumbnail('/abs/file.pdf','/abs/file_pagesix.png', 6,
		{ restriction => 200, frame => 2, normalize => 0 
	}); # creates '/abs/file_pagesix.png'

	create_thumbnail('/abs/file.pdf','/abs/file_i_lie_page234.png', 6,
		{ restriction => 200, frame => 2, normalize => 0 }
	); # creates '/abs/file_i_lie_page234.png' (thumbnail of page 6)

To create a thumb for page 19 in a different location with dimensions of 100x100

	create_thumbnail('/abs/file.pdf', '/abs/path/to/this19.jpg', 19, { rescrtiction => 100 });

=head2 Making All Thumbnails

This can be slow! This can be useful offline, but I don't suggest it real-time. You try it out.


The following examples makes  '/abs/f-0.gif',  '/abs/f-1.gif',  '/abs/f-2.gif', etc.

	create_thumbnail('/abs/file.pdf', '/abs/f.gif','all_pages');

The following example makes '/abs/file-0.png', '/abs/file-1.png', '/abs/file-2.png' etc

	create_thumbnail('/abs/file.pdf','all_pages');

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

=head1 DEBUGGING

Note that if you enable debugger 

	Image::Magick::Thumbnail::PDF::DEBUG = 1;

You will see that a restriction of 125 changes to 113.. how come? Because we compensate for the frame size.
Asking for a thumbnail no wider or taller then 125 px gives you just that. 

=head1 TODO

There is one thing I want to catch up with. If you make all thumbnails, all pages.. then I would like to return
an array ref with all thumbs created. But.. I don't know what they are! Hmm.
It would entail asking the pdf how many pages it has ahead of time, I'm scared about the consumption of resources
that would entail, if it's worth it.
I could enable that only if they specified all pages to be done.

=head1 PREREQUISITES

ImageMagick with convert installed.
Smart::Comments
Carp

=head1 SEE ALSO

ImageMagick on the web, convert.

=head1 AUTHOR

Leo Charre leocharre at cpan dot org

=cut





