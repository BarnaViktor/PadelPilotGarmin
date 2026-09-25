# S2-V2 – Valós órás pontstatisztikai próba

**Állapot:** FR265 béta build telepítve. A felhasználó az órás indítást és az
alapműködést ellenőrizte; a lent felsorolt pontsorozatot, újraindítást és
törlést még nem járta végig. Az éles, korábbi
`1.1.0` verzió önmagában nem alkalmas ennek az új funkciónak az ellenőrzésére.

**2026-09-25, FR265 telepítési előkészítés:** a jelenlegi munkafából készült
külön béta alkalmazásazonosítójú IQ-csomag:
`build/beta-1.1.0-export-4k_wxrxz/padel-pilot-1.1.0-beta.iq`, SHA-256
`fdfc09b33226e7d87c778760fb950af36daeb849935519493a815b400d8d4c60`.
A benne lévő PRG SHA-256 azonosítója
`50571b15e0a420615be60ea7b5045300d37f8010c607072d15457e95f790159f`.
Az FR265 `GARMIN/Apps` mappájába MTP-n átmásolt béta PRG visszaolvasott
azonosítója ugyanez. Az óra `GarminDevice.xml` fájlja `2905` szoftververziót
jelzett. Az órán való indulás sikeres; a kézi mérés még nyitott.

**Felhasználó által leolvasott kiindulás:** meccs nélküli állapot,
`MATCHES 0`, `POINT MATCHES 0`, pont W–L `0–0`.
2026-09-25-én idő hiányában az 1–3. mérési szakasz nem történt meg; innen
kell folytatni a következő alkalommal.

## Mérés előtt

1. Jegyezd fel az óra modelljét, firmware-verzióját, a telepítés módját és a
   tesztelt PRG SHA-256 azonosítóját. A 2026-09-24-i ellenőrzött build az
   FR265-höz `build/build-1.1.0-fr265-q6du_ayf/`, az első Enduróhoz
   `build/build-1.1.0-enduro-tdx2w90n/` alatt található. Ha új build készül,
   annak saját azonosítóját rögzítsd.
2. Az órán az előzménylistában hosszan nyomott UP-pal nyisd meg az összesítőt.
   Jegyezd fel a `MATCHES`, `FINISHED`, `STOPPED`, a pontlap W/L és `POINT
   MATCHES` kiinduló értékeit. A meglévő rekordokat ne töröld. Ha már 19 vagy
   20 rekord van, az új mentés a legrégebbit kiszoríthatja a 20-as korlát miatt;
   ilyenkor az alábbi hozzáadási különbségek nem használhatók önmagukban.
3. Ellenőrizd, hogy nincs folytatásra váró aktív meccs. Ha van, előbb őrizd
   meg vagy zárd le külön; a teszt ne írja felül a felhasználó meccsét.

Az A csapat a **MY TEAM**, a B az **OPPONENT**. Élő pontozáskor DOWN ad A-nak,
UP B-nek pontot, BACK visszavonja az utolsó pontot, START szüneteltet. Két
pontbevitel között várj legalább egy másodpercet a 500 ms-os bemenetvédelem
miatt. Minden érintést külön jelölj a kézi naplóban; az undo a hibás pontot
abból is húzza ki.

## 1. Félbehagyott meccs: 3–1 pont

1. Indíts új meccset. Az egyszerű ellenőrizhetőséghez a beállítás legyen
   `1 SET`, `ADVANTAGE`, A kezdő adogató. A többi beállítás maradhat alapérték.
2. Adj pontot ebben a sorrendben: **A, B, B (szándékos hiba), BACK, A**.
   Az érvényes állás ekkor A 30–15 B, összesen **2–1** pont.
3. Lépj ki az alkalmazásból az óra normál kezelőfelületén, majd indítsd újra.
   A `SAVED MATCH` képernyőn válaszd a folytatást; a meccs szüneteltetve
   nyílik meg. Ellenőrizd a 30–15 állást, majd folytasd.
4. Adj még **A** pontot. Az állás 40–15, az érvényes pontösszeg **3–1**;
   game még nem fejeződött be.
5. START → `SAVE & END` → megerősítés. Az előzményben ellenőrizd a
   `MATCH STOPPED` jelölést és a 40–15 állást. Nyisd meg újra a statisztikát:
   a pontlap az előző állapothoz képest A-nál +3, B-nél +1, a `POINT MATCHES`
   +1; a `STOPPED` +1. A pontarányt a **teljes aktuális** W/(W+L) alapján
   ellenőrizd, lefelé kerekített egész százalékként.

## 2. Lezárt meccs: 24–0 pont

1. Indíts új `1 SET`, `ADVANTAGE` meccset.
2. Adj A-nak **24 pontot**, minden pont között legalább egy másodpercet
   várva. Négy pont egy game; hat nyert game után a meccs 6–0-val lezárul.
   Minden game után hasonlítsd össze az órát a kézi, 4/8/12/16/20/24 pontos
   számlálóval.
3. Az összegzőn START → mentés és megerősítés. Az új előzmény győzelem és
   6–0-s szett legyen. A pontlap az előző állapothoz képest A-nál +24,
   B-nél +0, a `POINT MATCHES` +1; a `FINISHED` és a győzelmek száma +1.

Ha induláskor üres volt az előzmény, a két mentés után **27–1**, `POINT RATE
96%`, `POINT MATCHES 2`, `MATCHES 2`, `FINISHED 1`, `STOPPED 1` az elvárt
összesítés. Meglévő előzmények esetén az induló értékekhez hozzáadott
pontokból számolj arányt; a régi, pontadat nélküli rekordok ne növeljék a
`POINT MATCHES` értéket.

## 3. Törlés és eredmény

1. Az előzményben a teszthez készített félbehagyott rekord részletén nyisd
   meg a törlést. A `NO` után a rekord és az összesítés maradjon változatlan.
2. Ismételd meg `YES` választással. A pontlap A értéke 3-mal, B értéke
   1-gyel, a `POINT MATCHES` 1-gyel csökkenjen; a `STOPPED` és `MATCHES`
   szintén 1-gyel csökkenjen. Üres induló előzménynél ekkor **24–0**,
   `POINT RATE 100%`, `POINT MATCHES 1` marad.
3. A lezárt tesztrekord törléséről külön dönts a teszt végén; ha megtartod,
   jelöld meg a naplóban. A törlés csak a helyi előzményrekordot érinti;
   a mentett aktivitást külön kezeld.

**Mérési napló:** dátum, modell, firmware, telepítési mód, PRG SHA-256,
kiinduló négy statisztikalap, minden beviteli/undo esemény, újraindítás utáni
állás, a három ellenőrzési ponton kijelzett értékek, fényképek útvonala,
eltérés vagy összeomlás esetén az utolsó helyes állapot és a kiváltó gombsor.
A mérés akkor PASS, ha a kézi pontösszeg, az undo, a helyreállítás, a két
mentett rekord, az arány és a törlés utáni összesítés mind egyezik az órával.
