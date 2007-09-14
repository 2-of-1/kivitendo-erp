<?
/*
Funktionsbibliothek für den Datenimport in Lx-Office ERP

Copyright (C) 2005
Author: Holger Lindemann
Email: hli@lx-system.de
Web: http://lx-system.de

*/

require_once "DB.php";

$address = array(
	"name" => "Firmenname",
	"department_1" => "Abteilung",
	"department_2" => "Abteilung",
	"street" => "Strasse + Nr",
	"zipcode" => "Plz",
	"city" => "Ort",
	"country" => "Land",
	"contact" => "Ansprechpartner",
	"phone" => "Telefon",
	"fax" => "Fax",
	"homepage" => "Homepage",
	"email" => "eMail",
	"notes" => "Bemerkungen",
	"discount" => "Rabatt (nn.nn)",
	"taxincluded" => "incl. Steuer? (t/f)",
	"terms" => "Zahlungsziel (Tage)",
	"customernumber" => "Kundennummer",
	"vendornumber" => "Lieferantennummer",
	"taxnumber" => "Steuernummer",
	"ustid" => "Umsatzsteuer-ID",
	"account_number" => "Kontonummer",
	"bank_code" => "Bankleitzahl",
	"bank" => "Bankname",
	"branche" => "Branche",
	//"language" => "Sprache (de,en,fr)",
	"sw" => "Stichwort",
	"creditlimit" => "Kreditlimit (nnnnnn.nn)"); /*,
	"hierarchie" => "Hierarchie",
	"potenzial" => "Potenzial",
        "ar" => "Debitorenkonto",
        "ap" => "Kreditorenkonto",
        "matchcode" => "Matchcode",
	"customernumber2" => "Kundennummer 2"); 
	Kundenspezifisch */
        
$shiptos = array(
	"shiptoname" => "Firmenname",
	"shiptodepartment_1" => "Abteilung",
	"shiptodepartment_2" => "Abteilung",
	"shiptostreet" => "Strasse + Nr",
	"shiptozipcode" => "Plz",
	"shiptocity" => "Ort",
	"shiptocountry" => "Land",
	"shiptocontact" => "Ansprechpartner",
	"shiptophone" => "Telefon",
	"shiptofax" => "Fax",
	"shiptoemail" => "eMail",
	"customernumber" => "Kundennummer",
	"vendornumber" => "Lieferantennummer");

$parts = array( 
	"partnumber" => "Artikelnummer",
	"description" => "Artikeltext",
	"unit" => "Einheit",
	"weight" => "Gewicht in Benutzerdefinition",
	"onhand" => "Lagerbestand",
	"notes" => "Beschreibung",
	//"makemodel" => "Hersteller",
	//"model" => "Modellbezeichnung",
	"bin" => "Lagerort",
	"image" => "Pfad/Dateiname",
	"drawing" => "Pfad/Dateiname",
	"microfiche" => "Pfad/Dateiname",
	"listprice" => "Listenpreis",
	"sellprice" => "Verkaufspreis",
	"lastcost" => "letzter EK",
	"art" => "Ware/Dienstleistung (*/d), mu&szlig; vor den Konten kommen",
	"inventory_accno" => "Bestandskonto",
	"income_accno" => "Erl&ouml;skonto",
	"expense_accno" => "Konto Umsatzkosten",
	"obsolete" => "Gesperrt (Y/N)",
	"lastcost" => "letzer EK-Preis",
	"rop" => "Mindestbestand",
	"shop" => "Shopartikel (Y/N)",
	"assembly" => "St�ckliste (Y/N); wird noch nicht unterst�tzt",
	"partsgroup" => "Warengruppenbezeichnung",
	"partsgroup1" => "2.Warengruppenbezeichnung",
	//"income_accno_0" => "?Nummer? f�r Erl�se Inland",
	//"income_accno_1" => "?Nummer? f�r Erl�se EG",
	//"income_accno_3" => "?Nummer? f�r Erl�se Ausland",
	);
	
$contactscrm = array(
	"customernumber" => "Kundennummer",
	"vendornumber" => "Lieferantennummer",
	"cp_cv_id" => "FirmenID in der db",
	"firma" => "Firmenname",
	"cp_abteilung" => "Abteilung",
	"cp_position" => "Position/Hierarchie",
	"cp_greeting" => "Anrede",
	"cp_title" => "Titel",
	"cp_givenname" => "Vorname",
	"cp_name" => "Nachname",
	"cp_email" => "eMail",
	"cp_phone1" => "Telefon 1",
	"cp_phone2" => "Telefon 2",
	"cp_mobile1" => "Mobiltelefon 1",
	"cp_mobile2" => "Mobiltelefon 2",
	"cp_homepage" => "Homepage",
	"cp_street" => "Strasse",
	"cp_country" => "Land",
	"cp_zipcode" => "PLZ",
	"cp_city" => "Ort",
	"cp_privatphone" => "Privattelefon",
	"cp_privatemail" => "private eMail",
	"cp_notes" => "Bemerkungen",
	"cp_stichwort1" => "Stichwort(e)",
	"katalog" => "Katalog",
	"inhaber" => "Inhaber",
	"contact_id" => "Kontakt ID"
	);

