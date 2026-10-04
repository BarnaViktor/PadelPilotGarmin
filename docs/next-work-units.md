# Következő, kis kontextusú munkamenetek

Ez a lista a hátralévő munkát egymástól elválasztható fejlesztési egységekre
bontja. Egy új Codex-munkamenet egyszerre csak **egy azonosítót** kapjon meg,
például: „Folytasd az `S2-V1` egységgel”. Az egységek sorrendjét csak külön
termékdöntéssel változtasd meg.

**2026-10-04-i folytatás:** AM-1…AM-5 lezárva. Élő pontbevitel,
undo, szünet, játékidő, eredmény, megerősített eldobás és verziózott
aktív mentés/helyreállítás kész. FR265 és Enduro profilon 94/94 teszt,
optimalizált build és natív ellenőrzés sikeres.
Következő eszköz nélküli egység: AM-6, saját meccs eredménye és előzménye.
S2-V2 és a D-kapuk nyitva maradnak,
eszközkeresés nem szükséges.

## Munkamenet-szabály

Minden egység elején:

1. olvasd el a `development-handoff.md` fájlt és az egységnél felsorolt
   további fájlokat;
2. ellenőrizd a `git status --short` és `git log -1 --oneline` eredményét;
3. a már lezárt tesztkört csak akkor ismételd meg, ha az egység érinti annak
   kódját;
4. ne kezdj bele a következő azonosítóba ugyanabban a munkamenetben;
5. a végén rögzítsd az eredményt és a pontos következő azonosítót az átadási
   jegyzetben.

Kódmódosításos egységnél a minimális lezárás: célzott teszt, `git diff
--check`, érintett célkészülék fordítása és rövid dokumentációfrissítés.
Commit és push csak a felhasználó kifejezett kérésére történjen.

## S2 – Pontstatisztika hátralévő ellenőrzése

### S2-V1 – Vegyes rekordok natív szimulátoros bejárása

**Állapot:** kész (2026-09-25), FR265 és Enduro; eredmények és képek a
`development-handoff.md` fájlban és a gitignored `build/s2-v1-review/` alatt.

**Cél:** a v1/v2 rekordok és az új v3 pontrekordok együttes megjelenésének
vizuális ellenőrzése FR265 és Enduro skinen.

**Csak ezt olvasd:**

- `source/domain/MatchHistoryStore.mc`;
- `source/domain/MatchHistoryStatistics.mc`;
- `source/ui/MatchHistoryStatsView.mc`;
- `source/tests/ScoringEngineTests.mc` releváns history tesztjei.

**Lépések:**

1. hozz létre ismételhető, kizárólag fejlesztői/teszt célú vegyes előzményt:
   legalább egy pontadat nélküli régi és egy v3 rekordot;
2. nyisd meg a statisztikát MENU / hosszan nyomott UP művelettel;
3. ellenőrizd mind a négy lapot, különösen a pontlap nevezőjét;
4. ellenőrizd az UP/DOWN körbelapozást és a BACK-et;
5. őrizd meg a releváns képernyőképeket a gitignored `build/` alatt.

**Elfogadás:** a meccs-, szett- és időadatok minden érvényes rekordból, a
pontadatok kizárólag v3 rekordból számolódnak; nincs átfedés vagy körmaszk
miatti vágás 416 × 416 és 280 × 280 képponton.

**Ne módosítsd:** rekordformátum, 20-as korlát, release manifest.

### S2-V2 – Valós órás pontstatisztika

**Állapot:** FR265-re béta build felmásolva; az órás indítás és alapműködés
sikeres. A pontsorozat, újraindítás és törlés mérése még nyitott.
A 2026-10-04-i hatókörjelölések és egyedi statisztikalapok csak a helyi
fejlesztői buildben vannak; az órás UI-próba előtt friss béta szükséges.
Tesztóra hiányában ez az egység várakozik; AM-5 lezárva, AM-6 következik.

Az ismételhető gombsor és az elvárt értékek:
[valós órás pontstatisztikai próba](s2-v2-real-watch-point-test.md).

**Feltétel:** rendelkezésre áll FR265 vagy valamelyik cél-Enduro.

**Cél:** egy rövid félbehagyott és egy lezárt meccsel ellenőrizni a
pontszámlálást, undo-t, újraindítást és az összesítő pontlapját.

**Elfogadás:** a kézzel feljegyzett pontösszeg megegyezik az órán látható
W/L értékekkel; az arány helyes; a meccs törlése után az összesítés frissül.
Az eredményt a `development-handoff.md` és szükség esetén a
`supported-devices.md` kapja meg.

**Ne csinálj Store-kiadást** ebben az egységben.

## D – Készüléktámogatás valós órás kapui

Minden modellt külön munkamenetben ellenőrizz. Javasolt azonosítók:

- `D-FR265` – kontrollkészülék;
- `D-ENDURO` – első generáció, API 3.4 és 128 KiB;
- `D-ENDURO2` – SDK-azonosító `fenix7x`;
- `D-ENDURO3` – SDK-azonosító `enduro3`;
- `D-<device-id>` – egy további AMOLED-jelölt.

**Csak ezt olvasd:** `supported-devices.md`, `c4-real-watch-match-test.md`,
`store/release-checklist.md`.

**Egy modell kapuja:** teljes meccs, undo, szünet/folytatás, mentés,
előzmény, FIT-fájl, Garmin Connect, kültéri/beltéri olvashatóság, gombok,
memória és akkumulátor. Egy munkamenet csak egy modellt dokumentáljon.

**Elfogadás:** a modell sora bizonyítékkal frissül a
`supported-devices.md` fájlban. Release manifest csak sikeres valós órás
kapu után bővíthető, külön kiadási egységben.

## AM – Americano / Mexicano: egy saját meccs

**Felhasználói pontosítás, 2026-10-04:** kizárólag egy saját meccs
pontozása és végigvezetése. Nincs tornalebonyolítás, többpályás bevitel,
játékoslista, párosítás, partnerrotáció, fordulósorozat vagy ranglista.
AM-1…AM-5 lezárva; AM-6 eszköz nélkül folytatható, az S2-V2 órás kapu nyitott.

### AM-1 – Saját meccs szabályai

**Állapot:** kész (2026-10-04). Az
[egymeccses specifikáció](americano-mexicano-spec.md) rögzíti a felhasználó
két lezárási szabályát (A+B=X vagy A=X/B=X), a meccs előtt megadható pozitív
egész X-et és a kezdő csapat választását. X nem korlátozott 16/24/32-re.

**Kimenet:** lezárt specifikáció pontbeviteli, lezárási, döntetlen-, undo-,
kezdőcsapat- és hibásbemenet-példákkal, valamint a szünet, korai mentés és
helyreállítás későbbi integrációs elfogadásával. Termékkód nem módosult.
Az AM-2 domain is lezárult; következő azonosító: AM-3.

### AM-2 – Tiszta, egymeccses pontozási domain

**Állapot:** kész (2026-10-04). `PointMatchEngine` és 11 új domain-teszt;
FR265 és Enduro (API-minimum 3.4.0) 73/73 teszt, optimalizált build sikeres.
A lezárás, döntetlen, 20 pontos undo, kezdő csapat és hibás bemenet ellenőrizve.
UI/perzisztencia/FIT bekötés még nincs; következő azonosító AM-3.

**Bemenet:** az AM-1 lezárt specifikációja.

**Cél:** a két csapat pontjai, választott lezárási szabály (összpontszám
vagy csapatcél), pozitív egész X, kezdő csapat, eredmény
(győzelem/vereség/döntetlen) és undo, UI és perzisztencia nélkül.

**Elfogadás:** determinisztikus tesztek mindkét szabály határaira, azonos
pontállás eltérő lezárására, egyedi X-re, döntetlenre, lezáró pont undo-jára,
20 pontos undo-korlátra, mindkét kezdő csapatra, új meccsre és hibás bemenetre.
A klasszikus ScoringEngine viselkedése változatlan.

### AM-3 – Módválasztás és meccsbeállítás

**Állapot:** kész (2026-10-04). CLASSIC/AMERICANO/MEXICANO választó;
TOTAL X / TEAM X szabály, egyesével állítható 1–999 X (alapérték 24),
kezdő A/B, mentés és BACK/cancel. Indításkor független engine,
pontmódban 0–0-s kezdőnézet és BACK a megőrzött setupra. FR265 és Enduro
(API 3.4.0) profilon 78/78 teszt, optimalizált build, natív vizuális
ellenőrzés és mind a nyolc indítás/BACK kombináció sikeres.
Élő pontbevitel még nincs; következő azonosító AM-4.

**Cél:** klasszikus / Americano / Mexicano mód; az új módokban a két
lezárási szabály, egyesével állítható X és kezdő csapat választása, majd
egyetlen saját meccs indítása. Az alapértékek és a számválasztó technikai
felső határa megvalósítási részlet, nem új lezárási szabály.

**Elfogadás:** BACK/cancel megőrzi a beállítást; feliratok és kezelőszervek
elférnek FR265 és Enduro elrendezésben.

### AM-4 – Élő meccspontozás

**Állapot:** kész (2026-10-04). DOWN/UP, közös 500 ms-os védelem,
20 pontos undo, START-szünet és aktív játékidő. Automatikus
WIN/LOSS/DRAW eredmény, ponttiltás lezárás után; BACK visszavonja a
lezáró pontot és újranyit, az eredményen töltött időt kihagyva.
Szünetből és eredményről megerősített eldobás, NO alapértékkel,
visszatérés a megőrzött setupra. FR265 és Enduro API 3.4.0 profilon
85/85 teszt, optimalizált build, natív képernyők és mind a nyolc
kombináció indítás/pontozás/szünet/undo/eldobás integrációs próbája
sikeres. Következő azonosító AM-5.

