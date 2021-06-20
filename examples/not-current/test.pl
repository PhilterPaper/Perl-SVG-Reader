#!/usr/bin/perl
# test SVG images as much as possible
# outputs test.pdf
# author: Phil M Perry

use warnings;
use strict;

# VERSION
my $LAST_UPDATE = '3.013'; # manually update whenever code is changed

use Math::Trig;
use List::Util qw(min max);

use constant in => 1 / 72;
use constant cm => 2.54 / 72; 
use constant mm => 25.4 / 72;
use constant pt => 1;

use PDF::Builder;

my $PDFname = $0;
   $PDFname =~ s/\..*$//;  # remove extension
   $PDFname .= '.pdf';     # add new extension
my $globalX = 0; 
my $globalY = 0;
my $compress = 'none';
#my $compress = 'flate';

my $pdf = PDF::Builder->new(-compress => $compress);
my ($page, $grfx, $text); # objects for page, graphics, text
my (@base, @styles, @points, $i, $lw, $angle, @npts);
my (@cellLoc, @cellSize, $font, $width, $d1, $d2, $d3, $d4);
my @axisOffset = (5, 5); # clear the edge of the cell

my $fontR = $pdf->corefont('Times-Roman');
my $fontI = $pdf->corefont('Times-Italic');
my $fontC = $pdf->corefont('Courier');

my $pageNo = 0;
nextPage();
# next (first) page of output, 523pt wide x 720pt high

my $dpi = 1366/(13 + 9/16);  # 100.7 dpi
my ($W, $H, $img_obj, $min_height);
my $top = 792 - 20;
# ----------------------------------------------------
# 1. ATS_dirs.svg  640W x 512H (px)
$W = 72*640/$dpi; $H = 72*512/$dpi;
$min_height = 20 + $H;
if ($top-15 < $min_height) { nextPage(); } # allow room for page number
@cellLoc = (5, $top-10-$H);
@cellSize = ($W+2, $H+2); 
$text->translate(5, $top);
$text->text_left('ATS_dirs.svg  640x512');
$top -= 10;
$grfx->save();

makeCell(@cellLoc, @cellSize);
@base=@cellLoc;
$grfx->translate(@base);

#$img_obj = $pdf->image_svg('ATS_dirs.svg');
#$grfx->formimage($img_obj, 1,1, $img_obj->width(),$img_obj->height());

$grfx->restore();
$top -= $min_height;

# ----------------------------------------------------
# 2. ATS_flow.svg  640W x 512H (px)
$W = 72*640/$dpi; $H = 72*256/$dpi;
$min_height = 20 + $H;
if ($top-15 < $min_height) { nextPage(); }
@cellLoc = (5, $top-10-$H);
@cellSize = ($W+2, $H+2); 
$text->translate(5, $top);
$text->text_left('ATS_flow.svg  640x512');
$top -= 10;
$grfx->save();

makeCell(@cellLoc, @cellSize);
@base=@cellLoc;
$grfx->translate(@base);

#$img_obj = $pdf->image_svg('ATS_flow.svg');
#$grfx->formimage($img_obj, 1,1, $img_obj->width(),$img_obj->height());

$grfx->restore();
$top -= $min_height;

# ----------------------------------------------------
# 3. chrome-button.svg  30W x 60H (px)
$W = 72*30/$dpi; $H = 72*60/$dpi;
$min_height = 20 + $H;
if ($top-15 < $min_height) { nextPage(); }
@cellLoc = (5, $top-10-$H);
@cellSize = ($W+2, $H+2); 
$text->translate(5, $top);
$text->text_left('chrome-button.svg  30x60');
$top -= 10;
$grfx->save();

makeCell(@cellLoc, @cellSize);
@base=@cellLoc;
$grfx->translate(@base);

#$img_obj = $pdf->image_svg('chrome-button.svg');
#$grfx->formimage($img_obj, 1,1, $img_obj->width(),$img_obj->height());

$grfx->restore();
$top -= $min_height;

# ----------------------------------------------------
# 4. CSS.svg  361.244W x 180.3444H (mm) scaled 50%
$W = 361.244/mm/2; $H = 180.3444/mm/2;
$min_height = 20 + $H;
if ($top-15 < $min_height) { nextPage(); }
@cellLoc = (5, $top-10-$H);
@cellSize = ($W+2, $H+2); 
$text->translate(5, $top);
$text->text_left('CSS.svg  361mmx180mm scale 50%');
$top -= 10;
$grfx->save();

