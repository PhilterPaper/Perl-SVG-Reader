package SVG::Reader;

use strict;
use warnings;

our $VERSION = '0.001'; # VERSION
our $LAST_UPDATE = '0.001'; # manually update whenever code is changed

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
} # end of read()

1;
