package PDF::Builder::Resource::XObject::Image::SVG;

#use base 'PDF::Builder::Resource::XObject::Image';

use strict;
use warnings;

our $VERSION = '3.021'; # VERSION
my $LAST_UPDATE = '3.022'; # manually update whenever code is changed

##use Image::SVG::Parse;
#use POSIX qw(ceil floor);

=head1 NAME

PDF::Builder::Resource::XObject::Image::SVG - support routines for SVG image 
library (using pure Perl code plus SVG::Parser). 

=head1 METHODS

=over

=item $res = PDF::Builder::Resource::XObject::Image::SVG->new($pdf, $file, $name, %opts)

=item $res = PDF::Builder::Resource::XObject::Image::SVG->new($pdf, $file, $name)

=item $res = PDF::Builder::Resource::XObject::Image::SVG->new($pdf, $file)

=back 

Writes PDF graphics and text objects to render an SVG image on this page of 
the PDF. Note that unlike other image formats, the SVG library here does
B<not> produce a common bitmap (pixel-based) image to be rendered by the 
graphics C<image()> routine, but instead writes directly to the page (graphics
and text objects). Avoiding rendering the image instructions as pixels enables
the PDF image to be true vector graphics, and thus scale-independent.

It is required that the SVG::Parser module be installed and available. It is
assumed that the C<image_svg()> routine has already checked that SVG::Parser
is present. SVG.pm will fail with unpredictable results if SVG::Parser is not
installed!

=head2 Supported SVG content

The full Scalable Vector Graphics capability is a huge undertaking, 
approximately on the scale of PDF itself, so for obvious reasons only a subset 
of the full SVG can be supported here.

At least the basic SVG graphics and text will be supported, enough for SVG to
be useful. Some things such as animation and audio have no call for in PDFs
(at least as far as PDF::Builder supports), and so can be omitted. We will try
to at least give a warning message if your PDF requests something that cannot
be supported, but cannot guarantee this.

=cut

# globals

# diags: 0 = suppress all, 1 = errors, 2 = warnings too, 3 = info too
my $diags = 1;
if (defined $opts{'-diags'}) { $diags = $opts{'-diags'}; }
$diags = 3; # TEMP

# elements (attributes) that we're ignoring for now
my @ignore = (
  '-docref', '-parent', '-parentname', '-namespace', '-elsep', '-extension',
  '-xml_svg', '-xml_xlink', '-nocredits', '-sysid', '-version', '-inline',
  'xmlns:xlink', 'xmlns:svg', 'xmlns', '-indent', '-printerror', '-document', 
  '-level', '-elist', '-idlist', '-standalone', '-raiseerror', '-docroot', 
  '-pubid', 'baseProfile', 'version', 'xml:space', 'xlink:href', 'type',
	     );

my $tag;  # the current tag we're processing
my $encoding;  # document's encoding
my ($g_width, $g_height);  # global (<svg>) w,h converted to points
my @viewBox;  # global (<svg>) viewBox array from string
my $ppi; # pixels-per-inch either as input opts or from width/height/vB
my $first_level_2 = 1;

# array of one or more CSS hashes from <style>. [0] down to [n], matching
#   current nesting level (empty at new level) so know when to pop an element,
#   each 'tag'=>, '.class'=>, '#id'=> (multiple entries)
my @CSS = ();  # initially empty
# hash of id links for rapid reference
my %ids = ();  # initially empty
# list of (new) attributes at each nesting level. [0] down to [n], 
#   [0] contains defaults
my @attr;
# current attributes at any level, compare to specified attribute value to
#   see if need to issue attribute update (e.g., fill color) rather than
#   blindly setting update
my %curAttr;
# what attributes are used by which tags (elements), set in listAttrs()
my %attrList;

sub new {
    my ($class, $pdf, $page, $grfx, $text, $string, %opts) = @_;

   #my $self;    not used

   #$class = ref($class) if ref($class);    not used

    my $rc = 0;  # 0 = OK, 1 = error(s)

    # initialize attr[0]
    initAttr();
    # initialize attribute list (attributes needed per tag/element)
    listAttrs();

## TBD consider XML::Parser, per Image-SVG-Path usage
    my $parser = new SVG::Parser();
    my $svg = $parser->parse($string);
    # now we have hash $svg with all the content

    # no explicit -childs at root level (0), so no -name='svg', but should
    # be able to grab its attributes width, height, viewBox
## Image::SVG::Parse->new()
    $rc = processChildren(0, [$svg]);

    return $rc;
}

