#!C:\strawberry\perl\bin\perl.exe
use Cwd;
use Tie::File;

#Constructeurs d'objets
use Produkey;
use Audit;
use Ospp;
use Ospp_err;
use Mac;

use Data::Dumper;

print("Enter working directory (network drive of [Administration Clients])\n");
print("(Example : v:Administration Clients)\n");
my $WD = <STDIN>;
chomp($WD);
print("Enter name of the client :\n");
my $CLIENT = <STDIN>;
chomp($CLIENT);

my $WD_PRODUKEY = "$WD\\$CLIENT\\AUDIT_PARC\\PRODUKEY";
my $WD_OSPP = "$WD\\$CLIENT\\AUDIT_PARC\\OSPP";
my $WD_MAC = "$WD\\$CLIENT\\AUDIT_PARC\\INFOMACHINE";
my $OUTPUT_FILE = "$WD\\$CLIENT\\AUDIT_PARC\\AuditLicence.txt";

#Variable globales. Recuperation a n'importe quel endroit du script
#Variable correspondant aux champs de l'objet d'audit finale
my $BIOS_OEM="";
my $BIOS_KEY="";
my $OS_NAME="";
my $OS_ID="";
my $OS_KEY="";
my $OFFICE_NAME="";
my $OFFICE_ID="";
my $OFFICE_KEY="";
my $OFFICE16_NAME="";
my $OFFICE16_ID="";
my $OFFICE16_KEY="";
my $OTHER_OFFICE_NAME="";
my $OTHER_OFFICE_ID="";
my $OTHER_OFFICE_KEY="";
my $COMPUTER_NAME="";
my $HOSTNAME="";
my $SERIAL="";
my $MODEL="";

my $HNAME="";
my $SM="";

my %INFO_PRODUKEY=();
my %INFO_OSPP=();
my %INFO_MAC=();

my @obj_produkey=();
my @obj_ospp=();
my @obj_mac=();

my @produkey_tblobj=();
my @ospp_tblobj=();
my @mac_tblobj=();

my $HASH_PRODUKEY_TBLOBJ={};
my $HASH_OSPP_TBLOBJ={};
my $HASH_MAC_TBLOBJ={};

#Base de données. ID : HOSTNAME
my @AUDIT_PRODUKEY=();
my @AUDIT_OSPP=();
my @AUDIT_MAC=();
my @AUDIT=();


#Divers
my $OFFICE16_PRO ="Office 16, Office16ProfessionalR_Retail edition";
my $OFFICE16_HB ="Office 16, Office16HomeBusinessR_Retail3 edition";



