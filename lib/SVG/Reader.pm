package SVG::Reader;

use strict;
use warnings;

our $VERSION = '0.002'; # VERSION
our $LAST_UPDATE = '0.002'; # manually update whenever code is changed

use SVG::Parser;
#use Image::SVG::Path;
#use Image::SVG::Transform;

use Carp;

=head1 NAME

SVG:Reader - Decode an SVG file into elementary operations

=head1 SYNOPSIS

    use SVG::Reader;

    # read an XML-format SVG file, return hash of data
    $SVGcontentRef = SVG::Reader->read($filename, 'f');

    # read a string containing XML-format SVG, return hash of data
    $SVGcontentRef = SVG::Reader->read($XMLstring, 's');

=head2 Returned Data

    To be done.

=head1 AUTHOR

Phil M Perry

=cut

# TBD check if 3 prereq modules are installed

=item $svg = SVG::Reader->read_raw($content, $mode, %options)

=item $svg = SVG::Reader->read_raw($content, $mode)

Reads and returns the raw SVG XML structure, as parsed by SVG::Parser.

=over

=item $content

Either a file path and name (for mode = 'f'), or an XML string containing the
SVG item (mode = 's').

=item $mode

'f' to indicate that C<$content> is a file, or 's' to indicate that it is an
XML string.

=item %options

Optional, no current entries.

=back

=item $svg

The returned hash prepared by SVG::Parse. The structure is XML.

=cut

# ------------------------------------
sub read_raw {
    my ($self, $content, $mode, %options) = @_;

    if ($mode !~ /[fs]/i) {
	croak "Mode not one of (f)ile or (s)tring.";
    }

    my $xml;
    if (lc($mode) eq 'f') {
        local $/ = undef;
        $xml = <>;   # slurp in whole file
    } else {
	$xml = $content; # string
    }

    my $parser = new SVG::Parser();
    my $svg = $parser->parse($xml);

    return $svg;
} # end of read_raw()

=item @output = SVG::Reader->read($content, $mode, %options)

=item @output = SVG::Reader->read($content, $mode)

Reads and returns the processed SVG XML structure, as parsed by SVG::Parser,
plus further processing for general use.

=over

=item $content

Either a file path and name (for mode = 'f'), or an XML string containing the
SVG item (mode = 's').

=item $mode

'f' to indicate that C<$content> is a file, or 's' to indicate that it is an
XML string.

=item %options

Optional, no current entries.

=back

=item @output

The returned array of hashes as prepared by SVG::Reader.

=cut

# ------------------------------------
# read and process SVG file
sub read {
    my ($self, $xml, $mode, %options) = @_;
    # $xml should be a file ($mode = 'f') or string ($mode = 's')
    if ($mode !~ m/[fs]/i) {
	croak "read() called with invalid mode $mode, not f or s.";
	return;
    }

    my $svg = $self->read_raw($xml, $mode);
    if (undef $svg) { return; } # should be a message explaining problem
    my @output;
    push @output, 'INITIALIZE';

    # there is no -childs at the root level 0, so don't see -name=svg, just
    #   its attributes (width, height, viewBox)
    # top level gets -name=document and its attributes (-encoding)
    @output = processChildren(0, [$svg]);

    push @output, 'FINALIZE';
    return @output; # could be undef or empty if problem
} # end of read()