makeCell(@cellLoc, @cellSize);
@base=@cellLoc;
$grfx->translate(@base);

#$img_obj = $pdf->image_svg('CSS.svg');
#$grfx->formimage($img_obj, 1,1, 0.5*$img_obj->width(),0.5*$img_obj->height());

$grfx->restore();
$top -= $min_height;

# ----------------------------------------------------
# 5. ielogo.svg  68W x 68H (px)
$W = 72*68/$dpi; $H = 72*68/$dpi;
$min_height = 20 + $H;
if ($top-15 < $min_height) { nextPage(); }
@cellLoc = (5, $top-10-$H);
@cellSize = ($W+2, $H+2); 
$text->translate(5, $top);
$text->text_left('ielogo.svg  68x68');
$top -= 10;
$grfx->save();

makeCell(@cellLoc, @cellSize);
@base=@cellLoc;
$grfx->translate(@base);

#$img_obj = $pdf->image_svg('ielogo.svg');
#$grfx->formimage($img_obj, 1,1, $img_obj->width(),$img_obj->height());

$grfx->restore();
$top -= $min_height;

# ----------------------------------------------------
# 6. japanese.svg  361.244W x 18.3444H (mm) scaled 50%
$W = 361.244/mm/2; $H = 18.3444/mm/2;
$min_height = 20 + $H;
if ($top-15 < $min_height) { nextPage(); }
@cellLoc = (5, $top-10-$H);
@cellSize = ($W+2, $H+2); 
$text->translate(5, $top);
$text->text_left('japanese.svg  361mmx18mm scale 50%');
$top -= 10;
$grfx->save();

makeCell(@cellLoc, @cellSize);
@base=@cellLoc;
$grfx->translate(@base);

#$img_obj = $pdf->image_svg('japanese.svg');
#$grfx->formimage($img_obj, 1,1, 0.5*$img_obj->width(),0.5*$img_obj->height());

$grfx->restore();
$top -= $min_height;

# ----------------------------------------------------
$pdf->saveas($PDFname);

# =====================================================================
sub colors {
  my $color = shift;
  $grfx->strokecolor($color);
  $grfx->fillcolor($color);
  $text->strokecolor($color);
  $text->fillcolor($color);
  return;
}

# ---------------------------------------
# if a single coordinate pair, produces a green dot
# if two or more pairs, produces a green dot at each pair, and connects 
#   with a green line
sub greenLine {
  my $pointsRef = shift;
    my @points = @{ $pointsRef };

  my $i;

  $grfx->linewidth(1);
  $grfx->strokecolor('green');
  $grfx->poly(@points);
  $grfx->stroke();

  # draw green dot at each point
  $grfx->linewidth(3);
  $grfx->linecap(1);  # round
  for ($i=0; $i<@points; $i+=2) {
    $grfx->poly($points[$i],$points[$i+1], $points[$i],$points[$i+1]);
  }
  $grfx->stroke();
  return;
}

# ---------------------------------------
sub nextPage {
  $pageNo++;
  $page = $pdf->page();
  $grfx = $page->gfx();
  $text = $page->text();
  $page->mediabox('Universal');
  $top = 792 - 20;

  $text->translate(595/2,15);
  $text->font($fontR, 10);
  $text->fillcolor('black');
  $text->text_center($pageNo); # prefill page number before any other content

  $text->font($fontR, 15); # for cell labels
  return;
}

# ---------------------------------------
sub makeCell {
  my ($cellLocX, $cellLocY, $cellSizeW, $cellSizeH) = @_;

  # outline and clip of cell
  $grfx->strokecolor('#CCC');
  $grfx->linewidth(2);
  $grfx->rect($cellLocX,$cellLocY, $cellSizeW,$cellSizeH);
  $grfx->stroke();

 #$grfx->linewidth(1);
 #$grfx->rect($cellLocX,$cellLocY, $cellSizeW,$cellSizeH);
 #$grfx->clip(1);
 #$text->linewidth(1);
 #$text->rect($cellLocX,$cellLocY, $cellSizeW,$cellSizeH);
 #$text->clip(1);
  return;
}

