#!perl
#
#
use 5.001;
use strict;
use warnings;
use warnings::register;

use vars qw($VERSION $DATE);
$VERSION = '0.07';
$DATE = '2003/06/24';

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
   use vars qw( $__restore_dir__ @__restore_inc__ $__tests__);

   ########
   # Create the test plan by supplying the number of tests
   # and the todo tests
   #
   $__tests__ = 6;
   plan(tests => $__tests__);

   ########
   # Working directory is that of the script file
   #
   $__restore_dir__ = cwd();
   my ($vol, $dirs, undef) = File::Spec->splitpath( __FILE__ );
   chdir $vol if $vol;
   chdir $dirs if $dirs;

   #######
   # Add the current test directory to @INC
   #   (first t directory in upward march)
   #
   # Add the library of the unit under test (UUT) to @INC
   #   (lib directory at the same level as the t directory)
   #
   @__restore_inc__ = @INC;

   my $work_dir = cwd(); # remember the work directory so can restore it

   #######
   # Add the test directory root t to @INC
   #
   ($vol,$dirs) = File::Spec->splitpath( $work_dir, 'nofile');
   my @dirs = File::Spec->splitdir( $dirs );
   while( $dirs[-1] ne 't' ) { 
       chdir File::Spec->updir();
       pop @dirs;
   };


   ######
   # Add the unit under test root lib to @INC
   #
   unshift @INC, cwd();  # include the current test directory
   chdir File::Spec->updir();
   my $lib_dir = File::Spec->catdir( cwd(), 'lib' );
   unshift @INC, $lib_dir;

   chdir $work_dir;

}

END {

    #########
    # Restore working directory and @INC back to when enter script
    #
    @INC = @__restore_inc__;
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


#######
# 
# ok: 6
#
# R:
# 
print "# hex_dump\n";
$text_actual = <<'EOF';
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
    
$text_actual =~ s/\n/\012/g; # replace logcial \n with ASCII \012 LF

$text_expected = <<'EOF';
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
EOF

$text_actual  = $snl->hex_dump( $text_actual  );
$snl->fout( 'actual.txt', $text_actual);
ok($text_actual, $text_expected);

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

