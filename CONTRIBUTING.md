# Contributing to the development of SVG::Reader

We would appreciate the community around us chipping in with code, tests, 
documentation, and even just bug reports and feature requests. It's better 
knowing what users of SVG::Reader want and need, than for us to guess. It's 
not good to spend a lot of time working on something that no one is interested 
in!

You can contribute to the discussion by posting bug reports, feature requests, 
observations, etc. to the [GitHub issues area](https://github.com/PhilterPaper/Perl-SVG-Reader/issues?q=is%3Aissue+sort%3Aupdated-desc "issues")
(please tag new threads accordingly, using ["Labels"], if possible).

Please also read INFO/RoadMap to get an idea of where we would like for 
SVG::Reader to be heading, and may give you an idea of where you could
usefully contribute. Don't be afraid to discuss or propose taking SVG::Reader
off in a direction not in the RoadMap -- the worst that could happen is that
we say, "thanks, but no thanks."

**Per the notes in README.md, if this turns out to be relatively trivial code,
we may fold it into PDF::Builder and not offer it as a separate package (on
GitHub and CPAN). If you have found it to be useful for your project(s), and
want to use it for other purposes, please let us know that you are doing so 
(and would like for it to be a separate, independent package) _before_ we come
to release 1.000 time!**

For code changes, a GitHub pull request, a formal patch file (e.g., "diff"), or 
even a replacement file or manual patch will do, so long as it's clear where it 
goes and what it does. If the volume of such work becomes excessive (i.e., a 
burden to us), we reserve the right to limit the ways that code changes can be 
submitted. At this point, the volume is low enough that almost anything can be 
handled.

## Do NOT...

Do NOT under ANY circumstances open a PR (Pull Request) to **report a _bug_.**
It is a waste of both _your_ and _our_ time and effort. Open a regular ticket
(issue), and attach a Perl (.pl) program illustrating the problem, if possible. 
If you believe that you have a program patch, and offer to share it as a PR, we 
may give the go-ahead. Unsolicited PRs may be closed without further action.

Please do not start on a massive project (especially, new function), without 
discussing it with us first (via email or one of the discussion areas). This 
will save you the disappointment of seeing your hard work rejected because it 
doesn't fit in with what's going on with the rest of the SVG::Reader project. 
You are free to try contributing anything you want, or even to fork the project 
if you don't like the direction it's taking (that's how PDF::Builder split off 
from PDF::API2). Keeping in touch and coordinating with us ensures that your 
work won't be wasted. If you have something dependent on SVG::Reader 
functionality, but it doesn't fit our roadmap for core functionality, we may 
suggest that you release it as a separate package on CPAN (dependent on 
SVG::Reader), or as a new sub-package under SVG::Reader (e.g., like 
PDF::Builder::Ladder under PDF::Builder), under either our ownership or yours.

Good luck, and best wishes using and helping with SVG::Reader!

December, 2022
