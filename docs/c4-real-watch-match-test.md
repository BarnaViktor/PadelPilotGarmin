# C4.1 – Valós órás meccsteszt

Állapot: végrehajtásra előkészítve, valós Forerunner 265 teszt szükséges.

## Cél és elfogadási feltételek

A teszt akkor sikeres, ha egy teljes, valódi padelmeccs végigvezethető a
Forerunner 265 órán úgy, hogy:

- az órán látható pont-, game- és szetteredmény végig megegyezik a pályán
  vezetett független eredménnyel;
- a szerváló csapat, a szervaoldal és a tie-break szervarend nem
  tér el a tényleges játéktól;
- a szükséges korrekciók az undo vagy a szünetmenü segítségével adatvesztés
  nélkül elvégezhetők;
- az alkalmazás nem fagy le, nem lép ki és a meccs végéig nem veszít állapotot;
- a lezárt meccs bekerül a helyi előzménybe;
- a mentett Garmin-aktivitás megjelenik az órán és szinkronizálás után a
  Garmin Connectben.

Bármely pontozási vagy szervarendi eltérés, összeomlás, elveszett meccsállapot
vagy hiányzó FIT-aktivitás blokkoló hiba.

## Tesztkörnyezet

- Eszköz: Garmin Forerunner 265, nem 265S
- Alkalmazás: a teszt napján készített `bin/padel-pilot.prg`
- Szabály: 3 szett, advantage, normál döntő szett, 7 pontos tie-break
- Kezdő adogató: a pályán ténylegesen kezdő csapat
- Független referencia: egy játékostárs vagy papír/jegyzet, legalább
  game-enként rögzített eredménnyel
- Induló akkumulátor: ______ %
- Óra firmware-verzió: ____________________
- Teszt dátuma és helye: ____________________

## Telepítés előtti ellenőrzés

1. Fordítsd le a projektet `fr265` célra, és csak sikeres buildet telepíts.
2. Csatlakoztasd az órát USB-n, majd másold a PRG-t az óra
   `GARMIN/Apps` könyvtárába.
3. Válaszd le szabályosan az órát, indítsd el az alkalmazást, és ellenőrizd,
   hogy a beállítóképernyő megjelenik.
4. Ellenőrizd, hogy nincs korábbi aktív meccs; ha van, dokumentáld, majd vesd
   el, hogy a teszt tiszta állapotból induljon.
5. Szinkronizáld az órát, és jegyezd fel az induló akkumulátort.

## A meccs alatt

1. Indítsd el a meccset a fenti alapbeállítással.
2. Minden labdamenet után közvetlenül rögzítsd a pontot. A kijelzőt csak rövid,
   játék közben természetes pillantással ellenőrizd.
3. Minden game végén hasonlítsd össze az órát a független referenciával.
4. Legalább egyszer ellenőrizd az alábbi műveleteket, természetes
   meccshelyzetben:
   - hibás pontbevitel és azonnali undo;
   - szünet, majd folytatás;
   - game után megszakítás nélkül bevihető a következő pont;
   - no-ad 40–40 után nem jelenik meg külön oldalválasztó;
   - két gyors egymás utáni azonos pontgombnyomásra csak egy pont kerül be;
   - az aktív eredményképernyő megérintése nem módosítja az állapotot;
   - a szünetmenü szervaválasztója kizárólag gombokkal végigkezelhető.
5. Ha kialakul, külön ellenőrizd a deuce/advantage és a tie-break működését.
   Ezeket nem kell mesterségesen előidézni a valódi meccs rovására.
6. Eltérésnél ne próbáld emlékezetből rekonstruálni az eseményt: állítsd meg a
   játékot, írd fel az órán látható és a helyes állapotot, az utolsó műveletet,
   valamint azt, hogy undo-val javítható volt-e.
7. A meccs végén ellenőrizd az összegzést, majd mentsd a meccset.

## Olvashatósági próba