use SVG::Parser;

# stuff always to ignore
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

    # first level 2? clean up some globals, make sure have $ppi value
    # TBD more robust handling of viewBox < 4 elements, g_width present
    # but g_height missing or vice-versa, etc.
    if ($level == 2 && $first_level_2) {
	if (defined $opts{'ppi'}) {
	    $ppi = $opts{'ppi'};
	    if ($ppi <= 0) {
		print STDERR "Warning: ppi => $ppi is unreasonable, ignored!\n" if $diags > 1;
		$ppi = undef;
	    }
	}
.....	# now $ppi may be set
	        if (defined $g_width ) { $g_width  = toPoints($g_width);  }
	        if (defined $g_height) { $g_height = toPoints($g_height); }
	if (defined $ppi && defined @viewBox) {
	    # if ppi explicitly given in opts and viewBox given, override 
	    #   (or set) g_width and g_height
	    $g_width  = ($viewBox[2]-$viewBox[0])/$ppi*72;
	    $g_height = ($viewBox[3]-$viewBox[1])/$ppi*72;
	} elsif (
        # g_width and g_height to points, unless explicitly 'pt'
	if (defined $g_width ) { $g_width  = toPoints($g_width);  }
	if (defined $g_height) { $g_height = toPoints($g_height); }
	# if ppi not given in opts, calculate from g_width, g_height, viewBox
	# if still no ppi, default to 72 (equal to points)
	
        $first_level_2 = 0;
	# also time to output the global clipping box
    }

    my $rc = 0; # 0 clean scan, 1 if problem

    foreach my $child (@$ref) {
print ' 'x$level."level $level child: \n";
	my @keylist = sortkeys(keys %$child);
	foreach my $childEl (@keylist) {
	    if (ignoreIt(\@ignore, $childEl)) { next; }
	    if ($childEl eq '-name') {
		$tag = $child->{'-name'};
	        # ignore some tags
	        if ($tag eq 'title' || $tag eq 'desc' ||
		    $tag eq 'style' || $tag eq 'defs') {
		    next;
	        }
print ' 'x($level+1)."tag <$tag>\n";
		next;
	    } 
	    # simple scalar values (and strings)
	    if ($tag eq 'document' && $childEl =~ m/^(-?encoding)$/) {
		$encoding = $child->{$1};
print ' 'x($level+2)."$childEl = '$encoding'\n";
		next;
	    }
	    if ($tag eq 'svg' && $childEl eq 'width') {
		$g_width = $child->{'width'};
print ' 'x($level+2)."raw $childEl = '$g_width'\n";
		next;
	    }
	    if ($tag eq 'svg' && $childEl eq 'height') {
		$g_height = $child->{'height'};
print ' 'x($level+2)."raw $childEl = '$g_height'\n";
		next;
	    }
	    if ($tag eq 'svg' && $childEl eq 'viewBox') {
		my $vB = $child->{'viewBox'};
print ' 'x($level+2)."$childEl = '$vB'\n";
                # convert to array
		@viewBox = split / /, $vB;
		next;
	    }
	     
	    # silently ignoring these tags and their elements
	    if ($tag eq 'title' && $childEl eq '-cdata' ||
	        $tag eq 'desc'  && $childEl eq '-cdata') {
		next;
	    }
	    # for now ignoring these tags and their elements
	    if ($tag eq 'style' && $childEl eq '-cdata' ||
	        $tag eq 'defs') {
		print STDERR "Info: Skipping <$tag> for now.\n" if $diags > 2;
		$rc = 1;
		next;
	    }
	    # at first level==2 ? should be done with levels 0 and 1
	    # at some point need to convert width, height to points,
	    # using viewBox and possible override by ppi, else use to set ppi
	    # also set global clipping port

	    if (
	        $childEl eq 'x' ||
	        $childEl eq 'y' ||
	        $childEl =~ m/^[xy][12]$/ ||
	        $childEl eq 'rx' ||
	        $childEl eq 'ry' ||
		$childEl eq 'clip-path' ||
		$childEl eq 'clip-rule' ||
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
		$rc |= processChildren($level+1, $child->{$childEl});
		next;
	    }

	    # otherwise
	    print STDERR "Warning: Unknown attribute at level $level: $childEl => '$child->{$childEl}'\n" if $diags > 1;
	}
    }

    return $rc;
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
	    print STDERR "Error: ====== '$_' not used, but isn't on ignore list!\n" if $diags > 0;
	}
    }
   #if (scalar @rawKeys) {
   #    print STDERR "Error: ======== Don't know what to do with: @rawKeys\n" if $diags > 0;
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

