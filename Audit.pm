# --- fichier Audit.pm 
package Audit;
use strict;

sub new_Audit{
	my ($class, $BIOS_OEM, $BIOS_KEY, 
	$OS_NAME, $OS_ID, $OS_KEY, 
	$OFFICE_NAME, $OFFICE_ID, $OFFICE_KEY,
	$OFFICE16_NAME, $OFFICE16_ID, $OFFICE16_KEY,
	$OTHER_OFFICE_NAME, $OTHER_OFFICE_ID, $OTHER_OFFICE_KEY, 
	$COMPUTER_NAME, $SERIAL, $MODEL) = @_;
	
	my $this={};
	bless($this, $class);
	
	$this->{BIOS_OEM}=$BIOS_OEM;
	$this->{BIOS_KEY}=$BIOS_KEY;
	$this->{OS_NAME}=$OS_NAME;
	$this->{OS_ID}=$OS_ID;
	$this->{OS_KEY}=$OS_KEY;
	$this->{OFFICE_NAME}=$OFFICE_NAME;
	$this->{OFFICE_ID}=$OFFICE_ID;
	$this->{OFFICE_KEY}=$OFFICE_KEY;
	$this->{OFFICE_NAME}=$OFFICE16_NAME;
	$this->{OFFICE_ID}=$OFFICE16_ID;
	$this->{OFFICE_KEY}=$OFFICE16_KEY;
	$this->{OTHER_OFFICE_NAME}=$OTHER_OFFICE_NAME;
	$this->{OTHER_OFFICE_ID}=$OTHER_OFFICE_ID;
	$this->{OTHER_OFFICE_KEY}=$OTHER_OFFICE_KEY;
	$this->{COMPUTER_NAME}=$COMPUTER_NAME;
	$this->{MODEL}=$MODEL;
	$this->{SERIAL}=$SERIAL;
	return $this;
}
1;