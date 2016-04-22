#!/usr/bin/perl

use POSIX;
use Fcntl qw( :flock SEEK_END );

my $statefile = 'lpl';

################################################################################

sub msg {
  my $fh = shift;
  my $str = strftime( "$$: %Y-%m-%d %H:%M:%S ", localtime() );
  foreach ( @_ ) { $str .= $_ }
  print $fh $str;
}

################################################################################

# Create and lock a new, empty, state file if there isn't one already.

msg( STDERR, "Started\n" );

unless ( -e $statefile ) {  # No statefile: try to create new, empty one.
  msg( STDERR, "No state file: trying to create one ...\n" );
  sysopen( SF, $statefile, O_RDWR | O_EXCL | O_CREAT ) 
    or die "$$:   ... failed: $!";
  msg( STDERR,  "   ... succeeded!\n" );
  close SF;
}

msg( STDERR, "Trying to open state file ...\n" );
sysopen( SF, $statefile, O_RDWR )
    or die "$$: Failed to open $statefile: $!\n";
msg( STDERR, "Locking statefile ...\n" );
msg( STDERR, flock( SF, LOCK_EX ) ? "   Lock succeeded\n" : "   Lock failed\n");
seek( SF, 0, SEEK_END );	# Seek to end of file: makes writes into appends
msg( STDERR, "first write.\n" );
msg( SF, "first write.\n" );
sleep 10;
msg( STDERR, "last write\n" );
msg( SF, "last write\n" );
close SF;
msg( STDERR, "Completed\n" );
exit; 