$contacts = array(
	"customernumber" => "Kundennummer",
	"vendornumber" => "Lieferantennummer",
	"cp_cv_id" => "FirmenID in der db",
	"firma" => "Firmenname",
	"cp_greeting" => "Anrede",
	"cp_title" => "Titel",
	"cp_givenname" => "Vorname",
	"cp_greeting" => "Anrede",
	"cp_name" => "Nachname",
	"cp_email" => "eMail",
	"cp_phone1" => "Telefon 1",
	"cp_phone2" => "Telefon 2",
	"cp_mobile1" => "Mobiltelefon 1",
	"cp_mobile2" => "Mobiltelefon 2",
	"cp_privatphone" => "Privattelefon",
	"cp_privatemail" => "private eMail",
	"cp_homepage" => "Homepage",
	"katalog" => "Katalog",
	"inhaber" => "Inhaber",
	"contact_id" => "Kontakt ID"
	);

function checkCRM() {
global $db;
	$sql="select * from crm";
	$rs=$db->getAll($sql);
	if ($rs) {
		return true;
	} else {
		return false;
	}
}

function chkUsr($usr) {
// ist es ein gültiger ERP-Benutzer? Er muß mindestens 1 x angemeldet gewesen sein.
global $db;
	$sql="select * from employee where login = '$usr'";
	$rs=$db->getAll($sql);
	if ($rs[0]["id"]) { return $rs[0]["id"]; } 
	else { return false; };
}

function getKdId() {
// die nächste freie Kunden-/Lieferantennummer holen
global $db,$file,$test;
	if ($test) { return "#####"; }
	$sql1="select * from defaults";
	$sql2="update defaults set ".$file."number = '%s'";
	$db->lock();
	$rs=$db->getAll($sql1);
	$nr=$rs[0][$file."number"];
	preg_match("/^([^0-9]*)([0-9]+)/",$nr,$hits);
	if ($hits[2]) { $nr=$hits[2]+1; $nnr=$hits[1].$nr; }
	else { $nr=$hits[1]+1; $nnr=$nr; };
	$rc=$db->query(sprintf($sql2,$nnr));
	if ($rc) { 
		$db->commit(); 
		return $nnr;
	} else { 
		$db->rollback(); 
		return false;
	};
}

function chkKdId($data) {
// gibt es die Nummer schon?
global $db,$file,$test;
	$sql="select * from $file where ".$file."number = '$data'";
	$rs=$db->getAll($sql);
	if ($rs[0][$file."number"]==$data) {
		// ja, eine neue holen
		return getKdId();
	} else {
		return $data;
	}
}

function getKdRefId($data) {
// gibt es die Nummer schon?
global $db,$file,$test;
	if (empty($data) or !$data) {   
		return false; 
	} 
	$sql="select * from $file where ".$file."number = '$data'";
	$rs=$db->getAll($sql);
	return $rs[0]["id"];
}

function suchFirma($tab,$data) {
// gibt die Firma ?
global $db;
	if (empty($data) or !$data) {   
		return false; 
	}
	$data=strtoupper($data);
	$sql="select * from $tab where upper(name) like '%$data%'";
	$rs=$db->getAll($sql);
	if (!$rs) {
		$org=$data;
		while(strpos($data,"  ")>0) {
			$data=ereg_replace("  "," ",$data);
		}
	 	$data=preg_replace("/[^A-Z0-9]/ ",".*",trim($data));
		$sql="select * from $tab where upper(name) ~ '$data'"; 
		$rs=$db->getAll($sql);
		if (count($rs)==1) {
			return array("cp_cv_id"=>$rs[0]["id"],"Firma"=>$rs[0]["name"]);
		}
		return false;
	} else {
		return array("cp_cv_id"=>$rs[0]["id"],"Firma"=>$rs[0]["name"]);
	}
}

$land=array("DEUTSC"=>"D","FRANKR"=>"F","SPANIE"=>"ES","ITALIE"=>"I","HOLLAN"=>"NL","NIEDER"=>"NL",
	"BELGIE"=>"B","LUXEMB"=>"L","NORWEG"=>"N","FINNLA"=>"","GRIECH"=>"GR","OESTER"=>"A",
	"SCHWEI"=>"CH","SCHWED"=>"S","AUSTRI"=>"A");

function mkland($data) {
global $land;
	$data=strtr($data,array("Ö"=>"OE","Ä"=>"AE","Ü"=>"UE","ö"=>"OE","ä"=>"AE","ü"=>"UE","ß"=>"SS"));
	$data=strtoupper(substr($data,0,6));
	$cntr=$land[$data];
	return (strlen($cntr)>0)?$cntr:substr($data,0,3);
}

