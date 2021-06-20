#!/usr/bin/perl -w
use strict;
use warnings;
use PDF::Builder;

my $pdf = PDF::Builder->new(compress => 'none');
my $page = $pdf->page();

my ($file, $string);
if (scalar @ARGV) { 
    $file = $ARGV[0];
    $string = undef;
} else {
    $file = undef;
    # copy of CSS.svg.  try trimming some stuff off it
    # doesn't seem to matter if <?xml> line is out, but should keep <svg> line
    $string =
"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>
<svg width=\"361.244mm\" height=\"180.3444mm\"
 viewBox=\"0 0 1024 52\"
 xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\"  version=\"1.2\" baseProfile=\"tiny\">
<title>Qt Svg Document</title>
<desc>Generated with Qt</desc>
<style type=\"text/css\">
  text { fill: #ff00ff; }
</style>
<defs>
</defs>
<g fill=\"none\" stroke=\"black\" stroke-width=\"1\" fill-rule=\"evenodd\" stroke-linecap=\"square\" stroke-linejoin=\"bevel\" >

<g fill=\"#ffffff\" fill-opacity=\"1\" stroke=\"none\" transform=\"matrix(1,0,0,1,0,0)\"
font-family=\"MS Shell Dlg 2\" font-size=\"8.25\" font-weight=\"400\" font-style=\"normal\" 
>
<path vector-effect=\"non-scaling-stroke\" fill-rule=\"evenodd\" d=\"M0,0 L1024,0 L1024,52 L0,52 L0,0\"/>
<path vector-effect=\"non-scaling-stroke\" fill-rule=\"evenodd\" d=\"M0,0 L1024,0 L1024,52 L0,52 L0,0\"/>
</g>

<g fill=\"#000000\" fill-opacity=\"1\" stroke=\"#000000\" stroke-opacity=\"1\" stroke-width=\"1\" stroke-linecap=\"square\" stroke-linejoin=\"bevel\" transform=\"matrix(1,0,0,1,0,0)\"
font-family=\"Times New Roman\" font-size=\"16\" font-weight=\"400\" font-style=\"normal\" 
>
<text fill=\"#ff0000\" fill-opacity=\"1\" stroke=\"none\" xml:space=\"preserve\" y=\"8\" x=\"31\" font-family=\"Times New Roman\" font-size=\"16\" font-weight=\"400\" font-style=\"normal\" style=\"fill:#aaaaaa;\" 
 >????? 3 ??? P ?????????????????</text>
<text fill=\"#00ff00\" fill-opacity=\"1\" stroke=\"none\" xml:space=\"preserve\" y=\"68\" x=\"31\" font-family=\"Times New Roman\" font-size=\"16\" font-weight=\"400\" font-style=\"normal\" 
 >????? 3 ??? P ?????????????????</text>
<text fill=\"#0000ff\" fill-opacity=\"1\" stroke=\"none\" xml:space=\"preserve\" y=\"84\" x=\"31\" font-family=\"Times New Roman\" font-size=\"16\" font-weight=\"400\" font-style=\"normal\" 
 >????? 3 ??? P ?????????????????</text>
<text fill=\"#000000\" fill-opacity=\"1\" stroke=\"none\" xml:space=\"preserve\" y=\"129\" x=\"31\" font-family=\"Times New Roman\" font-size=\"16\" font-weight=\"400\" font-style=\"normal\" 
 >????? 3 ??? P ?????????????????</text>
<text fill=\"#000000\" fill-opacity=\"1\" stroke=\"none\" xml:space=\"preserve\" y=\"146\" x=\"31\" font-family=\"Times New Roman\" font-size=\"16\" font-weight=\"400\" font-style=\"normal\" 
 >????? 3 ??? P ?????????????????</text>
</g>
</g>
</svg>
";
}
# now have either $file or $string
my $rc = 0;

if (defined $file) {
    $rc = $page->image_svg(0,0, file=>$file, ppi=>'78');
} else {
    $rc = $page->image_svg(0,0, string=>$string, ppi=>'78');
}

print "SVG decode status: $rc\n";
