#!/usr/bin/perl -w
use strict;
use SVG::Parser;
use Data::Dumper;

die "Usage: $0 <file>\n" unless @ARGV;

my $xml;
{
    local $/=undef;
    $xml=<>;
}

#my $parser=new SVG::Parser(-debug=>1,'--indent'=>'  ');
my $parser=new SVG::Parser();

my $svg=$parser->parse($xml);

#print $svg->xmlify();
#print Dumper($svg);
my @base = @{ $svg->{'-childs'}[0]->{'-childs'} };

print scalar(@base)." elements in the document's top level\n";
my $unknown_tag = 0;
my ($width,$height, $x,$y, $x1,$y1, $x2,$y2, $d, $string, $points, $style);
my ($id, $class, $cx,$cy,$r, $fx,$fy, $rx,$ry);
my ($stroke_color, $stroke_width, $fill_color, $transform, $clip_path);

dumpLevel(0, '', @base);

print "Unknown tag(s) encountered!\n" if $unknown_tag > 0;

# ------------------------------------------------------------
sub dumpLevel {
	my ($i, $indent, @base) = @_;

if ($i == 0) {
	myprint($indent, "\n>>>>>> new level");
}
foreach my $ele (@base) {
	my $name = $ele->{'-name'};
	myprint($indent, "\n$i: ");
	$i++;

	if      ($name eq 'rect') {
		$id = commonAttr($ele);
		$width = $ele->{'width'}; $height = $ele->{'height'};
		$x = $ele->{'x'}; $y = $ele->{'y'};  # Upper Left of rectangle
		  $x = 0 if !defined $x; $y = 0 if !defined $y;  # default to 0,0
		$rx = $ele->{'rx'}; $ry = $ele->{'ry'}; # opt. rounded corners
		$transform = $ele->{'transform'};
		($fill_color,$stroke_color,$stroke_width) = commonDraw($ele);

		print "rect x=$x,y=$y width=$width,height=$height";
	        if (defined $rx) {
			print " rx=$rx,ry=$ry";
		}
		print "	$id\n";
		myprint($indent, "        transform='$transform'\n") if defined $transform;
		myprint($indent, "        fill='$fill_color'\n") if defined $fill_color;
		myprint($indent, "        stroke='$stroke_color'\n") if defined $stroke_color;
		myprint($indent, "        stroke-width='$stroke_width'\n") if defined $stroke_width;
		dumpStyle($ele, $indent);

	} elsif ($name eq 'circle') {
		$id = commonAttr($ele);
		$cx = $ele->{'cx'}; $cy = $ele->{'cy'};
		$r = $ele->{'r'}; 
		  $cx = 0 if !defined $cx; $cy = 0 if !defined $cy;
		$transform = $ele->{'transform'};
		($fill_color,$stroke_color,$stroke_width) = commonDraw($ele);

		print "circle cx=$cx,cy=$cy,r=$r $id\n";
		myprint($indent, "        transform='$transform'\n") if defined $transform;
		myprint($indent, "        fill='$fill_color'\n") if defined $fill_color;
		myprint($indent, "        stroke='$stroke_color'\n") if defined $stroke_color;
		myprint($indent, "        stroke-width='$stroke_width'\n") if defined $stroke_width;
		dumpStyle($ele, $indent);

	} elsif ($name eq 'ellipse') {
		$id = commonAttr($ele);
		$cx = $ele->{'cx'}; $cy = $ele->{'cy'};
		$rx = $ele->{'rx'}; $ry = $ele->{'ry'};
		  $cx = 0 if !defined $cx; $cy = 0 if !defined $cy;
		$transform = $ele->{'transform'};
		($fill_color,$stroke_color,$stroke_width) = commonDraw($ele);

		print "ellipse cx=$cx,cy=$cy, rx=$rx,ry=$ry $id\n";
		myprint($indent, "        transform='$transform'\n") if defined $transform;
		myprint($indent, "        fill='$fill_color'\n") if defined $fill_color;
		myprint($indent, "        stroke='$stroke_color'\n") if defined $stroke_color;
		myprint($indent, "        stroke-width='$stroke_width'\n") if defined $stroke_width;
		dumpStyle($ele, $indent);

	} elsif ($name eq 'line') {
		$id = commonAttr($ele);
		$x1 = $ele->{'x1'}; $y1 = $ele->{'y1'};
		$x2 = $ele->{'x2'}; $y2 = $ele->{'y2'};
		$transform = $ele->{'transform'};
		($fill_color,$stroke_color,$stroke_width) = commonDraw($ele);

		print "line x1=$x1,y1=$y1 x2=$x2,y2=$y2 $id\n";
		myprint($indent, "        transform='$transform'\n") if defined $transform;
		myprint($indent, "        fill='$fill_color'\n") if defined $fill_color;
		myprint($indent, "        stroke='$stroke_color'\n") if defined $stroke_color;
		myprint($indent, "        stroke-width='$stroke_width'\n") if defined $stroke_width;
		dumpStyle($ele, $indent);

	} elsif ($name eq 'polyline') {
		$id = commonAttr($ele);
		$points = $ele->{'points'};
		$transform = $ele->{'transform'};
		($fill_color,$stroke_color,$stroke_width) = commonDraw($ele);
		$clip_path = $ele->{'clip-path'};

		print "polyline point list='$points' $id\n";
		myprint($indent, "        transform='$transform'\n") if defined $transform;
		myprint($indent, "        fill='$fill_color'\n") if defined $fill_color;
		myprint($indent, "        stroke='$stroke_color'\n") if defined $stroke_color;
		myprint($indent, "        stroke-width='$stroke_width'\n") if defined $stroke_width;
		myprint($indent, "        clip-path='$clip_path'\n") if defined $clip_path;
		dumpStyle($ele, $indent);

	} elsif ($name eq 'polygon') {
		$id = commonAttr($ele);
		$points = $ele->{'points'};
		$transform = $ele->{'transform'};
		($fill_color,$stroke_color,$stroke_width) = commonDraw($ele);
		$clip_path = $ele->{'clip-path'};

		print "polygon point list='$points' $id\n";
		myprint($indent, "        transform='$transform'\n") if defined $transform;
		myprint($indent, "        fill='$fill_color'\n") if defined $fill_color;
		myprint($indent, "        stroke='$stroke_color'\n") if defined $stroke_color;
		myprint($indent, "        stroke-width='$stroke_width'\n") if defined $stroke_width;
		myprint($indent, "        clip-path='$clip_path'\n") if defined $clip_path;
		dumpStyle($ele, $indent);

	} elsif ($name eq 'path') {
		$id = commonAttr($ele);
		$transform = $ele->{'transform'};
		($fill_color,$stroke_color,$stroke_width) = commonDraw($ele);
		$clip_path = $ele->{'clip-path'};
		$d = $ele->{'d'};

		print "path d='$d' $id\n";
		myprint($indent, "        transform='$transform'\n") if defined $transform;
		myprint($indent, "        fill='$fill_color'\n") if defined $fill_color;
		myprint($indent, "        stroke='$stroke_color'\n") if defined $stroke_color;
		myprint($indent, "        stroke-width='$stroke_width'\n") if defined $stroke_width;
		myprint($indent, "        clip-path='$clip_path'\n") if defined $clip_path;
		dumpStyle($ele, $indent);

	} elsif ($name eq 'text') {
		$id = commonAttr($ele);
		$x = $ele->{'x'}; $y = $ele->{'y'};
		  $x = 0 if !defined $x; $y = 0 if !defined $y;  # default to 0,0
		my $rotate = $ele->{'rotate'};
		$transform = $ele->{'transform'};
		($fill_color,$stroke_color,$stroke_width) = commonDraw($ele);
		$clip_path = $ele->{'clip-path'};

		$string = substr($ele->{'-cdata'}, 1); # remove leading \n
		$string =~ s/<\n/</g; $string =~ s/\n>/>/g;
		$string =~ s/\n</</g; $string =~ s/>\n/>/g;

		print "text x=$x,y=$y string='$string' $id\n";
		myprint($indent, "        transform='$transform'\n") if defined $transform;
		myprint($indent, "        rotate='$rotate'\n") if defined $rotate;
		myprint($indent, "        fill='$fill_color'\n") if defined $fill_color;
		myprint($indent, "        stroke='$stroke_color'\n") if defined $stroke_color;
		myprint($indent, "        stroke-width='$stroke_width'\n") if defined $stroke_width;
		myprint($indent, "        clip-path='$clip_path'\n") if defined $clip_path;
		dumpStyle($ele, $indent);

	} elsif ($name eq 'tspan') {
		# should be child of <text>
		$id = commonAttr($ele);
		$x = $ele->{'x'}; $y = $ele->{'y'};
		  $x = 0 if !defined $x; $y = 0 if !defined $y;  # default to 0,0

		$string = substr($ele->{'-cdata'}, 1); # remove leading \n
		$string =~ s/<\n/</g; $string =~ s/\n>/>/g;
		$string =~ s/\n</</g; $string =~ s/>\n/>/g;

		print "tspan x=$x,y=$y string='$string' $id\n";
		dumpStyle($ele, $indent);

	} elsif ($name eq 'textPath') {
		$id = commonAttr($ele);
		my $href = $ele->{'href'};

		$string = substr($ele->{'-cdata'}, 1); # remove leading \n
		$string =~ s/<\n/</g; $string =~ s/\n>/>/g;
		$string =~ s/\n</</g; $string =~ s/>\n/>/g;

		print "textPath href='$href' string='$string' $id\n";

	} elsif ($name eq 'clipPath') {
		$id = commonAttr($ele);

		print "clipPath $id\n";
		dumpStyle($ele, $indent);
		doChildren($ele, $indent);

	} elsif ($name eq 'g') {
		$id = commonAttr($ele);
		$transform = $ele->{'transform'};
		($fill_color,$stroke_color,$stroke_width) = commonDraw($ele);
		my $fill_rule = $ele->{'fill-rule'} if defined $ele->{'fill-rule'};
		my $stroke_linecap = $ele->{'stroke-linecap'} if defined $ele->{'stroke-linecap'};
		my $stroke_linejoin = $ele->{'stroke-linejoin'} if defined $ele->{'stroke-linejoin'};

		print "g $id\n";
		myprint($indent, "        transform='$transform'\n") if defined $transform;
		myprint($indent, "        fill='$fill_color'\n") if defined $fill_color;
		myprint($indent, "        stroke='$stroke_color'\n") if defined $stroke_color;
		myprint($indent, "        stroke-width='$stroke_width'\n") if defined $stroke_width;
		myprint($indent, "        fill-rule='$fill_rule'\n") if defined $fill_rule;
		myprint($indent, "        stroke-linecap='$stroke_linecap'\n") if defined $stroke_linecap;
		myprint($indent, "        stroke-linejoin='$stroke_linejoin'\n") if defined $stroke_linejoin;
		dumpStyle($ele, $indent);
		doChildren($ele, $indent);

	} elsif ($name eq 'defs') {
		$id = commonAttr($ele);

		print "defs $id\n";
		dumpStyle($ele, $indent);
		doChildren($ele, $indent);

	} elsif ($name eq 'title') {  # ignore this 
		$id = commonAttr($ele);
		$string = $ele->{'-cdata'};
		$string = substr($ele->{'-cdata'}, 1); # remove leading \n

		print "title $id string='$string'\n";

	} elsif ($name eq 'desc') {  # ignore this 
		$id = commonAttr($ele);
		$string = $ele->{'-cdata'};
		$string = substr($ele->{'-cdata'}, 1); # remove leading \n

		print "desc $id string='$string'\n";

	} elsif ($name eq 'linearGradient') {
		# should be child of <defs>
		$id = commonAttr($ele);
		$x1 = $ele->{'x1'};  $y1 = $ele->{'y1'};
		$x2 = $ele->{'x2'};  $y2 = $ele->{'y2'};

		print "linearGradient $id";
		if (defined $x1) {
			print "x1=$x1,y1=$y1 x2=$x2,y2=$y2";
		}
		print "\n";
		dumpStyle($ele, $indent);
		doChildren($ele, $indent);

	} elsif ($name eq 'radialGradient') {
		# should be child of <defs>
		$id = commonAttr($ele);
		$cx = $ele->{'cx'};  $cy = $ele->{'cy'};
		$r = $ele->{'r'};
		$fx = $ele->{'fx'};  $fy = $ele->{'fy'};

		print "radialGradient $id cx=$cx,cy=$cy,r=$r fx=$fx,fy=$fy\n";
		dumpStyle($ele, $indent);
		doChildren($ele, $indent);

	} elsif ($name eq 'stop') {
		# should be child of linear or radial Gradient
		$id = commonAttr($ele);
		my $offset = $ele->{'offset'};

		print "stop $id offset=$offset\n";
		dumpStyle($ele, $indent);

	} elsif ($name eq 'filter') {
		# should be child of <defs>
		$id = commonAttr($ele);
		$x = $ele->{'x'}; $y = $ele->{'y'};

		print "filter $id x=$x,y=$y\n";
		dumpStyle($ele, $indent);

	# these filters and others TBD
	} elsif ($name eq 'feGaussianBlur') {
	} elsif ($name eq 'feOffset') {
	} elsif ($name eq 'feBlend') {

	} else {
		print "UNKNOWN element type '$name' I can't handle!!!\n";
		$unknown_tag = 1;
	}
}

	myprint($indent, "<<<<<< end of level\n");
return;
}