//Suche Nach Kunden-/Lieferantenummer
function getFirma($nummer,$tabelle) {
global $db;
	$nummer=strtoupper($nummer);
	$sql="select id from $tabelle where upper(".$tabelle."number) = '$nummer'";
	$rs=$db->getAll($sql);
	if (!$rs) {
		$nr=ereg_replace(" ","%",$nummer);
		$sql="select id,".$tabelle."number from $tabelle where upper(".$tabelle."number) like '$nr'";
		$rs=$db->getAll($sql);
		if ($rs) {
			$nr=ereg_replace(" ","",$nummer);
			foreach ($rs as $row) {
				$tmp=ereg_replace(" ","",$row[$tabelle."number"]);
				if ($tmp==$nr) return $row["id"];
			}
		} else { 
			return false;
		}
	} else {
		return $rs[0]["id"];
	}
}

function getAllBG($db) {
	$sql  = "select * from buchungsgruppen order by description";
	$rs=$db->getAll($sql);
	return $rs;
}

class myDB extends DB {
// Datenbankklasse

 var $rc = false;
 var $showErr = false;
 var $db = false;
 var $debug = false;
 var $logsql = false;
 var $errfile = false;
 var $logfile = false;


/****************************************************
* uudecode
* in: string
* out: string
* dekodiert Perl-UU-kodierte Passwort-Strings
* http://de3.php.net/base64_decode (bug #171)
*****************************************************/
	function uudecode($encode) {
	  $b64chars="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

	  $encode = preg_replace("/^./m","",$encode);
	  $encode = preg_replace("/\n/m","",$encode);
	  for($i=0; $i<strlen($encode); $i++) {
	    if ($encode[$i] == '')
	      $encode[$i] = ' ';
	    $encode[$i] = $b64chars[ord($encode[$i])-32];
	  }
   
	  while(strlen($encode) % 4)
	    $encode .= "=";

	  return base64_decode($encode);
	}

	function dbFehler($sql,$err) {
		if ($this->showErr)
			echo "$sql : $err\n";
	}

	function showDebug($sql) {	
		echo $sql."\n";
		if ($this->debug==2) {
			print_r($this->rc);
		};
	}

	function logSql($sql) {
		if (!$this->logfile)  $this->logfile=fopen("import.sql","a");
		fputs($this->logfile,$sql."\n");
	}
	function myDB($usr) {
		// Datenbankparameter des ERP-Users benutzen.
		$tmp = file_get_contents("../users/$usr.conf");
		preg_match("/dbname => '(.+)'/",$tmp,$hits);
		$dbname=$hits[1];
		preg_match("/dbpasswd => '(.+)'/",$tmp,$hits);
		if ($hits[1]) {
			$dbpasswd=$this->uudecode($hits[1]);
		} else {
        		$dbpasswd="";
		};
		preg_match("/dbuser => '(.+)'/",$tmp,$hits);
		$dbuser=$hits[1];
		preg_match("/dbhost => '(.+)'/",$tmp,$hits);
		$dbhost=$hits[1];
		if (!$dbhost) $dbhost="localhost";
		if ($dbpasswd) {
			$dns=$dbuser.":".$dbpasswd."@".$dbhost."/".$dbname;
		} else {
			$dns=$dbuser."@".$dbhost."/".$dbname;
		};
		$dns="pgsql://".$dns;
		$this->db=DB::connect($dns);
		if (!$this->db) DB::dbFehler("oh oh oh",$this->db->getDebugInfo());
		if (DB::isError($this->db)) {
			$this->dbFehler("Connect",$this->db->getDebugInfo());
			die ($this->db->getDebugInfo());
		}
		return $this->db;
	}

	function query($sql) {
		$this->rc=@$this->db->query($sql);
		if ($this->logsql) $this->logSql($sql);
		if ($this->debug) $this->showDebug($sql);
		if(DB::isError($this->rc)) {
			$this->dbFehler($sql,$this->rc->getMessage());
			return false;
		} else {
			return $this->rc;
		}
	}
	function getAll($sql) {
		$this->rc=@$this->db->getAll($sql,DB_FETCHMODE_ASSOC);
		if ($this->logsql) $this->logSql($sql);
		if ($this->debug) $this->showDebug($sql);
		if(DB::isError($this->rc)) {
			$this->dbFehler($sql,$this->rc->getMessage());
			return false;
		} else {
			return $this->rc;
		}
	}	

	function lock() {
		$this->query("BEGIN");
	}
	function commit() {
		$this->query("COMMIT");
	}
	function rollback() {
		$this->query("ROLLBACK");
	}
	function chkcol($tbl) {
	// gibt es die Spalte import schon?
		$rc=$this->db->query("select import from $tbl limit 1");
		if(DB::isError($rc)) {
			$rc=$this->db->query("alter table $tbl add column import int4");
			if(DB::isError($rc)) { return false; }
			else { return true; }
		
		} else { return true; };
	}
}

?>
