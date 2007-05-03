# @tag: USTVA_abstraction
# @description: Abstraktion der USTVA Report Daten. Dies vereinfacht die Integration von Steuerberichten anderer Nationen in Lx-Office.
# @depends: release_2_4_2

# Abstraktionlayer between general Taxreports and USTVA
# Most of the data and structures are not used yet, but maybe in future, 
# if there are other international customizings are requested...

###################

die("This script cannot be run from the command line.") unless ($main::form);

sub do_query {
  my ($query, $may_fail) = @_;

  if (!$dbh->do($query)) {
    mydberror($query) unless ($may_fail);
    $dbh->rollback();
    $dbh->begin_work();
  }
}


sub create_tables {

  # Watch out, SCHEMAs are new in Lx!
  my @queries = ( # Watch out, it's a normal array!
      q{ CREATE SCHEMA tax;
      },
      q{ CREATE TABLE tax.report_categorys (
           id              integer NOT NULL PRIMARY KEY,
           description     text,
           subdescription  text
         );
      },              
      q{ CREATE TABLE tax.report_headings (
           id              integer NOT NULL PRIMARY KEY,
           category_id     integer NOT NULL REFERENCES tax.report_categorys(id),
           type            text,
           description     text,
           subdescription  text
         );
      },
      q{ CREATE TABLE tax.report_variables (
           id            integer NOT NULL PRIMARY KEY,
           position      text NOT NULL,
           heading_id    integer REFERENCES tax.report_headings(id),
           description   text,
           taxbase       text,
           dec_places    text,
           valid_from    date
         );
      },
  );

  do_query("DROP SCHEMA tax CASCADE;", 1);
  map({ do_query($_, 0); } @queries);
  
  return 1;
  
}