# ------------------------------------
# recursively process -childs list. returns array of entries
sub processChildren {
    my ($level, $ref) = @_;

#   print "Recursively process -childs list at level $level\n";
#   print " -childs has ".(@$ref)." elements\n";
    my @output;  # return undef if error or empty

    foreach my $child (@$ref) {
#   print ' 'x$level."level $level child: \n";
        my @keylist = sortKeys(keys %$child);
        foreach my $childEl (@keylist) {

            if ($childEl eq '-name') {
	        if ($level == 1) { next; }
#   print ' 'x($level+1)."tag <$child->{'-name'}>\n";
    push @output, (' 'x($level+1)."tag <$child->{'-name'}>\n");
		    next;
	        } 

	    # simple scalar
	    if (
	        $childEl =~ m/^-?encoding$/ ||
	        $childEl eq 'height' ||
	        $childEl eq 'width' ||
	        $childEl =~ m/^[xy]$/ ||
	        $childEl =~ m/^[xy][12]$/ ||
	        $childEl =~ m/^c[xy]$/ ||
	        $childEl =~ m/^r[xy]$/ ||
	        $childEl eq 'r' ||
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
		$childEl eq 'vector-effect' ||
		$childEl eq 'class' ||
		
		$childEl eq '-docroot' ||
		$childEl eq '-level' ||
		$childEl eq '-pubid' ||
		$childEl eq '-sysid' ||
		$childEl eq '-parentname' ||
		$childEl eq 'xml:space' ||
		$childEl eq '-xml_xlink' ||
		$childEl eq '-xml_svg' ||
		$childEl eq '-raiseerror' ||
		$childEl eq '-printerror' ||
		$childEl eq 'type' ||
		$childEl =~ m/^-?version$/ ||
		$childEl eq '-namespace' ||
		$childEl eq '-extension' ||
		$childEl eq '-nocredits' ||
		$childEl eq '-inline' ||
		$childEl eq '-standalone' ||
		$childEl eq '-indent' ||
		$childEl eq 'xmlns' ||
		$childEl eq 'xmlns:xlink' ||
		$childEl eq 'xmlns:svg' ||
		$childEl eq 'baseProfile' ||
		$childEl eq 'xlink:href' ||
    
		0
	       ) {
#   print ' 'x($level+2)."element $childEl = '$child->{$childEl}'\n";
    push @output, (' 'x($level+2)."element $childEl = '$child->{$childEl}'\n");
		next;
	    } 

	    # sub-hash
	    if ($childEl eq 'style') {
#   print ' 'x($level+2)."style:\n";
    push @output, (' 'x($level+2)."style:\n");
		foreach (sort keys %{ $child->{'style'} }) {
#   print ' 'x($level+3)."element $_ = '$child->{'style'}->{$_}'\n";
    push @output, (' 'x($level+3)."element $_ = '$child->{'style'}->{$_}'\n");
		}
		next;
	    }

	    # string needs newlines dropped
	    if ($childEl eq '-cdata' ||
	        $childEl eq '-elsep') {
		my $string = $child->{'-cdata'}||'';
		$string =~ s/\n//g;
#   print ' 'x($level+2)."element $childEl = '$string'\n";
    push @output, (' 'x($level+2)."element $childEl = '$string'\n");
		next;
	    } 

	    # sub-array
            if ($childEl eq '-childs') {
		push @output, processChildren($level+1, $child->{$childEl});
		next;
	    }

	    # sub-array of -comment strings
	    if ($childEl eq '-comment') {
		my @str_array = @{ $child->{'-comment'} };
		foreach (@str_array) {
#   print ' 'x($level+2)."element -comment = '".($_||'')."'\n";
    push @output, (' 'x($level+2)."element -comment = '".($_||'')."'\n");
		}
		next;
	    }

	    # otherwise
	    print STDERR "Ignored at level $level: $childEl => '$child->{$childEl}'\n";
	}
    }

    return @output;
} # end of processChildren()

# ------------------------------------
# sort list of keys into groups, and alphabetically within groups
sub sortKeys {
    my (@rawKeys) = @_;

    my @sortedKeys = ();
    my (@list, $el);

    # desired output order of keys
    # encoding= in <?xml> tag seems to show up as -encoding
    @list = ('-name', '-cdata', 'width', 'height', 'x', 'y', 'x1', 'y1',
	     'x2', 'y2', 'cx', 'cy', 'rx', 'ry', 'r', 'id', '-encoding', 
	     'encoding', 'points', 'class',
	     'd', 'transform', 'font-family', 'font-style', 'font-size', 
	     'font-weight', 'vector-effect', 'clip-path', 'clip-rule', 
	     'viewBox', 'preserveAspectRatio', 'enable-background', 
	     'gradientUnits', 'gradientTransform', 'offset', 'fill-rule', 
	     'fill', 'fill-opacity', 'stroke', 'stroke-width', 
	     'stroke-opacity', 'stroke-linejoin', 'stroke-linecap', 
	     'stroke-miterlimit', 
	     # following might be of interest
             'xml:space', '-parentname', '-level', '-pubid', '-sysid',
	     '-parentname', 'xml:space', '-xml_xlink', '-xml_svg',
	     '-raiseerror', '-printerror', 'type', 'version', '-namespace',
	     '-extension', '-nocredits', '-inline', '-standalone', '-elsep',
	     '-version', '-docroot', '-indent', 'xmlns', 'xmlns:xlink',
	     'xmlns:svg', 'baseProfile', '-comment', 'xlink:href',
	     # nested items should always come last
	     'style', '-childs',
     );
    foreach (@list) {
        if (!scalar @rawKeys) { return @sortedKeys; }
        $el = findKey($_, @rawKeys);
        if ($el > -1) { push @sortedKeys, splice(@rawKeys, $el, 1); }
    }

    # anything else is to be ignored (should be on @ignore list)
    # listed just before the tag they were found in
    foreach (@rawKeys) {
	if (!ignoreIt(\@ignore, $_)) {
	    print STDERR "====== '$_' found, but isn't on ignore list and don't know how to process it!\n";
	}
    }
   #if (scalar @rawKeys) {
   #    print "======== Don't know what to do with: @rawKeys\n";
   #}

    return @sortedKeys;
} # end of sortKeys();

# ------------------------------------
# find needle in list haystack and return index (-1 if not found)
sub findKey {
    my ($needle, @haystack) = @_;

    for (my $i=0; $i<scalar @haystack; $i++) {
	if ($haystack[$i] eq $needle) {
	    return $i;
	}
    }
    return -1;
} # end of findKey()

1;
