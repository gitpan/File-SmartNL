#!perl
#
#
use 5.001;
use strict;
use warnings;
use warnings::register;

use vars qw($VERSION $DATE);
$VERSION = '0.08';
$DATE = '2003/07/19';

use Cwd;
use File::Spec;
use File::Package;
use Test;

######
#
# T:
#
# use a BEGIN block so we print our plan before Module Under Test is loaded
#
BEGIN { 
   use vars qw( $__restore_dir__ $__tests__);

   ########
   # Create the test plan by supplying the number of tests
   # and the todo tests
   #
   $__tests__ = 5;
   plan(tests => $__tests__);

   ########
   # Working directory is that of the script file
   #
   $__restore_dir__ = cwd();
   my ($vol, $dirs, undef) = File::Spec->splitpath( __FILE__ );
   chdir $vol if $vol;
   chdir $dirs if $dirs;

}

END {

    #########
    # Restore working directory  to when enter script
    #
    chdir $__restore_dir__;
}

#####
# New $fu object
#
my $fp = 'File::Package';
my $snl = 'File::SmartNL';

#######
#
# ok: 1 
#
# R:
#
my $loaded;
print "# is_package_loaded\n";
ok ($loaded = $fp ->is_package_loaded('File::SmartNL'), ''); 

#######
# 
# ok:  2
#
# R:
# 
print "# load_package\n";
my $errors = $fp ->load_package( 'File::SmartNL' );
skip($loaded, $errors, '');
skip_rest( $errors, 2 );

####
#
# ok: 3
#
# R:
#
print "# fin fout 1\n";
unlink 'test.pm';
my $fout_expected = "=head1 Title Page\n\nSoftware Version Description\n\nfor\n\n";
$snl->fout( 'test.pm', $fout_expected, {binary => 1} );
my $fout_actual = $snl->fin( 'test.pm' );
ok($fout_actual,$fout_expected);
unlink 'test.pm';

####
#
# ok: 4
#
# R:
#
print "# fin fout 2\n";
my $fout_dos = "=head1 Title Page\r\n\r\nSoftware Version Description\r\n\r\nfor\r\n\r\n";
$snl->fout( 'test.pm', $fout_dos, {binary => 1} );
$fout_actual = $snl->fin('test.pm');
ok($fout_actual, $fout_expected);
unlink 'test.pm';

#######
# 
# ok: 5
#
# R:
# 
print "# smart_nl\n";
my $text_actual =   "line1\015\012line2\012\015line3\012line4\015";
my $text_expected = "line1\nline2\nline3\nline4\n";
ok($snl->smart_nl($text_actual), $text_expected);


unlink 'actual.txt';

####
# 
# Support:
#
#

sub skip_rest
{
    my ($results, $test_num) = @_;
    if( $results ) {
        for (my $i=$test_num; $i < $__tests__; $i++) { skip(1,0,0) };
        exit 1;
    }
}

__END__

=head1 NAME

smartNL.t - test script for $fu

=head1 SYNOPSIS

 smartNL.t 

=head1 COPYRIGHT

copyright © 2003 Software Diamonds.

Software Diamonds permits the redistribution
and use in source and binary forms, with or
without modification, provided that the 
following conditions are met: 

=over 4

=item 1

Redistributions of source code, modified or unmodified
must retain the above copyright notice, this list of
conditions and the following disclaimer. 

=item 2

Redistributions in binary form must 
reproduce the above copyright notice,
this list of conditions and the following 
disclaimer in the documentation and/or
other materials provided with the
distribution.

=back

SOFTWARE DIAMONDS, http://www.SoftwareDiamonds.com,
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

=cut

## end of test script file ##

