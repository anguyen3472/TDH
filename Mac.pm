# --- fichier Mac.pm 
package Mac;
use strict;

sub new_Mac{
	my ($class, $HOSTNAME, $CPL) = @_;
	
	my $this={};
	bless($this, $class);
	
	$this->{HOSTNAME}=$HOSTNAME;
	$this->{CPL}=$CPL;
	return $this;
}
1;