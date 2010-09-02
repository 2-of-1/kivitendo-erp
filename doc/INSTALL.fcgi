
Diese Datei ist in Plain Old Documentation geschrieben. Mit

> perldoc INSTALL.fcgi

ist sie deutlich leichter zu lesen.

=head1 FastCGI f�r Lx-Office

=head2 Was ist FastCGI?

Direkt aus L<http://de.wikipedia.org/wiki/FastCGI> kopiert:

  FastCGI ist ein Standard f�r die Einbindung externer Software zur Generierung
  dynamischer Webseiten in einem Webserver. FastCGI ist vergleichbar zum Common
  Gateway Interface (CGI), wurde jedoch entwickelt, um dessen
  Performance-Probleme zu umgehen.


=head2 Warum FastCGI?

Perl Programme (wie Lx-Office eines ist) werden nicht statisch kompiliert.
Stattdessen werden die Quelldateien bei jedem Start �bersetzt, was bei kurzen
Laufzeiten einen Gro�teil der Laufzeit ausmacht. W�hrend SQL Ledger einen
Gro�teil der Funktionalit�t in einzelne Module kapselt, um immer nur einen
kleinen Teil laden zu m�ssen, ist die Funktionalit�t von Lx-Office soweit
gewachsen, dass immer mehr Module auf den Rest des Programms zugreifen.
Zus�tzlich benutzen wir umfangreiche Bibliotheken um Funktionalt�t nicht selber
entwickeln zu m�ssen, die zus�tzliche Ladezeit kosten. All dies f�hrt dazu dass
ein Lx-Office Aufruf der Kernmasken mittlerweile deutlich l�nger dauert als
fr�her, und dass davon 90% f�r das Laden der Module verwendet wird.

Mit FastCGI werden nun die Module einmal geladen, und danach wird nur die
eigentliche Programmlogik ausgef�hrt.

=head2 Kombinationen aus Webservern und Plugin.

Folgende Kombinationen sind getestet:

 * Apache 2.2.11 (Ubuntu) und mod_fastcgi.
 * Apache 2.2.11 (Ubuntu) und mod_fcgid:

Als Perl Backend wird das Modul FCGI.pm verwendet. Vorsicht: FCGI 0.69 und
h�her ist extrem strict in der Behandlung von Unicode, und verweigert bestimmte
Eingaben von Lx-Office. Solange diese Probleme nicht behoben sind, muss auf die
Vorg�ngerversion FCGI 0.68 ausgewichen werden.


=head2 Konfiguration des Webservers.

Zuerst muss das FastCGI-Modul aktiviert werden. Dies kann unter
Debian/Ubuntu z.B. mit folgendem Befehl geschehen:

  a2enmod fastcgi

bzw.

  a2enmod fcgid

Die Konfiguration f�r die Verwendung von Lx-Office mit FastCGI erfolgt
durch Anpassung der vorhandenen Alias- und Directory-Direktiven. Dabei
wird zwischen dem Installationspfad von Lx-Office im Dateisystem
("/path/to/lx-office-erp") und der URL unterschieden, unter der
Lx-Office im Webbrowser erreichbar ist ("/web/path/to/lx-office-erp").

Folgendes Template funktioniert mit mod_fastcgi:

  AliasMatch ^/web/path/to/lx-office-erp/[^/]+\.pl /path/to/lx-office-erp/dispatcher.fpl
  Alias       /web/path/to/lx-office-erp/          /path/to/lx-office-erp/

  <Directory /path/to/lx-office-erp>
    AllowOverride All
    AddHandler fastcgi-script .fpl
    Options ExecCGI Includes FollowSymlinks
    Order Allow,Deny
    Allow from All
  </Directory>

  <DirectoryMatch /path/to/lx-office-erp/users>
    Order Deny,Allow
    Deny from All
  </DirectoryMatch>

...und f�r mod_fcgid muss die erste Zeile ge�ndert werden in:

  AliasMatch ^/web/path/to/lx-office-erp/[^/]+\.pl /path/to/lx-office-erp/dispatcher.fcgi


Hierdurch wird nur ein zentraler Dispatcher gestartet. Alle Zugriffe
auf die einzelnen Scripte werden auf diesen umgeleitet. Dadurch, dass
zur Laufzeit �fter mal Scripte neu geladen werden, gibt es hier kleine
Performance-Einbu�en. Trotzdem ist diese Variante einer globalen
Benutzung von "AddHandler fastcgi-script .pl" vorzuziehen.