**Cél:** MY TEAM / OPPONENT pontbevitel, undo, szünet és eredményre lépés.

**Elfogadás:** egy meccs végigpontozható; lezárás után további pont tiltott,
a lezáró pont undo-ja visszanyitja a meccset. Nincs fordulóváltás.

### AM-5 – Aktív meccs mentése és helyreállítása

**Állapot:** kész (2026-10-04). Külön v4 aktív pontmeccsmentés,
mód/szabály/X/kezdő csapat/pontállás és milliszekundumos játékidő.
Mentés indításkor, pont/undo/szünet/folytatás után, elrejtéskor és
alkalmazásleálláskor. Újraindítás után szüneteltetett folytatás; lezárt
meccsnél fagyasztott WIN/LOSS/DRAW. Az undo-napló újraindításkor üres,
a klasszikus meccshez igazodva. Eldobás csak az aktív mentést törli.
Régi klasszikus v1/v2/v3 olvasható, hibás pontmentés az előzményt nem érinti.
FR265 és Enduro API 3.4.0: 94/94 teszt, optimalizált build, natív
vizuális próba és nyolckombinációs tényleges újraindítás/folytatás/eldobás.
Következő azonosító AM-6.

**Cél:** verziózott, játékmódot, lezárási szabályt, X-et és kezdő csapatot
őrző aktív meccsmentés,
újraindítás utáni szüneteltetett folytatás vagy eldobás.

**Elfogadás:** régi normál meccsmentés olvasható; hibás új mentés nem
károsítja az előzményt. Pontállás és játékidő egyezik a mentett állapottal.

### AM-6 – Saját meccs eredménye és előzménye

**Cél:** mód, lezárási szabály, X, A/B pontszám, idő és eredmény
megjelenítése/mentése/törlése;
az összesítő pont- és időadatainak, valamint a döntetlennek a kezelése.

**Elfogadás:** döntetlen befejezett meccs, nem vereség vagy félbehagyás;
pont nem válik szetté/game-mé. Régi rekordok olvashatók, a 20 meccses korlát
megmarad. Endurón az új mód és az előzmény memóriahasználata ellenőrzött.

### AM-7 – Saját meccs FIT- és készülékkapuja

**Cél:** egy saját meccshez egy FIT-aktivitás; a pontok, eredmény, szünet,
mentés és a meglévő újraindítás utáni szegmenskezelés ellenőrzése.

**Elfogadás:** FR265 és Enduro teszt/build és natív szimulátoros kör,
majd később külön valós órás próba. Ne bővíts release manifestet.

## I2 – Instinct 2 monokróm adaptáció

Csak az `AM` sorozat után induljon.

### I2-1 – Korlátok és vizuális tokenek

API 3.4, 176 × 176, 96 KiB és monokróm megjelenítés felmérése. Kimenet:
színfüggetlen jelölések, betű- és térközméretek, képernyőnkénti drótváz.

### I2-2 – Beállítás és élő pontozás

Csak a Home/Setup/Score képernyők adaptációja, elrendezési tesztekkel és
szimulátoros gombbejárással.

### I2-3 – Szünet, összegzés és előzmény

Pause/Recovery/History/Stats képernyők adaptációja; minden pontjelölésnek
színek nélkül is egyértelműnek kell lennie.

### I2-4 – Memória- és valós órás kapu

Hosszú meccs, 20 előzményrekord, undo-terhelés, FIT, olvashatóság és
akkumulátor. Csak sikeres kapu után külön egységben módosulhat a manifest.

## W – Saját szinkron és webes felület

Csak az Instinct 2 után induljon.

### W-1 – Adatszerződés

Verziózott JSON-séma klasszikus és Americano/Mexicano saját meccshez;
idempotencia, időzóna, törlés és konfliktuskezelés. Kódolás előtt minta payloadokkal
jóváhagyandó.

### W-2 – Órás kimenő sor

Kapcsolat nélküli queue, újrapróbálás, sikeres nyugta és tárhelykorlát. Még
nincs Laravel vagy Vue fejlesztés.

### W-3 – Laravel API

Hitelesítés, idempotens feltöltés, validáció és migrációk; szerződéses
tesztekkel.

### W-4 – Vue alapnézet

Meccslista, részletek és az órával azonos aggregált statisztikák. Egy külön
egység foglalkozzon grafikonokkal és hosszú távú trendekkel.

### W-5 – Végponttól végpontig ellenőrzés

Óra → queue → API → web, megszakított hálózattal és ismételt feltöltéssel.
Adatvesztés vagy duplikáció nem elfogadható.