open (my $ofd, ">>", $OUTPUT_FILE) or die "Can't open $OUTPUT_FILE in write mode: $!"; #Ouverture du fichier de sortie en écriture 
print($ofd "COMPUTER_NAME;MODEL;SERIAL;BIOS_OEM;BIOS_KEY;OS_NAME;OS_ID;OS_KEY;OFFICE_NAME;OFFICE_ID;OFFICE_KEY;OFFICE16_NAME;OFFICE16_ID;OFFICE16_KEY;OTHER_OFFICE_NAME;OTHER_OFFICE_ID;OTHER_OFFICE_KEY\n");
#Récupération sous formes d'objets de chaque entrée produkey
opendir(my $PRODUKEY, $WD_PRODUKEY) || die "Can't open dir $WD_PRODUKEY: $!";
while (my $produkey_file = readdir $PRODUKEY){ #Bouclage sur chacun des fichiers du dossier
	next unless $produkey_file =~ /\.txt$/i; #Traitement des fichiers textes uniquement
	my $PRODUKEY_USR = "$WD_PRODUKEY"."\\"."$produkey_file"; #chaînage dynamique du chemin d'accès des fichiers
	open (my $produkey_fd, "<", $PRODUKEY_USR) or die "Can't open $produkey_file in read-only mode: $!"; #Ouverture des fichiers d'audit en lecture
	PRODUKEY: while (my $produkey_line = <$produkey_fd>){
		#Suppression des retours chariots
		$produkey_line =~ s/\r|\n//g;
		
		#Skip des lignes inutiles
		if ($produkey_line =~ m/==================================================/i){
			next PRODUKEY;
		}
		#Recuperation des champs
		else{
			if ($produkey_line =~ m/Product Name/ || $produkey_line =~ m/Product ID/i 
			|| $produkey_line =~ m/Product Key/i || $produkey_line =~ m/Installation Folder/i 
			|| $produkey_line =~ m/Service Pack/i || $produkey_line =~ m/Computer Name/i 
			|| $produkey_line =~ m/Modified Time/i){
			
				if (scalar(@obj_produkey) >= 6){
					%INFO_PRODUKEY=split(/: /,$produkey_line);
					foreach my $k(keys(%INFO_PRODUKEY)){
						push(@obj_produkey, $INFO_PRODUKEY{$k});
					}
					my $product_name = $obj_produkey[0];				
					my $product_id = $obj_produkey[1];
					my $product_key = $obj_produkey[2];
					my $installation_folder = $obj_produkey[3];
					my $service_pack = $obj_produkey[4];
					my $computer_name = $obj_produkey[5];
					my $modified_time = $obj_produkey[6];
					
					if ($computer_name ne ""){
						$HNAME = $computer_name;
						#print("$HNAME\n");
					}
					#Initialisation d'un premier objet. Pour chaque enregistrement, un objet est créé.
					#Enregistrement sous la forme <clef : valeur>. Les noms de champs des objets reprennent la nomenclature des entrées 
					#leur contenu est initialisé avec la valeur de la clef 
					
					my $info_obj = Produkey->new_Produkey(
					$product_name, 
					$product_id, 
					$product_key, 
					$installation_folder,
					$service_pack,
					$computer_name,
					$modified_time);
					
					#Remplissage d'un tableau comprenant toutes les entrées de chaque fichier 
					#(entrées ayant été mises sous formes d'objets juste au dessus)
					push(@produkey_tblobj, $info_obj);					
					
					#Reinitialisation du tableau contenant les couples <clef : valeur> au 6ème couple 
					@obj_produkey=();
					next PRODUKEY;
				}
				
				else{
					%INFO_PRODUKEY=split(/: /,$produkey_line);
					foreach my $k(keys(%INFO_PRODUKEY)){
						push(@obj_produkey, $INFO_PRODUKEY{$k});
					}
				}	
			}
		}
	}
	foreach my $g(@produkey_tblobj){	
		$HASH_PRODUKEY_TBLOBJ={};
		$HASH_PRODUKEY_TBLOBJ->{$HNAME} = $g;
		push (@AUDIT_PRODUKEY, $HASH_PRODUKEY_TBLOBJ)
	}
	@produkey_tblobj=();
}#Fin de la récupération des produkey


$HNAME = "";
#Récupération sous formes d'objets des fichiers de sortie d'exécution du script OSPP.vbs
opendir(my $OSPP, $WD_OSPP) || die "Can't open dir $WD_OSPP: $!";
while (my $ospp_file = readdir $OSPP){
	next unless $ospp_file =~ /\.txt$/i; #Traitement des fichiers textes uniquement
	$HNAME = $ospp_file;
	my $OSPP_USR = "$WD_OSPP"."\\"."$ospp_file"; #chaînage dynamique du chemin d'accès des fichiers
	open (my $ospp_fd, "<", $OSPP_USR) or die "Can't open $ospp_file in read-only mode: $!"; #Ouverture des fichiers d'audit en lecture
	OSPP: while (my $ospp_line = <$ospp_fd>){
		$ospp_line =~ s/\r|\n//g;
		if ($ospp_line =~ m/---Exiting-----------------------------/i){
			tie my @BUILD, 'Tie::File', $OSPP_USR or die $!;
			$#BUILD -= 2;
		}
		if ($ospp_line =~ m/---Processing--------------------------/i){
			tie my @BUILD, 'Tie::File', $OSPP_USR or die $!;
			splice @BUILD, 0, 4;
		}
		if ($ospp_line =~ m/---------------------------------------/i){
			if (scalar(@obj_ospp) == 0){
				next OSPP;
			}
			elsif (scalar(@obj_ospp) == 7){
				my $o_product_id = $obj_ospp[0];				
				my $o_sku_id = $obj_ospp[1];
				my $o_license_name = $obj_ospp[2];
				my $o_license_desc = $obj_ospp[3];
				my $beta_expiration = $obj_ospp[4];
				my $o_license_status = $obj_ospp[5];
				my $partial_key = $obj_ospp[6];		
			
				#Appel du constructeur		
				my $ospp_infobj=Ospp->new_Ospp(	
				$o_product_id,
				$o_sku_id,
				$o_license_name,
				$o_license_desc,
				$beta_expiration,
				$o_license_status,
				$partial_key);
			
				push(@ospp_tblobj, $ospp_infobj);					
			}
			
			elsif (scalar(@obj_ospp) == 9){
				my $o_product_id = $obj_ospp[0];				
				my $o_sku_id = $obj_ospp[1];
				my $o_license_name = $obj_ospp[2];
				my $o_license_desc = $obj_ospp[3];
				my $beta_expiration = $obj_ospp[4];
				my $o_license_status = $obj_ospp[5];
				my $o_err_code = $obj_ospp[6];
				my $o_err_desc = $obj_ospp[7];
				my $partial_key = $obj_ospp[8];		
				
				#Appel du constructeur		
				my $ospp_infobj=Ospp_err->new_Ospp_err(	
				$o_product_id,
				$o_sku_id,
				$o_license_name,
				$o_license_desc,
				$beta_expiration,
				$o_license_status,
				$o_err_code,
				$o_err_desc,
				$partial_key);	
				
				push(@ospp_tblobj, $ospp_infobj);
			}
			@obj_ospp=();
			next OSPP;
		}
		%INFO_OSPP=split(/: /,$ospp_line);
		foreach my $j(keys(%INFO_OSPP)){
			push(@obj_ospp, $INFO_OSPP{$j});
		}
	}
	foreach my $h(@ospp_tblobj){	
		$HASH_OSPP_TBLOBJ={};
		$HASH_OSPP_TBLOBJ->{$HNAME} = $h;
		push (@AUDIT_OSPP, $HASH_OSPP_TBLOBJ)
	}
	@ospp_tblobj=();	
}#Fin de la récupération des ospp


