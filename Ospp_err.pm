# --- fichier Ospp_err.pm 
package Ospp_err;
use strict;


sub new_Ospp_err{
	my ($class, 
	$PRODUCT_ID, 
	$SKU_ID, 
	$LICENSE_NAME, 
	$LICENSE_DESCRIPTION, 
	$BETA_EXPIRATION, 
	$LICENSE_STATUS,
	$ERROR_CODE,
	$ERROR_DESCRIPTION,
	$PARTIAL_KEY) = @_;
	
	my $this = {};
	bless($this, $class);
	$this->{PRODUCT_ID} = $PRODUCT_ID;
	$this->{SKU_ID} = $SKU_ID;
	$this->{LICENSE_NAME} = $LICENSE_NAME;
	$this->{LICENSE_DESCRIPTION} = $LICENSE_DESCRIPTION;
	$this->{BETA_EXPIRATION} = $BETA_EXPIRATION;
	$this->{LICENSE_STATUS} = $LICENSE_STATUS;
	$this->{ERROR_CODE} = $ERROR_CODE;
	$this->{ERROR_DESCRIPTION} = $ERROR_DESCRIPTION;
	$this->{PARTIAL_KEY} = $PARTIAL_KEY;
	return $this;
}
1;
	