# ------------------------------------------------------------
# common attributes fill, stroke, stroke-width. leave undef if not given
sub commonDraw {
	my ($ele) = @_;

	my $f  = undef; 
	my $s  = undef; 
	my $sw = undef; 

	$f  = $ele->{'fill'} if defined $ele->{'fill'};
	$s  = $ele->{'stroke'} if defined $ele->{'stroke'};
	$sw = $ele->{'stroke-width'} if defined $ele->{'stroke-width'};

	return ($f,$s,$sw);
}

# ------------------------------------------------------------
sub doChildren {
	my ($ele, $indent) = @_;

	my @children = @{ $ele->{'-childs'} } if defined $ele->{'-childs'};
	myprint($indent, "   has ".scalar(@children)." child(ren)\n");
	if (scalar(@children) > 0) {
		dumpLevel(0, $indent.'  ', @children);
	}

	return;
}

# ------------------------------------------------------------
sub commonAttr {
	my ($ele) = @_;

	my $ret = '';
	if (defined $ele->{'id'}) { $ret .= "id='".$ele->{'id'}."' "; }
	if (defined $ele->{'class'}) { $ret .= "class='".$ele->{'class'}."' "; }

	return $ret;
}

# ------------------------------------------------------------
sub dumpStyle {
	my ($ele, $indent) = @_;

	my $style = $ele->{'style'};  # hashref
	if (defined $style) {
		myprint($indent, "        style=\n");
		foreach my $k (keys %{ $style }) {
			myprint($indent, "           $k = ".$style->{$k}."\n");
		}
	}
	return;
}

# ------------------------------------------------------------
sub myprint {
	my ($indent, $string) = @_;

	# if string starts with \n, insert indent after \n
	if (substr($string, 0, 1) eq "\n") {
		print "\n".$indent.substr($string, 1);
	} else {
		print $indent.$string;
	}
	return;
}
