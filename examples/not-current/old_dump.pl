#!/usr/bin/perl -w
use strict;
use warnings;

use SVG::Parser;
use Data::Dumper;

my $output = 2;  # 1 = Data::Dumper, 2 = decoded

die "Usage: $0 <file> | $0 -s\n" unless @ARGV;

my $mode = 's';  # f/file, s/string input (see $string)
my $xml;  # input .svg file as string
if ($ARGV[0] ne '-s') {
    local $/=undef;
    $xml=<>;   # slurp in whole file
    $mode = 'f';
}
my @ignore = (
  '-docref', '-parent', '-parentname', '-namespace', '-elsep', '-extension',
  '-xml_svg', '-xml_xlink', '-nocredits', '-sysid', '-version', '-inline',
  'xmlns:xlink', 'xmlns:svg', 'xmlns', '-indent', '-printerror', '-document', 
  '-level', '-elist', '-idlist', '-standalone', '-raiseerror', '-docroot', 
  '-pubid', 'baseProfile', 'version', 'xml:space', 'xlink:href', 'type',
	     );

# copy of CSS.svg to use with -s flag.  try trimming some stuff off it
# doesn't seem to matter if <?xml> line is out, but should keep <svg> line
my $string =    
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

#my $parser=new SVG::Parser(-debug=>1,'--indent'=>'  ');
my $parser=new SVG::Parser();

if ($mode eq 's') {
    $xml = $string;
}
my $svg=$parser->parse($xml);

#print $svg->xmlify();
if ($output == 1) {
    print Dumper($svg);
}

# -encoding => "UTF-8" from encoding field in <?xml> tag
# -childs => [] of {}'s
#    height =>, width =>  from <svg> tag, in pixels (convert with dpi)
#    -childs => [] of {}'s in order of appearance of each tag
#       -name => rect, polyline, etc. tag name
#       x =>, y=>, height=>, width =>, points => list of x,y pairs
#       for -name=path, expect d => path string, sometimes transform=>string
#       for -name=text, expect -cdata => string of text
#       for -name=line, expect x1=> y1=> x2=> y2=>
#       style => {}
#          fill =>, stroke =>, stroke-width => etc in style attribute
#       clip-path => url(#setup) where id=setup in clipPath to use
#       for clipPath, has id =>
#          -childs => [] of {}'s
#             regular tag(s) within to define clipping path
#  ignore -docref, -parent, -parentname, -namespace, -elsep, -extension,
#         -xml_svg, -xml_xlink, -nocredits, -sysid, -version, -inline,
#         xmlns:xlink, xmlns:svg, xmlns, -indent, -printerror, -document, 
#         -level, -elist, -idlist, -standalone, -raiseerror, -docroot, -pubid

if ($output == 2) {
    # there is no -childs at the root level 0, so don't see -name=svg, just
    #   its attributes (width, height, viewBox)
    # top level gets -name=document and its attributes (-encoding)
    processChildren(0, [$svg]);
#    my @keylist = sortkeys(keys %$svg);
#    foreach my $toplevel (@keylist) {
#	if (ignoreIt(\@ignore, $toplevel)) { next; }
#	if ($toplevel eq '-name') { 
#	    print "level 0 child:\n  tag <$toplevel>\n";
#	    next; 
#        }
#
#	if ($toplevel eq '-encoding') { 
#	    print "level 0: Encoding = '$svg->{$toplevel}'\n";
#	    next;
#	}
#	if ($toplevel eq '-childs') { 
#	    processChildren(1, $svg->{$toplevel});
#	    next;
#	}
#
#	print "don't know what to do with toplevel $toplevel = '$svg->{$toplevel}'\n";
#    }
}

# stuff always to ignore. return 1 if to ignore item
sub ignoreIt {
    my ($listRef, $item) = @_;
    my @list = @$listRef;
    my $igIt = 0;
    foreach (@list) {
	if ($item eq $_) { $igIt = 1; last; }
    }
    return $igIt;
}

