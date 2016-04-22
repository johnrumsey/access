package fh;

#require Exporter;
#our @ISA       = qw(Exporter);
#our @EXPORT    = qw( getx putx );
#our @EXPORT_OK = qw( getx putx );

use Fcntl;

{
  my $fyle = 'fht';

  sub getx {
    sysopen( FH, $fyle, O_RDWR ) or die "Failed to open $fyle: $!";
    local $/;	# Slurp mode
    return <FH>;
  }

  sub putx {
    my $content = shift;
    truncate( FH, 0 ) or die "Failed to truncate $fyle: $!\n";
    print FH $content;
    close FH
  }

}