# ---------------------------------------
# draw a set of axes at current origin
sub drawAxes {

  # draw 75-long axes, at offset 
  $grfx->linejoin(0);  
  $grfx->linewidth(1);
  $grfx->poly($axisOffset[0]+0, $axisOffset[1]+75, 
	      $axisOffset[0]+0, $axisOffset[1]+0, 
	      $axisOffset[0]+75,$axisOffset[1]+0);
  $grfx->stroke();
  # 36x36 box
 #$grfx->rect(0,0, 36,36);  # draw a square
 #$grfx->stroke();

  # X axis arrowhead draw
  $grfx->poly($axisOffset[0]+75-2, $axisOffset[1]+0+2, 
	      $axisOffset[0]+75+0, $axisOffset[1]+0+0, 
	      $axisOffset[0]+75-2, $axisOffset[1]+0-2);
  $grfx->stroke();

  # Y axis arrowhead draw
  $grfx->poly($axisOffset[0]+0-2, $axisOffset[1]+75-2, 
  	      $axisOffset[0]+0+0, $axisOffset[1]+75+0, 
 	      $axisOffset[0]+0+2, $axisOffset[1]+75-2);
  $grfx->stroke();
  return;
}

# ---------------------------------------
# label the X and Y axes, and draw a sample 'n'
sub drawLabels {
  my ($Xlabel, $Ylabel) = @_;

  my $fontI = $pdf->corefont('Times-Italic');
  my $fontR = $pdf->corefont('Times-Roman');

  # outline "n"
  $text->distance($axisOffset[0]+0, $axisOffset[1]+0);
  $text->font($fontR, 72);
  $text->render(1);
  $text->text('n');

  $text->render(0);
  $text->font($fontI, 12);

  # X axis label
  $text->distance(75+2, 0-3);
  $text->text($Xlabel);

  # Y axis label
  $text->distance(-75-2+0-4, 0+3+75+2);
  $text->text($Ylabel);
  return;
}

# ---------------------------------------
# write out a 1 or more line caption             
sub drawCaption {
  my $captionsRef = shift;
    my @captions = @$captionsRef;
  my $just = shift;  # 'LC' = left justified (centered on longest line)

  my ($width, $i, $y);

  $text->font($fontC, 12);
  $text->fillcolor('black');

  # find longest line width
  $width = 0;
  foreach (@captions) {
    $width = max($width, $text->advancewidth($_));
  }

  $y=20;  # to shut up perlcritic
  for ($i=0; $i<@captions; $i++) {
    # $just = LC
    $text->translate($cellLoc[0]+$cellSize[0]/2-$width/2, $cellLoc[1]-$y);
    $text->text($captions[$i]);
    $y+=13;  # to mollify perlcritic
  }
  return;
}

# ---------------------------------------
# m, n  (both within X and Y index ranges) = set to this position
# 0  = next cell (starts new page if necessary)
# N  = >0 number of cells to skip (starts new page if necessary)
sub makeCellLoc {
  my ($X, $Y) = @_;

  my @cellX = (36, 212, 388);        # horizontal (column positions L to R)
  my @cellY = (635, 458, 281, 104);  # vertical (row positions T to B)
  my $add;

  if (defined $Y) {
    # X and Y given, use if valid indices
    if ($X < 0 || $X > $#cellX) { die "X = $X is invalid index."; }
    if ($Y < 0 || $Y > $#cellY) { die "Y = $Y is invalid index."; }
    $globalX = $X;
    $globalY = $Y;
    $add = 0;
  } elsif ($X == 0) {
    # requesting next cell
    $add = 1;
  } else { 
    # $X is number of cells to skip (1+)
    $add = $X + 1;
  }

  while ($add-- > 0) {
    if ($globalX == $#cellX) {
      # already at end of row
      $globalX = 0;
      $globalY++;
    } else {
      $globalX++;
    }

    if ($globalY > $#cellY) {
      # ran off bottom row, so go to new page
      $globalX = $globalY = 0;
      nextPage();
      # next page of output, 523pt wide x 720pt high
    }
  }

  return ($cellX[$globalX], $cellY[$globalY]);
}