# convert value with units to points
# mm, cm, m, in, ft, yd, px, pt recognized
sub toPoints {
    my ($inString) = @_;

    my $valPts = 0;
    my $units;

    if ($inString =~ s/[^a-z]{1,}$//i) {
	# explicit units found
	$units = lc($1);
    } else {
	# no explicit units, assume pixels
	$units = 'px';
    }

    # TBD what are valid units? ft, yd, m?
    if      ($units eq 'px') {
	if (defined $ppi) {
	    $valPts = $inString * 72/$ppi;
	} else {
	    $valPts = $inString;  # default to px = pt
	}
    } elsif ($units eq 'pt') {
	$valPts = $inString;
    } elsif ($units eq 'mm') {
	$valPts = $inString * 72/25.4;
    } elsif ($units eq 'cm') {
	$valPts = $inString * 72/2.54;
    } elsif ($units eq 'm') {
	$valPts = $inString * 72*39.37;
    } elsif ($units eq 'in') {
	$valPts = $inString * 72;
    } elsif ($units eq 'ft') {
	$valPts = $inString * 72*12;
    } elsif ($units eq 'yd') {
	$valPts = $inString * 72*36;
    } else {
	print STDERR "Warning: Sorry, measurement unit '$units' not one of " .
	 "px (default),\npt, in, ft, yd, mm, cm, or m.\n" if $diags > 1;
	 # TBD how handle? as px?
    }

    return $valPts;
}

...TBD possibly all '' to force PDF to update to first setting?
# initialize attr for all settings @attr[0] to PDF defaults
# assume nothing inherited from earlier objects -- save/restore state and
#   start afresh with each SVG image
#
# many or most may be set either as elements in a tag, or in style= CSS string
sub initAttr {
    $attr[0] = {};
    # update in sync with setAttribute()

    # think about...
   #$attr[0]{'xml:space'} = 'preserve';
   #$attr[0]{'preserveAspectRatio'} = 'none';
   #$attr[0]{'zoomAndPan'} = 'magnify';
   #$attr[0]{'display'} = 'none';
   #$attr[0]{'visibility'} = 'visible';
   #$attr[0]{'opacity'} = 1;  # overridden by stroke- and fill-opacity?

    $attr[0]{'fill'} = 'none';  # special 'color'
    $attr[0]{'fill-rule'} = 'evenodd'; 
    $attr[0]{'fill-opacity'} = 1; 
    $attr[0]{'stroke'} = 'black';  # can be 'none', #rrggbb, etc.
    $attr[0]{'stroke-width'} = 1;
    $attr[0]{'stroke-linejoin'} = 'miter';
    $attr[0]{'stroke-miterlimit'} = 4;
    $attr[0]{'stroke-linecap'} = 'round';
    $attr[0]{'stroke-opacity'} = 1;
    $attr[0]{'stroke-dasharray'} = 'none';
    $attr[0]{'stroke-dashoffset'} = 0;

   #$attr[0]{'stop-color'} = 'black';  # for gradient
   #$attr[0]{'stop-opacity'} = 1;  # for gradient
   #$attr[0]{'gradientUnits'} = '';  # for gradient
   #$attr[0]{'gradientTransform'} = '';  # for gradient: translate etc.

    $attr[0]{'font-family'} = 1;  # corefont serif? default encoding UTF-8
    $attr[0]{'font-size'} = '8pt';
    $attr[0]{'font-style'} = 'normal';  # italic, etc.
    $attr[0]{'font-weight'} = 'normal';
    $attr[0]{'font-stretch'} = 'normal';

    $attr[0]{'transform'} = '';  # rotate, translate, etc.
    $attr[0]{'vector-effect'} = '';
    $attr[0]{'clip-rule'} = 'none';

    # finally, set (initialize) current attribute hash to these values
    %curAttr = $attr[0];
     
    return;
} # end of initAttr()