sub do_copy {

  my @copy_statements = (
    "COPY tax.report_categorys FROM STDIN WITH DELIMITER ';'",
    "COPY tax.report_headings FROM STDIN WITH DELIMITER ';'", 
    "COPY tax.report_variables FROM STDIN WITH DELIMITER ';'",
  );

  my @copy_data = (
    [ "0;;",
      "1;Lieferungen und sonstige Leistungen;(einschlie�lich unentgeltlicher Wertabgaben)",
      "2;Innergemeinschaftliche Erwerbe;",
      "3;Erg�nzende Angaben zu Ums�tzen;",
      "99;Summe;",
    ],
    ["0;0;;;",
     "1;1;received;Steuerfreie Ums�tze mit Vorsteuerabzug;",
     "2;1;recieved;Steuerfreie Ums�tze ohne Vorsteuerabzug;",
     "3;1;recieved;Steuerpflichtige Ums�tze;(Lieferungen und sonstige Leistungen einschl. unentgeltlicher Wertabgaben)",
     "4;2;recieved;Steuerfreie innergemeinschaftliche Erwerbe;",
     "5;2;recieved;Steuerpflichtige innergemeinschaftliche Erwerbe;",
     "6;3;recieved;Ums�tze, f�r die als Leistungsempf�nger die Steuer nach � 13b Abs. 2 UStG geschuldet wird;",
     "66;3;recieved;;",
     "7;3;paied;Abziehbare Vorsteuerbetr�ge;",
     "8;3;paied;Andere Steuerbetr�ge;",
     "99;99;;Summe;",
    ],
    ["0;keine;0;< < < keine UStVa Position > > >;;;19700101",
     "1;41;1;Innergemeinschaftliche Lieferungen (� 4 Nr. 1 Buchst. b UStG) an Abnehmer mit USt-IdNr.;0;0;19700101",
     "2;44;1;neuer Fahrzeuge an Abnehmer ohne USt-IdNr.;0;0;19700101",
     "3;49;1;neuer Fahrzeuge au�erhalb eines Unternehmens (� 2a UStG);0;0;19700101",
     "4;43;1;Weitere steuerfreie Ums�tze mit Vorsteuerabzug;0;0;19700101",
     "5;48;2;Ums�tze nach � 4 Nr. 8 bis 28 UStG;0;0;19700101",
     "6;51;3;zum Steuersatz von 16 %;0;0;19700101",
     "7;511;3;;6;2;19700101",
     "8;81;3;zum Steuersatz von 19 %;0;0;19700101",
     "9;811;3;;8;2;19700101",
     "10;86;3;zum Steuersatz von 7 %;0;0;19700101",
     "11;861;3;;10;2;19700101",
     "12;35;3;Ums�tze, die anderen Steuers�tzen unterliegen;0;0;19700101",
     "13;36;3;;12;2;19700101",
     "14;77;3;Lieferungen in das �brige Gemeinschaftsgebiet an Abnehmer mit USt-IdNr.;0;0;19700101",
     "15;76;3;Ums�tze, f�r die eine Steuer nach � 24 UStG zu entrichten ist;0;0;19700101",
     "16;80;3;;15;2;19700101",
     "17;91;4;Erwerbe nach � 4b UStG;0;0;19700101",
     "18;97;5;zum Steuersatz von 16 %;0;0;19700101",
     "19;971;5;;18;2;19700101",
     "20;89;5;zum Steuersatz von 19 %;0;0;19700101",
     "21;891;5;;20;2;19700101",
     "22;93;5;zum Steuersatz von 7 %;0;0;19700101",
     "23;931;5;;22;2;19700101",
     "24;95;5;zu anderen Steuers�tzen;0;0;19700101",
     "25;98;5;;24;2;19700101",
     "26;94;5;neuer Fahrzeuge von Lieferern ohne USt-IdNr. zum allgemeinen Steuersatz;0;0;19700101",
     "27;96;5;;26;2;19700101",
     "28;42;66;Lieferungen des ersten Abnehmers bei innergemeinschaftlichen Dreiecksgesch�ften (� 25b Abs. 2 UStG);0;0;19700101",
     "29;60;66;Steuerpflichtige Ums�tze im Sinne des � 13b Abs. 1 Satz 1 Nr. 1 bis 5 UStG, f�r die der Leistungsempf�nger die Steuer schuldet;0;0;19700101",
     "30;45;66;Nicht steuerbare Ums�tze (Leistungsort nicht im Inland);0;0;19700101",
     "31;52;6;Leistungen eines im Ausland ans�ssigen Unternehmers (� 13b Abs. 1 Satz 1 Nr. 1 und 5 UStG);0;0;19700101",
     "32;53;6;;31;2;19700101",
     "33;73;6;Lieferungen sicherungs�bereigneter Gegenst�nde und Ums�tze, die unter das GrEStG fallen (� 13b Abs. 1 Satz 1 Nr. 2 und 3 UStG);0;0;19700101",
     "34;74;6;;33;2;19700101",
     "35;84;6;Bauleistungen eines im Inland ans�ssigen Unternehmers (� 13b Abs. 1 Satz 1 Nr. 4 UStG);0;0;19700101",
     "36;85;6;;35;2;19700101",
     "37;65;6;Steuer infolge Wechsels der Besteuerungsform sowie Nachsteuer auf versteuerte Anzahlungen u. �. wegen Steuersatz�nderung;;2;19700101",
     "38;66;7;Vorsteuerbetr�ge aus Rechnungen von anderen Unternehmern (� 15 Abs. 1 Satz 1 Nr. 1 UStG), aus Leistungen im Sinne des � 13a Abs. 1 Nr. 6 UStG (� 15 Abs. 1 Satz 1 Nr. 5 UStG) und aus innergemeinschaftlichen Dreiecksgesch�ften (� 25b Abs. 5 UStG);;2;19700101",
     "39;61;7;Vorsteuerbetr�ge aus dem innergemeinschaftlichen Erwerb von Gegenst�nden (� 15 Abs. 1 Satz 1 Nr. 3 UStG);;2;19700101",
     "40;62;7;Entrichtete Einfuhrumsatzsteuer (� 15 Abs. 1 Satz 1 Nr. 2 UStG);;2;19700101",
     "41;67;7;Vorsteuerbetr�ge aus Leistungen im Sinne des � 13b Abs. 1 UStG (� 15 Abs. 1 Satz 1 Nr. 4 UStG);;2;19700101",
     "42;63;7;Vorsteuerbetr�ge, die nach allgemeinen Durchschnittss�tzen berechnet sind (�� 23 und 23a UStG);;2;19700101",
     "43;64;7;Berichtigung des Vorsteuerabzugs (� 15a UStG);;2;19700101",
     "44;59;7;Vorsteuerabzug f�r innergemeinschaftliche Lieferungen neuer Fahrzeuge au�erhalb eines Unternehmens (� 2a UStG) sowie von Kleinunternehmern im Sinne des � 19 Abs. 1 UStG (� 15 Abs. 4a UStG);;2;19700101",
     "45;69;8;in Rechnungen unrichtig oder unberechtigt ausgewiesene Steuerbetr�ge (� 14c UStG) sowie Steuerbetr�ge, die nach � 4 Nr. 4a Satz 1 Buchst. a Satz 2, � 6a Abs. 4 Satz 2, � 17 Abs. 1 Satz 6 oder � 25b Abs. 2 UStG geschuldet werden;;2;19700101",
     "46;39;8;Anrechnung (Abzug) der festgesetzten Sondervorauszahlung f�r Dauerfristverl�ngerung (nur auszuf�llen in der letzten Voranmeldung des Besteuerungszeitraums, in der Regel Dezember);;2;19700101",
  ],
  );

  for my $statement ( 0 .. $#copy_statements ) {

    do_query($iconv->convert($copy_statements[$statement]), 0);
    
    for my $copy_line ( 1 .. $#{$copy_data[$statement]} ) {
      #print $copy_data[$statement][$copy_line] . "<br />"
      $dbh->pg_putline($iconv->convert($copy_data[$statement][$copy_line]) . "\n");
    }
    $dbh->pg_endcopy;
  }
  return 1;
}


return create_tables() && do_copy();

