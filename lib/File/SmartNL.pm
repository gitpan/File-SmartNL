#!perl
#
# Documentation, copyright and license is at the end of this file.
#

#####
#
# File::SmartNL package
#
package  File::SmartNL;

use 5.001;
use strict;
use warnings;
use warnings::register;

use vars qw($VERSION $DATE $FILE);
$VERSION = '1.1';
$DATE = '2003/06/24';
$FILE = __FILE__;

use SelfLoader;

__DATA__

######
# Perl 5.6 introduced a built-in smart nl functionality as an IO discipline :crlf.
# See I<Programming Perl> by Larry Wall, Tom Christiansen and Jon Orwant,
# page 754, Chapter 29: Functions, open function.
# For Perl 5.6 or above, the :crlf IO discipline may be preferable over the
# smart_nl method of this package.
#
sub smart_nl
{
   my (undef, $data) = @_;
   $data =~ s/\015\012|\012\015/\012/g;  # replace LFCR or CRLF with a LF
   $data =~ s/\012|\015/\n/g;   # replace CR or LF with logical \n 
   $data;
}

####
# slurp in a text file in a platform independent manner
#
sub fin
{
   my (undef, $file, $options_p) = @_;


   ######
   # If have a file name, open the file, otherwise
   # the file is opened and the file name is a 
   # file handle.
   #
   my $fh;
   if( ref($file) eq 'GLOB' ) {
       $fh = $file;
   }
   else {
       unless(open $fh, "<$file") {
           warn("# Cannot open <$file\n");
           return undef;
       }
   } 

   #####
   # slurp in the file contents with no operating system
   # translations
   #
   binmode $fh; # make the test friendly for more platforms
   my $data = join '', <$fh>;

   #####
   # Close the file
   #
   unless(close($fh)) {
       warn( "# Cannot close $file\n");
       return undef;
   }
   return $data unless( $data );

   #########
   # No matter what platform generated the data, convert
   # all platform dependent new lines to the new line for
   # the current platform.
   #
   $data = File::SmartNL->smart_nl($data) unless $options_p->{binary};
   $data          

}



###
# slurp a file out, current platform text format
#
sub fout
{
   my (undef, $file, $data, $options_p) = @_;

   if($options_p->{append}) {
       unless(open OUT, ">>$file") {
           warn("# Cannot open >$file\n");
           return undef;
       }
   }
   else {
       unless(open OUT, ">$file") {
           warn("# Cannot open >$file\n");
           return undef;
       }
   }
   binmode OUT if $options_p->{binary};
   my $char_out = print OUT $data;
   unless(close(OUT)) {
       warn( "# Cannot close $file\n");
       return undef;
   }
   $char_out; 
}


#####
#
#
sub hex_dump
{
    my (undef, $text) = @_;
    $text = unpack('H*', $text);
    my $result = ''; 
    while( $text ) { 
        if( 40 < length( $text) ) {
            $result .= substr( $text, 0, 40 ) . "\n";
            $text = substr( $text,40);
        }
        else {
            $result .= substr( $text, 0) . "\n";
            $text = '';
        }
    }
    $result
}


1


__END__


=head1 NAME

File::SmartNL - slurp text files no matter the NL sequence

=head1 SYNOPSIS

  use File::SmartNL

  $data          = File::SmartNL->smart_nl($data)
  $data          = File::SmartNL->fin( $file_name, {@options} )
  $success       = File::SmartNL->fout($file_name, $data, {@options})
  $hex_string    = File::SmartNL->hex_dump( $string );

=head1 DESCRIPTION

=head2 The NL Story

Different operating systems have different sequences for new-lines.
Historically when computers where first being born, 
one of the mainstays was the teletype. 
The teletype understood L<ASCII|http:://ascii.computerdiamonds.com>.
The teletype was an automated typewriter that would perform a 
carriage return when it received an ASCII Carriage Return (CR), \015,  character
and a new line when it received a Line Feed (LF), \012 character.

After some time came Unix. Unix had a tty driver that had a raw mode that
sent data unprocessed to a teletype and a cooked mode that performed all
kinds of translations and manipulations. Unix stored data internally using
a single NL character at the ends of lines. The tty driver in the cooked
mode would translate the NL character to a CR,LF sequence. 
When driving a teletype, the physicall action of performing a carriage
return took some time. By always putting the CR before the LF, the
teletype would actually still be performing a carriage return when it
received the LF and started a line feed.

