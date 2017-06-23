# --- fichier Produkey.pm 
package Produkey;
use strict;


sub new_Produkey{
	my ($class, 
	$product_name, 
	$product_id, 
	$product_key, 
	$installation_folder, 
	$service_pack, 
	$computer_name,
	$modified_time) = @_;
	
	my $this = {};
	bless($this, $class);
	$this->{PRODUCT_NAME} = $product_name;
	$this->{PRODUCT_ID} = $product_id;
	$this->{PRODUCT_KEY} = $product_key;
	$this->{INSTALLATION_FOLDER} = $installation_folder;
	$this->{SERVICE_PACK} = $service_pack;
	$this->{COMPUTER_NAME} = $computer_name;
	$this->{MODIFIED_TIME} = $modified_time;
	return $this;
}
1;
	