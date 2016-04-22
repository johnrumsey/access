package evani;

# Utility routines for handling Evan's Internet access.
#
# Assumes caller will trap exceptions raised with "die".

use POSIX;
use Fcntl qw( :flock );
use strict;

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT    = qw(
  );
our @EXPORT_OK = qw(
  );

# Package global variables.

my $now = time();
my $statefile = 'statefile';
my %state;

################################################################################

# loadstate
#   create state file if it doesn't exist.
#   open state file
#   lock state file
#   read state file contents into state hash

sub loadstate {

  # If state file doesn't exist, try to create it.
  # If state file not open, try to open it.
  ( ! -e $statefile &&
    sysopen( SF, $statefile, O_RDWR | O_EXCL | O_CREAT ) ) ||
  sysopen( SF, $statefile, O_RDWR ) ||
  die "Failed to create or open state file $statefile: $!";

  # Lock state file
  flock( SF, LOCK_EX ) or die "Failed to lock state file $statefile";

  # Read state file contents into state hash.
  while ( <SF> ) {
    chomp;
    if ( /^(\d+) ([01])$/ ) { $state{ $1 } = $2 }
  }

}

################################################################################

# storestate
#   truncate state file
#   write state hash contents to state file
#   close state file

sub storestate {
  truncate( SF, 0 ) or die "Failed to truncate state file $statefile";
  foreach ( sort keys %state ) {
    print SF "$_ $state{ $_ }\n" or die "Print to state file $statefile failed"
  }
  close SF;
}

################################################################################

# stripstate
#   Remove all historical entries except the most recent.  If there are no
#   historical entries, and current_state is defined, add a 'now,current_state'
#   entry.
#   Remove all future entries that wouldn't cause a state change.
#   return current state, timestamp of next state change

sub stripstate {
  my $current_state = shift; 
  my $last_state;
  my $last_timestamp;
  my $next_state;
  my $next_timestamp;
  my $end_state;
  my $end_timestamp;

  # Remove all historical entries except the most recent.
  foreach ( sort keys %state ) {
    last if $_ > $now;
    delete $state{ $last_timestamp } if $last_timestamp;
    $last_timestamp = $_;
    $last_state = $state{ $_ };
  }

  # If there are no historical entries, and current_state is defined, add a
  # 'now,current_state' entry.
  if ( ! defined $last_timestamp && defined $current_state ) {
    $last_timestamp = $now;
    $last_state = $current_state;
    $state{ $now } = $current_state;
  }

  # Remove all future entries that wouldn't cause a state change.
  $end_state = $last_state if defined $last_state;
  foreach ( sort keys %state ) {
    next if $_ <= $now;
    if ( defined $end_state && $state{ $_ } == $end_state ) {
      delete $state{ $_ };
      next;
    }
    $end_state = $state{ $_ };
    $end_timestamp = $_;
    if ( ! defined $next_state ) {
      $next_state = $end_state;
      $next_timestamp = $end_timestamp;
    }
  }

  # If end_state is "enabled", add a disable event at the following midnight.
  if ( $end_state ) {
    $end_timestamp = $last_timestamp unless defined $end_timestamp;
    $end_timestamp = 86400 * ( int( $end_timestamp / 86400 ) + 1 );
    $end_state = 0;
    $state{ $end_timestamp } = 0;
    if ( ! defined $next_state ) {
      $next_state = $end_state;
      $next_timestamp = $end_timestamp;
    }
  }

  return ( $last_state, $next_timestamp );
}

################################################################################

sub getstate {
  local $_ = `ssh -n mikrotik ip firewall filter print`;
  return /14 (.) chain/ ? $1 eq 'X' ? 1 : 0 : undef;
}

################################################################################

sub setstate {
  my $state = shift;
  $state = $state ? 'disable' : 'enable';
  $state = `ssh -n mikrotik ip firewall filter $state 14 2>&1`;
}

################################################################################

1;