After some time came DOS. Since the tty driver is actually one of the largest
peices of code for UNIX and DOS needed to run in very cramp space,
the DOS designers decided, that instead of writing a tailored down tty driver,
they would stored a CR,LF in the internal memory. Data internally would be
either 'text' data or 'binary' data.

Needless to say, after many years and many operating systems about every
conceivable method of storing new lines may be found amoung the various
operating systems.
This greatly complicates moving files from one operating system to
another operating system.

The smart NL methods in this package are designed to take any combination
of CR and NL and translate it into the special NL seqeunce used on the
site operating system. Thus, by using these methods, the messy problem of 
moving files between operating systems is mostly hidden in these methods.
The one thing not hidden is that the methods need to know if the data is
'text' data or 'binary' data. Normally, the assume the data is 'text' and
are overriden by setting the 'binary' option.

The methods in the C<File::SmartNL> package are designed to support the
L<C<Test::STDmaker>|Test::STDmaker> and 
the L<C<ExtUtils::SVDmaker>|ExtUtils::SVDmaker> packages.
These packages generate test scripts and CPAN distribution files
that must be portable between operating systems.
Since C<File::SmartNL> is a separate package, the methods
may be used elsewhere.

Note that Perl 5.6 introduced a built-in smart nl functionality as an IO discipline :crlf.
See I<Programming Perl> by Larry Wall, Tom Christiansen and Jon Orwant,
page 754, Chapter 29: Functions, open function.
For Perl 5.6 or above, the :crlf IO discipline may be preferable over the
smart_nl method of this package.
However, when moving code from one operating system to another system,
there will be target operating systems for the near and probable far future
that have not upgraded to Perl 5.6.

=head2 System Overview

The "File::SmartNL" module is used to support the expansion of 
the "Test" module by the "Test::Tech" module as follows::

  File::Load
     File::SmartNL
         Test::Tech

The "Test::Tech" module is the foundation of the 2167A bundle that
includes the L<C<Test::STDmaker>|Test::STDmaker> and 
L<C<ExtUtils::SVDmaker>|ExtUtils::SVDmaker> modules.
The focus of the "File::SmartNL" is the support of these other
modules.
In all likehood, any revisions will maintain backwards compatibility
with previous revisions.
However, support and the performance of the 
L<C<Test::STDmaker>|Test::STDmaker> and 
L<C<ExtUtils::SVDmaker>|ExtUtils::SVDmaker> packages has
priority over backwards compatibility.

=head1 METHODs

=head2 fin fout method

  $data = File::SmartNL->fin( $file_name, {@options} )
  $success = File::SmartNL->fout($file_name, $data, {@options})

Different operating systems have different new line sequences. Microsoft uses
\015\012 for text file, \012 for binary files, Macs \015 and Unix 012.  
Perl adapts to the operating system and uses \n as a logical new line.
The \015 is the L<ASCII|http://ascii.computerdiamonds.com> Carraige Return (CR)
character and the \012 is the L<ASCII|http://ascii.computerdiamonds.com> Line
Feed character.

The I<fin> method will translate any CR LF combination into the logical Perl
\n character. Normally I<fout> will use the Perl \n character. 
In other words I<fout> uses the CR LF combination appropriate of the operating
system and file type.
However supplying the option I<{binary => 1}> directs I<fout> to use binary mode and output the
CR LF raw without any translation.

By using the I<fin> and I<fout> methods, text files may be freely exchanged between
operating systems without any other processing. For example,

 ==> my $text = "=head1 Title Page\n\nSoftware Version Description\n\nfor\n\n";
 ==> File::SmartNL->fout( 'test.pm', $text, {binary => 1} );
 ==> File::SmartNL->fin( 'test.pm' );

 =head1 Title Page\n\nSoftware Version Description\n\nfor\n\n

 ==> my $text = "=head1 Title Page\r\n\r\nSoftware Version Description\r\n\r\nfor\r\n\r\n";
 ==> File::SmartNL->fout( 'test.pm', $text, {binary => 1} );
 ==> File::SmartNL->fin( 'test.pm' );

=head2 hex_dump method

