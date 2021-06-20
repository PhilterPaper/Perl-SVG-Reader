use strict;
use warnings;
use PDF::Builder;

my $compress = 'none';

my $PDFname = $0;
$PDFname =~ s/\..*$//;  # remove extension
$PDFname .= '.pdf';     # add new extension
 
my $pdf = PDF::Builder->new(-compress => $compress);

my ($font, $text, $grfx, $page, $image);
my $pageNo = 0;
nextPage();
# next (first) page of output, 523pt wide x 720pt high
my $svg_height = 37; # expected height of image_svg

$text->translate(0,610);
$text->font($font, 15);
$text->text("Above SVG image");

$grfx->move(0,600);
$grfx->linewidth(1);
$grfx->strokecolor('red');
$grfx->line(500,600);
$grfx->stroke();

$grfx->move(0,600-$svg_height);
$grfx->line(500,600-$svg_height);
$grfx->stroke();

$text->translate(0,600-$svg_height-25);
$text->text("Below SVG image");

# ===== do SVG stuff below here
$image = $pdf->image_svg('hello');
if ($compress eq 'none') {
    # equivalent to commenting out compressFlate call in Hybrid.pm
    # (or putting it under the compression flag control)
    $image->{'-docompress'} = 0; 
    delete $image->{'Filter'};
}
$grfx->formimage($image, 5,600-$svg_height);  # absolute position Lower Left
# ===== do SVG stuff above here

$pdf->saveas($PDFname);

# ---------------------------------------
sub nextPage {
  $pageNo++;
  $page = $pdf->page();
  $grfx = $page->gfx();
  $text = $page->text();
  $page->mediabox('Universal');
  $font = $pdf->corefont('Times-Roman');
  $text->translate(595/2,15);
  $text->font($font, 10);
  $text->fillcolor('black');
  $text->text_center($pageNo); # prefill page number before any other content
  return;
}

