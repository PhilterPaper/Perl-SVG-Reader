# SVG::Reader

A Perl library to facilitate the reading of SVG files for the purpose of using their data in other programs

# Going Away!

On or after June 1, 2025, I plan to delete the GitHub repository for 
SVG::Reader. I have found Johan Vroman's _SVGPDF_ package to be quite 
sufficient for PDF::Builder's needs, and there is no need to continue with a 
separate duplicate package (especially as it is incomplete and unmaintained).

If you are actually _using_ SVG::Reader, please plan accordingly to grab a copy 
of it (or fork it) for your own use. I do not plan to keep it available on 
GitHub, nor to place it on CPAN.

I will be using _SVGPPDF_ to support PDF::Builder use of general SVG 
graphics, MathJax equation support, GnuPlot SVG graph output, and possibly 
other uses.

### Using it?

If you are actually _using_ SVG::Reader, please plan accordingly to grab a copy 
of it (or fork it) for your own use. I do not plan to keep it available on 
GitHub, nor to place it on CPAN. If someone wants to carry it forward, I
welcome their efforts and will be happy to turn it over to you. I just want it
out of my hair.

If you have need for something to parse SVG so you can interpret it for other
(than PDF) purposes, or translate it into something else, you should consider
adapting _SVGPDF_ for this purpose, unless you're already deeply committed to
_SVG::Reader_. My intent was to parse SVG, and then (in _PDF::Builder_)
interpret the resulting data structure to put PDF primitives into the PDF
output, which is what _SVGPDF_ does all in one call.