Sometimes the designer's eyes need to see what the computer sees,
I<i.e.> the actual bytes of a file content. 
The hex_dump method provides these eyes.
For example,

 ==> $text
 1..8 todo 2 5;
 # OS            : MSWin32
 # Perl          : 5.6.1
 # Local Time    : Thu Jun 19 23:49:54 2003
 # GMT Time      : Fri Jun 20 03:49:54 2003 GMT
 # Number Storage: string
 # Test::Tech    : 1.06
 # Test          : 1.15
 # Data::Dumper  : 2.102
 # =cut 
 # Pass test
 ok 1
 EOF

 ==> File::SmartNL->hex_dump( $text )

 312e2e3820746f646f203220353b0a23204f5320
 20202020202020202020203a204d5357696e3332
 0a23205065726c202020202020202020203a2035
 2e362e310a23204c6f63616c2054696d65202020
 203a20546875204a756e2031392032333a34393a
 353420323030330a2320474d542054696d652020
 202020203a20467269204a756e2032302030333a
 34393a3534203230303320474d540a23204e756d
 6265722053746f726167653a20737472696e670a
 2320546573743a3a54656368202020203a20312e
 30360a232054657374202020202020202020203a
 20312e31350a2320446174613a3a44756d706572
 20203a20322e3130320a23203d637574200a2320
 5061737320746573740a6f6b20310a

=head2 smart_nl method

  $data = File::SmartNL->smart_nl( $data  )

Different operating systems have different new line sequences. Microsoft uses
\015\012 for text file, \012 for binary files, Macs \015 and Unix \012.  
Perl adapts to the operating system and uses \n as a logical new line.
The \015 is the L<ASCII|http://ascii.computerdiamonds.com> Carraige Return (CR)
character and the \012 is the L<ASCII|http://ascii.computerdiamonds.com> Line
Feed (LF) character.

The I<fin> method will translate any CR LF combination into the logical Perl
\n character. Normally I<fout> will use the Perl \n character. 
In other words I<fout> uses the CR LF combination appropriate for the operating
system and file type or device.
However supplying the option I<{binary => 1}> directs I<fout> to use binary mode and outputs 
CRs and LFs raw without any translation.

Perl 5.6 introduced a built-in smart nl functionality as an IO discipline :crlf.
See I<Programming Perl> by Larry Wall, Tom Christiansen and Jon Orwant,
page 754, Chapter 29: Functions, open function.
For Perl 5.6 or above, the :crlf IO discipline my be preferable over the
smart_nl method of this package.

An example of the smart_nl method follows:

 ==> $text

 "line1\015\012line2\012\015line3\012line4\015"

 ==> File::SmartNL->smart_nl( $text )

 "line1\nline2\nline3\nline4\n"

=head1 REQUIREMENTS

The requirements are coming.
 
=head1 NOTES

=head2 AUTHOR

The holder of the copyright and maintainer is

E<lt>support@SoftwareDiamonds.comE<gt>

=head2 COPYRIGHT NOTICE

Copyrighted (c) 2002 Software Diamonds

All Rights Reserved

=head2 BINDING REQUIREMENTS NOTICE

Binding requirements are indexed with the
pharse 'shall[dd]' where dd is an unique number
for each header section.
This conforms to standard federal
government practices, 490A (L<STD490A/3.2.3.6>).
In accordance with the License, Software Diamonds
is not liable for any requirement, binding or otherwise.

=head2 LICENSE

Software Diamonds permits the redistribution
and use in source and binary forms, with or
without modification, provided that the 
following conditions are met: 

=over 4

=item 1

Redistributions of source code must retain
the above copyright notice, this list of
conditions and the following disclaimer. 

=item 2

Redistributions in binary form must 
reproduce the above copyright notice,
this list of conditions and the following 
disclaimer in the documentation and/or
other materials provided with the
distribution.

=back

SOFTWARE DIAMONDS, http::www.softwarediamonds.com,
PROVIDES THIS SOFTWARE 
'AS IS' AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
SHALL SOFTWARE DIAMONDS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL,EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE,DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING USE OF THIS SOFTWARE, EVEN IF
ADVISED OF NEGLIGENCE OR OTHERWISE) ARISING IN
ANY WAY OUT OF THE POSSIBILITY OF SUCH DAMAGE. 

=back

=for html
<p><br>
<!-- BLK ID="NOTICE" -->
<!-- /BLK -->
<p><br>
<!-- BLK ID="OPT-IN" -->
<!-- /BLK -->
<p><br>
<!-- BLK ID="EMAIL" -->
<!-- /BLK -->
<p><br>
<!-- BLK ID="COPYRIGHT" -->
<!-- /BLK -->
<p><br>
<!-- BLK ID="LOG_CGI" -->
<!-- /BLK -->
<p><br>

=cut

### end of file ###