Ugyanazon a tesztnapon ellenőrizd a fő eredményképernyőt közvetlen napfényben,
árnyékban és sötét környezetben. Mindhárom helyzetben egy legfeljebb két
másodperces, játék közben természetes rápillantással azonosíthatónak kell
lennie:

- melyik sor a saját csapat és melyik az ellenfél;
- a szett-, game- és pontállásnak;
- a szerváló csapatnak és a szervaoldalnak;
- a szünet- és kézi szervaválasztó képernyő következő műveletének.

A teszt sikertelen, ha az óra fényerejének kézi felülbírálása szükséges, fontos
szöveg vagy szám levágódik, illetve az állapot csak a piros/zöld szín alapján
azonosítható. Jegyezd fel azt is, ha csuklómozdulat után a kijelző túl lassan
válik olvashatóvá; ez külön eszközviselkedési megfigyelés.

## Meccs utáni ellenőrzés

1. Nyisd meg a helyi meccselőzményt, és egyeztesd a győztest, a szettarányt,
   a szettenkénti game-eredményt és az időtartamot.
2. Ellenőrizd az órán, hogy létrejött és megnyitható a padel aktivitás.
3. Szinkronizáld Garmin Connecttel, majd ellenőrizd:
   - a sportbesorolást;
   - az időtartamot;
   - a pulzus- és kalóriaadatokat;
   - a GPS-nyomvonalat, a távolságot, valamint az átlagos és maximális
     sebességet;
   - az eredmény és a szettadatok megjelenését, amennyiben a Garmin Connect
     felülete megjeleníti a developer mezőket.
4. A meccsvégi összegzés ACTIVITY oldalán ellenőrizd a távolságot, az átlagos
   és maximális sebességet, az átlagos és maximális pulzust, valamint a
   kalóriát.
5. Jegyezd fel a záró akkumulátort. Ez ezen a teszten csak megfigyelés; a C4
   külön akkumulátormérését nem helyettesíti.

## Eredménylap

- Tényleges végeredmény: ____________________
- Órán mentett végeredmény: ____________________
- Helyi előzmény helyes: igen / nem
- FIT-aktivitás létrejött: igen / nem
- Garmin Connect szinkron sikeres: igen / nem
- GPS-nyomvonal létrejött: igen / nem
- Mért távolság: ____________________
- Átlagos / maximális sebesség: ____________________
- Órás ACTIVITY összegzés helyes: igen / nem
- Garmin Connectben látható meccseredmény: igen / nem / USB-s telepítés
- Pontozási eltérések száma: ______
- Undo teszt: sikeres / sikertelen / nem történt
- Szünet–folytatás: sikeres / sikertelen / nem történt
- Folyamatos pontbevitel game után: sikeres / sikertelen / nem történt
- Folyamatos no-ad döntő pont: sikeres / sikertelen / nem történt
- Gyors duplagombnyomás védelme: sikeres / sikertelen / nem történt
- Véletlen érintés védelme: sikeres / sikertelen / nem történt
- Gombos szervaválasztás: sikeres / sikertelen / nem történt
- Olvashatóság napfényben: sikeres / sikertelen / nem történt
- Olvashatóság árnyékban: sikeres / sikertelen / nem történt
- Olvashatóság sötétben: sikeres / sikertelen / nem történt
- Két másodperces rápillantási próba: sikeres / sikertelen / nem történt
- Deuce/advantage: sikeres / sikertelen / nem alakult ki
- Tie-break: sikeres / sikertelen / nem alakult ki
- Alkalmazáshiba vagy kilépés: ____________________
- Záró akkumulátor: ______ %
- Megjegyzések: ____________________
- Összesített eredmény: **PASS / FAIL**

Hiba esetén a reprodukcióhoz őrizd meg a tesztelt PRG-t, és add meg a
firmware-verziót, a meccs beállításait, az utolsó helyes állapotot, a kiváltó
gombsort és a megfigyelt hibás állapotot.