$HNAME ="";
#Récupération sous formes d'objets des fichiers de sortie d'exécution de la commande wmic
opendir(my $MAC, $WD_MAC) || die "Can't open dir $WD_MAC: $!";
while (my $mac_file = readdir $MAC){ #Bouclage sur chacun des fichiers du dossier
	next unless $mac_file =~ /\.txt$/i; #Traitement des fichiers textes uniquement
	my $MAC_USR = "$WD_MAC"."\\"."$mac_file"; #chaînage dynamique du chemin d'accès des fichiers
	open (my $mac_fd, "<", $MAC_USR) or die "Can't open $mac_file in read-only mode: $!"; #Ouverture des fichiers d'audit en lecture
	MAC: while (my $mac_line = <$mac_fd>){
		$mac_line =~ s/\r|\n//g;
		if ($mac_line =~ m/Node,IdentifyingNumber,Name/i || $mac_line =~ m/^\s*$/i){
			next MAC;
		}
				
		else{

			@obj_mac=split(/,/, $mac_line);
			
			my $HN = $obj_mac[0]; #Clef
			my $CN = $obj_mac[1]; #Valeur1
			my $MDL = $obj_mac[2]; #Valeur2
			
			$SM="$CN,$MDL";
			$HNAME = $HN;
						
			my $mac_infobj=Mac->new_Mac(
			$HN,
			$SM);
			push (@mac_tblobj, $mac_infobj);
		}
		@obj_mac=();
	}
	
	foreach my $i(@mac_tblobj){	
		$HASH_MAC_TBLOBJ={};
		$HASH_MAC_TBLOBJ->{$HNAME} = $i;
		push (@AUDIT_MAC, $HASH_MAC_TBLOBJ)
	}
	@mac_tblobj=();		
}#Fin recuperation output de la cmd wmic

# Tableaux constituant la base de données 
# @AUDIT_PRODUKEY
# @AUDIT_OSPP
# @AUDIT_MAC