[![Open Issues](https://img.shields.io/github/issues/PhilterPaper/Perl-SVG-Reader)](https://github.com/PhilterPaper/Perl-SVG-Reader/issues)

This archive contains the distribution SVG::Reader.
See **Changes** file for the version.

## Objective

The purpose of this package is to read and parse into graphics primitives an
SVG file or an SVG-format string. A list of primitives to draw will be
returned, along with the data and settings that go with each primitive. The
exact format has not yet been determined. Our intent is to have something to
process SVG content so that PDF::Builder can turn it into PDF primitives and
support SVG as its **scalable** image format (along with GIF, PNG, JPEG, and
other non-scalable bitmapped formats). Note that the SVG-to-PDF conversion will
_not_ be part of this package, but part of PDF::Builder. We will attempt to
support as much of the SVG specification as possible in this package, but will
restrict what is supported in PDF::Builder (there are many things in SVG which
are of no use for static images).

# C A U T I O N !

This is still a very preliminary release of this package. We expect it to
change considerably as it is developed towards an official release 1.000. We
would appreciate constructive feedback as we work on it, but please be careful
about basing any of your programs or products on anything less than release
1.000! Once that release is out, we will try very hard to maintain upwards
compatibility.

The ultimate objective here is to be the first part of an SVG support package
for the PDF::Builder PDF creation library. It may be modified during early
development to facilitate this particular use. If you feel that such changes
are making SVG::Reader unusable for other, more general-purpose usage, please
speak up in the issues with your thoughts. We won't guarantee that the end
result will be something useful for everyone, but with constructive feedback
from _you_, the chances are increased that it's useful for everyone!

## Obtaining the Package

The installable Perl package may be obtained from
"https://metacpan.org/pod/SVG::Reader", or via a CPAN installer package. If
you install this product, only the run-time modules will be installed. Download
the full `.tar.gz` file and unpack it (hint: on Windows,
**7-Zip File Manager** is an excellent tool) to get utilities, test buckets,
example usage, etc.

Alternatively, you can obtain the full source files from
"https://github.com/PhilterPaper/Perl-SVG-Reader", where the ticket list
(bugs, enhancement requests, etc.) is also kept. Unlike the installable CPAN
version, this will have to be manually installed (copy files; there are no XS
compiles at this time).

Note that there are several "optional" libraries (Perl modules) used to extend
and improve SVG::Reader. Read about the list of optional libraries in
SVG::Reader::Docs, and decide whether or not you want to install any of them.
By default, all are installed (as "recommended", so failure to install will
not fail the overall SVG::Reader installation). You may choose which ones to
install by modifying certain installation files with "optional\_update.pl".

## Requirements

### Perl

**Perl 5.26** or higher. It will likely run on somewhat earlier versions, but
the CPAN installer may refuse to install it. The reason this version was
chosen was so that LTS (Long Term Support) versions of Perl going back about
6 years are officially supported (by SVG::Reader), and older versions are not
supported. The intent is to not waste time and effort trying to fix bugs which
are an artifact of old Perl releases. We will _not_ be testing SVG::Reader on
any earlier Perl releases, although the chances are good that it will work on
some range of earlier Perls.

#### Older Perls

If you MUST install on an older (pre 5.26) Perl, you can try the following for
Strawberry Perl (Windows). NO PROMISES! Something similar MAY work for other
OS's and Perl installations:

1. Unpack installation file (`.tar.gz`, via a utility such as 7-Zip) into a directory, and cd to that directory
1. Edit META.json and change 5.026000 to 5.016000 or whatever level desired
1. Edit META.yml and change 5.026000 to 5.016000 or whatever level desired
1. Edit Makefile.PL and change `use 5.026000;` to `use 5.016000;`, change `$PERL_version` from `5.026000` to `5.016000`
1. `cpan .`

Note that some Perl installers MAY have a means to override or suppress the
Perl version check. That may be easier to use. Or, you may have to repack the
edited directory back into a `.tar.gz` installable. YMMV.

If all goes well, SVG::Reader will be installed on your system. Whether or
not it will RUN is another matter. Please do NOT open a bug report (ticket)
unless you're absolutely sure that the problem is not a result of using an old
Perl release, e.g., SVG::Reader is using a feature introduced in Perl 5.008
and you're trying to run Perl 5.002!

### Libraries used

These libraries are available from CPAN.

#### REQUIRED

These libraries should be automatically installed...  (once on CPAN)

* SVG::Parser
* Image::SVG::Path
* Image::SVG::Transform
* Carp (should be core)

#### OPTIONAL

* (currently none)

These libraries are _recommended_ for improved functionality and performance.
The default behavior is to attempt to install all of them during SVG::Reader
installation. If you use optional\_update.pl to _not_ to install any of
them, or they fail to install automatically, you can always manually install 
them later.

Other than an installer for standard CPAN packages (such as 'cpan' on
Strawberry Perl for Windows), no other tools or manually-installed prereqs are
needed (worst case, you can unpack the `.tar.gz` file and copy files into
place yourself!). Currently there are no compiles and links (Perl extensions)
done during the install process, only copying of .pm Perl module files.

## Copyright

This software is Copyright (c) 2021-2022 by Phil M. Perry.

## License

This is free software, licensed under:

`The GNU Lesser General Public License, Version 2.1, February 1999`

You are permitted (at your option) to
redistribute and/or modify this software (those portions under LGPL) at an
LGPL version greater than 2.1. See INFO/LICENSE for more information on the
licenses and warranty statement.

## See Also

* INFO/RoadMap file for the SVG::Reader road map
* CONTRIBUTING file for how to contribute to the project
* INFO/SUPPORT file for information on reporting bugs, etc. via GitHub Issues
* INFO/DEPRECATED file for information on deprecated features
* INFO/Changes\* files for older change logs

## Documentation

To build the full HTML documentation (all the POD), get the full installation
and go to the `docs/` directory. Run `buildDoc.pl --all` to generate the full
tree of documentation. There's a lot of additional information in the
SVG::Reader::Docs module (it's all documentation).

We admit that the documentation is a bit light on "how to" task orientation.
We hope to more fully address this in the future, but for now, get the full
installation and look at the `examples/` and `contrib/` directories for sample
code that may help you figure out how to do things. The installation tests in
the `t/` directory might also be useful to you.
