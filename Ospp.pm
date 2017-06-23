# --- fichier Ospp.pm 
package Ospp;
use strict;


sub new_Ospp{
	my ($class, 
	$PRODUCT_ID, 
	$SKU_ID, 
	$LICENSE_NAME, 
	$LICENSE_DESCRIPTION, 
	$BETA_EXPIRATION, 
	$LICENSE_STATUS,
	$PARTIAL_KEY) = @_;
	
	my $this = {};
	bless($this, $class);
	$this->{PRODUCT_ID} = $PRODUCT_ID;
	$this->{SKU_ID} = $SKU_ID;
	$this->{LICENSE_NAME} = $LICENSE_NAME;
	$this->{LICENSE_DESCRIPTION} = $LICENSE_DESCRIPTION;
	$this->{BETA_EXPIRATION} = $BETA_EXPIRATION;
	$this->{LICENSE_STATUS} = $LICENSE_STATUS;
	$this->{PARTIAL_KEY} = $PARTIAL_KEY;
	return $this;
}
1;
	