# recursively process -childs list
sub processChildren {
    my ($level, $ref) = @_;

#   print "Recursively process -childs list at level $level\n";
#   print " -childs has ".(@$ref)." elements\n";

    foreach my $child (@$ref) {
	print ' 'x$level."level $level child: \n";
	my @keylist = sortkeys(keys %$child);
	foreach my $childEl (@keylist) {
	    if (ignoreIt(\@ignore, $childEl)) { next; }
	    if ($childEl eq '-name') {
	        if ($level == 1) { next; }
		print ' 'x($level+1)."tag <$child->{'-name'}>\n";
		next;
	    } 
	    # simple scalar
	    if (
		$childEl eq 'encoding' ||
	        $childEl eq '-encoding' ||
	        $childEl eq 'height' ||
	        $childEl eq 'width' ||
	        $childEl eq 'x' ||
	        $childEl eq 'y' ||
	        $childEl =~ m/^[xy][12]$/ ||
	        $childEl eq 'rx' ||
	        $childEl eq 'ry' ||
		$childEl eq 'clip-path' ||
		$childEl eq 'clip-rule' ||
		$childEl eq 'viewBox' ||
		$childEl eq 'preserveAspectRatio' ||
		$childEl eq 'enable-background' ||
		$childEl eq 'gradientUnits' ||
		$childEl eq 'gradientTransform' ||
		$childEl eq 'offset' ||
		$childEl eq 'fill-rule' ||
		$childEl eq 'fill' ||
		$childEl eq 'fill-opacity' ||
		$childEl eq 'stroke' ||
		$childEl eq 'stroke-width' ||
		$childEl eq 'stroke-opacity' ||
		$childEl eq 'stroke-linejoin' ||
		$childEl eq 'stroke-linecap' ||
		$childEl eq 'stroke-miterlimit' ||
		$childEl eq 'points' ||
		$childEl eq 'd' ||
		$childEl eq 'id' ||
		$childEl eq 'transform' ||
		$childEl eq 'font-family' ||
		$childEl eq 'font-style' ||
		$childEl eq 'font-size' ||
		$childEl eq 'font-weight' ||
		$childEl eq 'vector-effect' 
	       ) {
		print ' 'x($level+2)."element $childEl = '$child->{$childEl}'\n";
		next;
	    } 
	    # sub-hash
	    if ($childEl eq 'style') {
		print ' 'x($level+2)."style:\n";
		foreach (sort keys %{ $child->{'style'} }) {
		    print ' 'x($level+3)."element $_ = '$child->{'style'}->{$_}'\n";
		}
		next;
	    }
	    # string needs newlines dropped
	    if ($childEl eq '-cdata') {
		my $string = $child->{'-cdata'};
		$string =~ s/\n//g;
		print ' 'x($level+2)."element -cdata = '$string'\n";
		next;
	    } 
	    # sub-array
            if ($childEl eq '-childs') {
		processChildren($level+1, $child->{$childEl});
		next;
	    }

	    # otherwise
	    print "Unknown at level $level: $childEl => '$child->{$childEl}'\n";
	}
    }

    return;
}

# sort list of keys into groups, and alphabetically within groups
sub sortkeys {
    my (@rawKeys) = @_;

    my @sortedKeys = ();
    my (@list, $el);

    # desired output order of keys
    # encoding= in <?xml> tag seems to show up as -encoding
    @list = ('-name', '-cdata', 'width', 'height', 'x', 'y', 'x1', 'y1',
	     'x2', 'y2', 'rx', 'ry', 'id', '-encoding', 'encoding', 'points', 
	     'd', 'transform', 'font-family', 'font-style', 'font-size', 
	     'font-weight', 'vector-effect', 'clip-path', 'clip-rule', 
	     'viewBox', 'preserveAspectRatio', 'enable-background', 
	     'gradientUnits', 'gradientTransform', 'offset', 'fill-rule', 
	     'fill', 'fill-opacity', 'stroke', 'stroke-width', 
	     'stroke-opacity', 'stroke-linejoin', 'stroke-linecap', 
	     'stroke-miterlimit', 'style', '-childs');
    foreach (@list) {
        if (!scalar @rawKeys) { return @sortedKeys; }
        $el = findKey($_, @rawKeys);
        if ($el > -1) { push @sortedKeys, splice(@rawKeys, $el, 1); }
    }

    # anything else is to be ignored (should be on @ignore list)
    foreach (@rawKeys) {
	if (!ignoreIt(\@ignore, $_)) {
	    print "====== '$_' not used, but isn't on ignore list!\n";
	}
    }
   #if (scalar @rawKeys) {
   #    print "======== Don't know what to do with: @rawKeys\n";
   #}

    return @sortedKeys;
}

# find needle in list haystack and return index (-1 if not found)
sub findKey {
    my ($needle, @haystack) = @_;

    for (my $i=0; $i<scalar @haystack; $i++) {
	if ($haystack[$i] eq $needle) {
	    return $i;
	}
    }
    return -1;
}