# get a named attribute to use, and update PDF if it has changed
#   ($text->attr(val) and $grfx->attr(val))
# we have an attribute name (e.g., "fill") and look for appropriate value to use
# order of attributes:
#   1. style= CSS in tag (element)    $styleAttr hashref from CSSstring()
#   2a.  #id in <style> CSS section(s)
#   2b.  .class in <style> CSS section(s)
#   2c.  tag (element) in <style> CSS section(s)
#   3. attr= in tag (element) and then chain of parents
sub getAttr {
    my ($name, $styleAttr, $tag, $class, $id) = @_;
    my $rc = 0;

    my %CSSlist = ();
    my $CSSval = ''; # matching name's value string

    while (1) {
        # 1. is there a style= attribute in this tag/element?
        #    if contains desired attribute, we're done
        if (defined $styleAttr->{$name}) {
            $CSSval = $styleAttr->{$name};
            last;
        }

        # 2. in CSS chain (<style>) ? check in reverse order (most recent first)
        #    note that we do not have full elaborate selector support: just
        #      simple id's, classes, tag-names
	#    same number of elements in chain as @attr (nesting level)
	#    if any of the following get a match on selector AND find an entry,
        #       we're done (skip over other chains)
	#    
	# first, look for match #id up the CSS style chain
        for (my $CSSel = $#CSS; $CSSel >= 0; $CSSel--) {
	    foreach my $CSShashSel (keys %{ $CSS[$CSSel] }) {
	        if (defined $CSS[$CSSel]{"#".$id}) {
	            # 2a. matching #id to examine?
                    %CSSlist = CSSstring($CSS[$CSSel]{"#".$id});
		    if (defined $CSSlist{$name}) {
		        $CSSval = $CSSlist{$name};
		        last;
		    }
	        } 
	    }
	    if (length($CSSval) > 0) { last; }
	}

	# second, look for match .class up the CSS style chain
        for (my $CSSel = $#CSS; $CSSel >= 0; $CSSel--) {
	    foreach my $CSShashSel (keys %{ $CSS[$CSSel] }) {
	        if (defined $CSS[$CSSel]{".".$class}) {
	            # 2b. matching .class to examine?
                    %CSSlist = CSSstring($CSS[$CSSel]{".".$class});
		    if (defined $CSSlist{$name}) {
		        $CSSval = $CSSlist{$name};
		        last;
		    }
	        }
	    }
	    if (length($CSSval) > 0) { last; }
	}

	# third, look for match tag up the CSS style chain
        for (my $CSSel = $#CSS; $CSSel >= 0; $CSSel--) {
	    foreach my $CSShashSel (keys %{ $CSS[$CSSel] }) {
	        if (defined $CSS[$CSSel]{$tag}) {
	            # 2c. matching tag to examine?
                    %CSSlist = CSSstring($CSS[$CSSel]{$tag});
		    if (defined $CSSlist{$name}) {
		        $CSSval = $CSSlist{$name};
		        last;
		    }
	        }
	    }
	    if (length($CSSval) > 0) { last; }
	}
	
	# 3. go UP chain from this tag to parent(s) to root UNTIL hit a match
	#    in @attr array
        for (my $AttrE = $#attr; $AttrE >= 0; $AttrE--) {
	    foreach my $AttrName (keys %{ $attr[$AttrE] }) {
	        if (defined $attr[$AttrE]->{$AttrName}) {
		    $CSSval = $attr[$AttrE]->{$AttrName};
		    last;
	        }
	    }
	    if (length($CSSval) > 0) { last; }
	}

	last;  # always quit after one trip!
    } # once-through while() loop (easy to exit quickly)

    if (length($CSSval) > 0) {
...just accumulate curAttr hash for now. wait until have all attributes
...and about to output PDF calls before setting fillcolor, etc. because
...some depend on multiple attributes (e.g., call fillcolor() only if 
...not 'none' AND opacity (overridden by fill-opacity) is not 0
        # if different from current attribute, tell PDF about it
	if ($CSSval ne $curAttr{$name}) {
	    $rc = setAttribute($tag, $name, $CSSval);
	}

        # set current attribute
	$curAttr{$name} = $CSSval;

    } else {
        # else nothing found for this attribute $name
	$rc = 1; # hopefully some default behavior or setting can be used
    }

    return $rc;
} # end of getAttr()

# split up a CSS entry (<style> section or style= attribute) into hash of
#   attribute => value pairs
sub CSSstring {
    my ($string) = @_;

    my %hash = ();
    my @array = split /;/, $string;
    # each element should be attr: value pair
    foreach (@array) {
	my @pair = split /:/, $_;
	$pair[0] =~ s/^\s+|\s+$//;  # trim leading and trailing blanks
	$pair[1] =~ s/^\s+|\s+$//;
	if ($pair[1] =~ m/^['"]/) {  # remove any enclosing quotes
	    $pair[1] = substr($pair[1], 1, length($pair[1])-2);
	}
	$hash{$pair[0]} = $pair[1];
    }

    return %hash;
}; # end of CSSstring()

# tell PDF about a changed attribute (have checked that it's different)
sub setAttribute {
    my ($tag, $name, $value) = @_;
    my $rc = 0;  # 1 if any trouble such as invalid value
    my $oldVal = $curAttr{$name};

    # update in sync with initAttr()
    # colors: name (except 'none'), #hexdigits use as-is. 'rgb(d, d, d)' 
    #         translate to #rrggbb
    # opacity: should see 'opacity' first, then 'fill-' or 'stroke-' opacity
    #          TBD how do we do opacity when not 0 or 1?
    
    #==== for filled areas (could be graphics or text, so do both)
    #     note that none (trans.) color, or opacity 0, don't call fillcolor
    # fill   a color (not checking for validity here). incl 'none' for no fill
    #        formats? name, #rrggbb rgb(nn,nn,nn)
    if ($name eq 'fill') {
	if ($value ne 'none') {
	    
	}
    }
    # fill-opacity   value in range 0 to 1 (fully transparent to fully opaque)
    # fill-rule   evenodd, nonzero
    
    #==== for stroked lines (could be graphics or text outlines)
    #     note that none (trans.) color, or opacity 0, don't call strokecolor
    # stroke  a color (not checking for validity here). incl 'none' for no draw
    # stroke-opacity   value in range 0 to 1
    # stroke-width   number >= 0 line width in pt (may have units)
    # stroke-linejoin   miter, bevel, round
    # stroke-miterlimit   number >= 0  no units
    # stroke-linecap   round, butt, square
    # stroke-dasharray    none or a vector
    # stroke-dashoffset   number no units, n%

    #==== for gradients TBD
    # stop-color   a color
    # stop-opacity    value in range 0 to 1
    # gradientUnits    ?
    # gradientTransform    translate, etc.

    #==== for font used
    # TBD how to map family names etc. to specific corefont or ttf fontname,
    #     how to determine whether to use TTF (req if UTF-8 encoding) or core
    # font-family   number or name
    # font-size    length unit
    # font-style    normal, italic, oblique
    # font-weight    normal, bold, bolder, lighter, number 100-900
    # font-stretch    normal, wider, narrower, ultra-condensed, extra-condensed,
    #                 condensed, semi-condensed, semi-expanded, expanded,
    #                 extra-expanded, ultra-expanded

    # transform     rotate(angle) CW around 0,0
    #               rotate(angle x,y) CW around x,y
    #               translate(x,y) move origin to x,y (y defaults to 0)
    #               scale(m) scale x and y by m (can be <0 to mirror)
    #               scale(m,n) scale x by m, y by n
    #               skewX(angle)  Y axis CCW by angle
    #               skewY(angle)  X axis CW by angle
    #               matrix(a,b,c,d,e,f)
    # vector-effect    none, non-scaling-stroke, non-scaling-size, non-rotation,
    #                  fixed-position TBD
    # clip-rule    evenodd, nonzero   clipPath only?
    # display      ?
    # visibility   visible, hidden, collapse
    # opacity     value 0 to 1, applies to both fill and stroke
    #               overridden by fill-opacity and stroke-opacity

    return $rc;
}


# what attributes are used by this element (tag)?
sub listAttrs {
    $attrList{'circle'} = [ 'cx', 'cy', 'r', 'fill', 'stroke', 'fill-opacity',
                            'stroke-opacity', 'stroke-dasharray', 
			    'stroke-dashoffset', 'transform', 'opacity' ];
    $attrList{'ellipse'} = [ 'cx', 'cy', 'rx', 'ry', 'fill', 'stroke', 
	                     'fill-opacity', 'stroke-opacity', 
			     'stroke-dasharray', 'stroke-dashoffset', 
			     'transform', 'opacity' ];
    $attrList{'line'} = [ 'x1', 'y1', 'x2', 'y2', 'stroke', 'stroke-opacity',
	                  'stroke-dasharray', 'stroke-dashoffset', 'transform',
			  'opacity' ];
    $attrList{'polygon'} = [ 'points', 'fill-rule', 'fill', 'stroke', 
	                     'fill-opacity', 'stroke-opacity', 
			     'stroke-dasharray', 'stroke-dashoffset', 
			     'transform', 'opacity' ];
    # check if polyline gets filled! TBD
    $attrList{'polyline'} = [ 'points', 'stroke', 'stroke-opacity',
	                      'stroke-dasharray', 'stroke-dashoffset', 
			      'transform', 'opacity' ];
    $attrList{'rect'} = [ 'x', 'y', 'rx', 'ry', 'width', 'height', 'stroke', 
	                  'stroke-opacity', 'stroke-dasharray', 
			  'stroke-dashoffset', 'transform', 'opacity' ];
    $attrList{'svg'} = [ 'x', 'y', 'width', 'height', 'viewBox', 
	                 'preserveAspectRatio', 'zoomAndPan', 'xml' ];

    $attrList{'clipPath'} =
    $attrList{'defs'} = [ ];
    $attrList{'g'} = [ 'id', 'fill', 'opacity' ];
    $attrList{'defs'} = [ ];
    $attrList{'image'} = [ 'x', 'y', 'width', 'height', 'xlink:href' ];
    $attrList{'path'} = [ 'd', 'pathLength', 'transform' ];
    # remember style=
    # text.x, y, dx, dy, rotate may be lists (one per character)
    $attrList{'text'} = [ 'x', 'y', 'dx', 'dy', 'rotate', 'textLength',
	                  'lengthAdjust', 'fill', 'fill-opacity', 'opacity' ];
} # end of listAttrs()

# list of tags (elements) not currently supported. input is tag not found, 
# output is 0 (it's known but ignored), 1 (don't know what it is)
sub missingTags {
    my ($tag) = @_;

    if (
	$tag eq 'a' ||
	$tag eq 'altGlyph' ||
	$tag eq 'altGlyphDef' ||
	$tag eq 'altGlyphItem' ||
	$tag eq 'animate' ||
	$tag eq 'animateMotion' ||
	$tag eq 'animateTransform' ||
	$tag eq 'color-profile' ||
	$tag eq 'cursor' ||
	$tag eq 'desc' ||
	$tag eq 'feBlend' ||
	$tag eq 'linearGradient' ||
	$tag eq 'marker' ||
	$tag eq 'mask' ||
	$tag eq 'pattern' ||
	$tag eq 'radialGradient' ||
	$tag eq 'stop' ||
	$tag eq 'title' ||
	$tag eq 'tref' ||
	$tag eq 'use' ||
	0) {
        # know about this but have chosen not to implement
	print STDERR "Info: tag (element) <$tag> is not supported.\n" if $diags > 2;
	return 0;
    } else {
	# unknown tag, possibly in error
	print STDERR "Error tag (element) <$tag> is unknown.\n" if $diags > 0;
	return 1;
    }
}; # end of missingTags

# list of attributes not currently supported. input is attribute not 
# found, output is 0 (it's known but ignored), 1 (don't know what it is)
sub missingAttrs {
    my ($attr) = @_;

    if (
	$attr eq 'xlink:show' ||
	$attr eq 'xlink:actuate' ||
	$attr eq 'target' ||
	$attr eq 'glyphRef' ||
	$attr eq 'format' ||
	$attr eq 'attributeName' ||
	$attr eq 'by' ||
	$attr eq 'from' ||
	$attr eq 'to' ||
	$attr eq 'dur' ||
	$attr eq 'repeatCount' ||
	$attr eq 'calcMode' ||
	$attr eq 'path' ||
	$attr eq 'keyPoints' ||
	$attr eq 'type' ||
	$attr eq 'local' ||
	$attr eq 'name' ||
	$attr eq 'rendering-intent' ||
	$attr eq 'mode' ||
	$attr eq 'in' ||
	$attr eq 'in2' ||
	$attr eq 'gradientUnits' ||
	$attr eq 'gradientTransform' ||
	$attr eq 'spreadMethod' ||
	$attr eq 'markerUnits' ||
	$attr eq 'refx' ||
	$attr eq 'refy' ||
	$attr eq 'orient' ||
	$attr eq 'markerWidth' ||
	$attr eq 'markerHeight' ||
	$attr eq 'maskUnits' ||
	$attr eq 'maskContentUnits' ||
	$attr eq 'patternUnits' ||
	$attr eq 'patternContentUnits' ||
	$attr eq 'patternTransform' ||
	$attr eq 'fx' ||
	$attr eq 'fy' ||
	$attr eq 'offset' ||
	$attr eq 'stop-color' ||
	$attr eq 'stop-opacity' ||
	0) {
        # know about this but have chosen not to implement
	print STDERR "Info: attribute $attr is not supported.\n" if $diags > 2;
	return 1;
    } else {
	# unknown tag, possibly in error
	print STDERR "Error: attribute $attr is unknown.\n" if $diags > 0;
	return 2;
    }
    return 0;

1;
