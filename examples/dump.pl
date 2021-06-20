#!/usr/bin/perl -w
use strict;
use warnings;

use SVG::Reader;
use Data::Dumper;
use Carp;

# use Data Dumper to dump file or string SVG

croak "Usage: $0 <file> | $0 -s\n" unless @ARGV;

my ($mode, $xml);
if ($ARGV[0] eq '-s') {
    $mode = 's';

# copy of CSS.svg to use with -s flag.  try trimming some stuff off it
# doesn't seem to matter if <?xml> line is out, but should keep <svg> line
$xml =    
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

} else {
    $mode = 'f';
    $xml = $ARGV[0];
}

my $svg = SVG::Reader->read_raw($xml, $mode);

print Dumper($svg);

# ================================================== END 