Es ist m�glich die gleiche Lx-Office Version parallel unter cgi und fastcgi zu
betreiben. Daf�r bleiben Directorydirektiven bleiben wie oben beschrieben, die
URLs werden aber umgeleitet:

  # Zugriff ohne FastCGI
  Alias       /web/path/to/lx-office-erp                /path/to/lx-office-erp

  # Zugriff mit FastCGI:
  AliasMatch ^/web/path/to/lx-office-erp-fcgi/[^/]+\.pl /path/to/lx-office-erp/dispatcher.fpl
  Alias       /web/path/to/lx-office-erp-fcgi/          /path/to/lx-office-erp/

Dann ist unter C</web/path/to/lx-office-erp/> die normale Version erreichbar,
und unter C</web/opath/to/lx-office-erp-fcgi/> die FastCGI Version.

Achtung:

Die AddHandler Direktive vom Apache ist entgegen der Dokumentation
anscheinend nicht lokal auf das Verzeichnis beschr�nkt sondern global im
vhost.

=head2 Entwicklungsaspekte

Wenn �nderungen in der Konfiguration von Lx-Office gemacht werden, muss der
Server neu gestartet werden.

Bei der Entwicklung f�r FastCGI ist auf ein paar Fallstricke zu achten. Dadurch
dass das Programm in einer Endlosschleife l�uft, m�ssen folgende Aspekte
geachtet werden:

=head3 Programmende und Ausnahmen: C<warn>, C<die>, C<exit>, C<carp>, C<confess>

Fehler, die dass Programm normalerweise sofort beenden (fatale Fehler), werden
mit dem FastCGI Dispatcher abgefangen, um das Programm am Laufen zu halten. Man
kann mit C<die>, C<confess> oder C<carp> Fehler ausgeben, die dann vom Dispatcher
angezeigt werden. Die Lx-Office eigene C<$::form->error()> tut im Prinzip das
Gleiche, mit ein paar Extraoptionen. C<warn> und C<exit> hingegen werden nicht
abgefangen. C<warn> wird direkt nach STDERR, also in Server Log eine Nachricht
schreiben (sofern in der Konfiguration nicht die Warnungen in das Lx-Office Log
umgeleitet wurden), und C<exit> wird die Ausf�hrung beenden.

Prinzipiell ist es kein Beinbruch, wenn sich der Prozess beendet, fcgi wird ihn
sofort neu starten. Allerdings sollte das die Ausnahme sein. Quintessenz: Bitte
kein C<exit> benutzen, alle anderen Exceptionmechanismen sind ok.

=head3 Globale Variablen

Um zu vermeiden, dass Informationen von einem Request in einen anderen gelangen,
m�ssen alle globalen Variablen vor einem Request sauber initialisiert werden.
Das ist besonders wichtig im C<$::cgi> und C<$::auth> Objekt, weil diese nicht
gel�scht werden pro Instanz, sondern persistent gehalten werden.

In C<SL::Dispatcher> gibt es einen sauber abgetrennten Block der alle
kanonischen globalen Variablen listet und erkl�rt. Bitte keine anderen
einf�hren ohne das sauber zu dokumentieren.

Datenbankverbindungen wird noch ein Guide verfasst werden, wie man sichergeht,
dass man die richtige erwischt.

=head2 Performance und Statistiken

Die kritischen Pfade des Programms sind die Belegmasken, und unter diesen ganz
besonders die Verkaufsrechnungsmaske. Ein Aufruf der Rechnungsmaske in
Lx-Office 2.4.3 stable dauert auf einem Core2duo mit 4GB Arbeitsspeicher und
Ubuntu 9.10 eine halbe Sekunde. In der 2.6.0 sind es je nach Menge der
definierten Variablen 1-2s. Ab der Moose/Rose::DB Version sind es 5-6s.

Mit FastCGI ist die neuste Version auf 0,26 Sekunden selbst in den kritischen
Pfaden, unter 0,15 sonst.

=head2 Bekannte Probleme

=head3 Encoding Awareness

UTF-8 kodierte Installationen sind sehr anf�llig gegen fehlerhfate Encodings
unter FCGI. latin9 Installationen behandeln falsch kodierte Zeichen eher
unwissend, und geben sie einfach weiter. UTF-8 verweigert bei fehlerhaften
Programmpfaden kurzerhand aus ausliefern. Es wird noch daran gearbeitet alles
Fehler da zu beseitigen.