foreach my $m_ref(@AUDIT_MAC){
	#Déclaration d'un objet vide
	my $audit_obj=Audit->new_Audit(
		$BIOS_OEM,
		$BIOS_KEY,
		$OS_NAME, 
		$OS_ID,
		$OS_KEY,
		$OFFICE_NAME,
		$OFFICE_ID,
		$OFFICE_KEY,
		$OFFICE16_NAME,
		$OFFICE16_ID,
		$OFFICE16_KEY,		
		$OTHER_OFFICE_NAME,
		$OTHER_OFFICE_NAME,
		$OTHER_OFFICE_KEY,
		$MODEL,
		$SERIAL,
		$COMPUTER_NAME
		
);
	
	MAC: foreach my $m_role( keys %$m_ref ){
		my $HASH_MAC= $m_ref->{$m_role};	
		 foreach my $p_ref(@AUDIT_PRODUKEY){
			PRODUKEY : foreach my $p_role( keys %$p_ref){
				 foreach my $o_ref (@AUDIT_OSPP){
					OSPP: foreach my $o_role (keys %$o_ref){
						if ($p_role =~ m/$m_role/i){
							my $HASH_PRODUKEY = $p_ref->{$p_role};
							my @DATA_MAC=split(/,/,$HASH_MAC->{CPL});
							
							my $CPT_SERIAL = $DATA_MAC[0];
							my $CPT_MODEL = $DATA_MAC[1];
							my $CPT_HN = $p_role;
							
							
							$audit_obj->{SERIAL} = $CPT_SERIAL;
							$audit_obj->{MODEL} = $CPT_MODEL;
							$audit_obj->{COMPUTER_NAME} = $CPT_HN;
							
							if ($HASH_PRODUKEY->{PRODUCT_NAME} =~ m/(BIOS OEM Key)/i ){
								$audit_obj->{BIOS_OEM}=$HASH_PRODUKEY->{PRODUCT_NAME};
								$audit_obj->{BIOS_KEY}=$HASH_PRODUKEY->{PRODUCT_KEY};
							}
							elsif ($HASH_PRODUKEY->{PRODUCT_NAME} =~ m/Windows \d+ /i || $HASH_PRODUKEY->{PRODUCT_NAME} =~ m/Windows Server \d+ /i){
								$audit_obj->{OS_NAME}=$HASH_PRODUKEY->{PRODUCT_NAME};
								$audit_obj->{OS_ID}=$HASH_PRODUKEY->{PRODUCT_ID};
								$audit_obj->{OS_KEY}=$HASH_PRODUKEY->{PRODUCT_KEY};
							}
							elsif ($HASH_PRODUKEY->{PRODUCT_NAME} =~ m/Microsoft Office/i ){
								$audit_obj->{OFFICE_NAME}=$HASH_PRODUKEY->{PRODUCT_NAME};
								$audit_obj->{OFFICE_ID}=$HASH_PRODUKEY->{PRODUCT_ID};
								$audit_obj->{OFFICE_KEY}=$HASH_PRODUKEY->{PRODUCT_KEY};
							}						
						}
						if ($o_role =~ m/$m_role/i){
							if ($audit_obj->{OFFICE_NAME} eq "" && $audit_obj->{OFFICE_ID} eq "" && $audit_obj->{OFFICE_KEY} eq ""){
								my $HASH_OSPP =  $o_ref->{$o_role};
								next if $HASH_OSPP->{LICENSE_STATUS} =~ m/ ---NOTIFICATIONS--- /i ;
								if($HASH_OSPP->{LICENSE_NAME} =~ m/$OFFICE16_PRO/i || $HASH_OSPP->{LICENSE_NAME} =~ m/$OFFICE16_HB/i){
									$audit_obj->{OFFICE16_NAME}=$HASH_OSPP->{LICENSE_NAME};
									$audit_obj->{OFFICE16_ID}=$HASH_OSPP->{PRODUCT_ID};
									$audit_obj->{OFFICE16_KEY}=$HASH_OSPP->{PARTIAL_KEY};
								}
								else{
									$audit_obj->{OTHER_OFFICE_NAME}=$HASH_OSPP->{LICENSE_NAME};
									$audit_obj->{OTHER_OFFICE_ID}=$HASH_OSPP->{PRODUCT_ID};
									$audit_obj->{OTHER_OFFICE_KEY}=$HASH_OSPP->{PARTIAL_KEY};
								}
							}
						}
					}
				}
			}
		}
	}
	push (@AUDIT, $audit_obj);
	
}

foreach my $REF_AUDIT (@AUDIT){
	print($ofd "$REF_AUDIT->{COMPUTER_NAME};$REF_AUDIT->{MODEL};$REF_AUDIT->{SERIAL};$REF_AUDIT->{BIOS_OEM};$REF_AUDIT->{BIOS_KEY};$REF_AUDIT->{OS_NAME};$REF_AUDIT->{OS_ID};$REF_AUDIT->{OS_KEY};$REF_AUDIT->{OFFICE_NAME};$REF_AUDIT->{OFFICE_ID};$REF_AUDIT->{OFFICE_KEY};$REF_AUDIT->{OFFICE16_NAME};$REF_AUDIT->{OFFICE16_ID};$REF_AUDIT->{OFFICE16_KEY};$REF_AUDIT->{OTHER_OFFICE_NAME};$REF_AUDIT->{OTHER_OFFICE_ID};$REF_AUDIT->{OTHER_OFFICE_KEY};\n");
}