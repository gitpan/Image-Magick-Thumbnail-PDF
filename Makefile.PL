use ExtUtils::MakeMaker;
WriteMakefile(
	NAME => 'Image::Magick::Thumbnail::PDF',
	VERSION_FROM => 'lib/Image/Magick/Thumbnail/PDF.pm',
	PREREQ_PM => {
		'Smart::Comments' => 0,
		'File::Path' => 0,
		'File::Copy' => 0,		
	},
);
