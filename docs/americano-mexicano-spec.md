# AM-1 – Americano / Mexicano: egy saját meccs pontozása

> Aktuális kiadási csomag: **1.3.0 produkció**, 2026-10-07. A produkciós csomag,
> verziózás és Store-szöveg: [kiadási jegyzet](releases/1.3.0.md).
> Az alábbi korábbi checkpointok dátumozott fejlesztési bizonyítékok;
> az 1.1.0 fájlnevek és a korábbi béta telepítése történeti adatok.
> Következő egység: I2-1 (Instinct 2 korlátok és vizuális tokenek); AM-7 automatikus kapu lezárva 2026-10-07-én.


**Állapot:** AM-1 lezárva, 2026-10-04. A felhasználó két választható
pontszám-alapú lezárást, meccs előtt megadható X pontszámot és kezdő
csapatot kért. AM-2 domain és AM-3 módválasztás/meccsbeállítás elkészült
és ellenőrizve. Az AM-4 élő pontozása, az AM-5 aktív mentése/helyreállítása
és az AM-6 lezárt/félbehagyott előzménye is kész. Az AM-7 FIT-integráció
automatikus kapuja lezárva; a valós órás FIT/Connect próba külön nyitott.

## Jóváhagyott használati cél

Az óra egyetlen saját meccset vezessen végig, a saját csapat és az ellenfél
pontjait számolva. A mérkőzés résztvevői a teljes meccs alatt adottak.
A felhasználó kifejezetten nem kér bajnokság- vagy tornalebonyolítást.

A beállítás és a pontozás két csapatot használ: A = MY TEAM, B = OPPONENT.
Játékosnév, egyéni azonosító, teljes résztvevőlista, pályaszám,
partnerrotáció, automatikus párosítás, fordulósorozat és ranglista nem
része a funkciónak. Más pálya eredményét nem kell és nem lehet bevinni.
Újabb meccs új, önálló mérkőzésként indul.

Az Americano és Mexicano itt egy saját meccs pontozási módjai; a torna
párosítási eltéréseit az alkalmazás nem kezeli. Az azonos lezárási szabályú
módok közös pontozási domaint használhatnak, a választott mód megmarad az
eredményen és az előzményben. A klasszikus padelpontozás továbbra is elérhető.

## Meccs előtti beállítások és lezárás

Mind az Americano, mind a Mexicano saját meccsében megadható:

- lezárási szabály: közös összpontszám vagy egy csapat célpontszáma;
- X: pozitív egész pontszám, egyesével állítható; nem csak 16/24/32;
- kezdő csapat: A = MY TEAM vagy B = OPPONENT, az első adogató csapat.

Egy elfogadott labdamenet pontosan egy pontot ad A-nak vagy B-nek.
A meccs a választott szabály teljesülésekor automatikusan lezárul.
A beállítások a meccs indításakor rögzülnek; az aktív meccsben nem
módosíthatók. Új meccs bármelyik kezdő csapattal mindig 0–0-ról indul.

| Lezárási szabály | Feltétel | Példa X = 24 esetén |
|---|---|---|
| Közös összpontszám | A + B = X | 14–10 vagy 12–12 lezárt; 14–9 még aktív |
| Egy csapat célpontszáma | A = X vagy B = X | 24–23 lezárt; 14–10 és 23–23 még aktív |

Közös összpontszámnál a több pontot szerzett csapat nyer. Páros X esetén
az X/2–X/2 döntetlen is befejezett meccs; páratlan X mellett nincs döntetlen.
Csapatcél esetén a célpontot először elérő csapat nyer; befejezett döntetlen
nem keletkezik. Egy pont különbség is elég: nincs kétpontos hosszabbítás.
Mindkét szabály közvetlen pontszámlálás, game, szett és időlimit nélkül.

A korábbi, csak 16/24/32-es közös pontkeret-javaslatot ez a felhasználói
döntés váltja fel. Az alapértékek és a számválasztó technikai felső határa
az AM-3 megvalósításának részletei; nem változtathatják meg a két lezárási
szabály jelentését, és a pontszám nem szűkíthető a korábbi három értékre.

## Egy meccs menete

Játékmód, lezárási szabály, X és kezdő csapat → indítás → pontozás →
eredmény → mentés.
Nem következik automatikusan új forduló vagy új párosítás.

- DOWN pontot ad a saját csapatnak, UP az ellenfélnek.
- BACK visszavonja az utolsó pontot, legfeljebb a legutóbbi 20 bevitelből.
- START szüneteltet; szünetben nincs pontbevitel, az aktív játékidő nem nő.
- A meglévő 500 ms-os védelem kiszűri a túl gyors ismételt pontbevitelt.
- A lezáró pont után további pont elutasítva; végleges mentés előtt a
  lezáró pont visszavonható, ezzel a meccs újranyílik.
- Korai SAVE & END megerősítés után félbehagyott meccset ment az aktuális
  pontokkal és játékidővel. DISCARD külön megerősítéssel eldobja a meccset.

A kezdő csapat választása az első adogató csapatot rögzíti, pontelőnyt
nem ad, és nem korlátozza, melyik csapat szerezheti az első pontot.
A pontozási bővítés nem vezet be külön automatikus Americano/Mexicano
szervablokk- vagy térfélcsere-szabályt. A klasszikus game/tie-break
szervarendje nem alkalmazható automatikusan erre a pontozásra.

## Mentés, eredmény és előzmény

Egy aktív meccs mentendő: játékmód, lezárási szabály, X, kezdő csapat,
A/B pontállás, játékidő és a folytatáshoz szükséges állapot. Újraindítás
után ugyanaz a meccs szüneteltetve folytatható vagy megerősítéssel eldobható. Az undo-ablak
újraindítás utáni viselkedése a jelenlegi meccshez igazodik; külön,
tartós undo-napló nem követelmény. Hibás vagy ismeretlen mentés nem
indíthat találgatással meccset, és nem ronthatja a régi normál mentéseket.

A végeredmény MY TEAM / OPPONENT pontszámot, meccsidőt, a választott
játékmódot, lezárási szabályt és X értékét mutatja. Győzelem, vereség,
döntetlen és félbehagyott állapot különbözik. Döntetlen nem minősül vereségnek vagy félbehagyott meccsnek.
Nem szabad a pontokat game- vagy szettértékként tárolni.

Az AM-5/AM-6 mentési formátuma támogatja a módot és a döntetlent, a v1/v2/v3
normál előzmények olvashatóságának megtartásával. A jelenlegi v3 formátum
befejezett rekordhoz csak 0/1 győztest enged; a -1 félbehagyott állapothoz
tartozik, ezért döntetlenre nem használható változtatás nélkül.
A legfeljebb 20 helyi meccs korlátja megmarad; külön tornaelőzmény nincs.

Az AM-6 v4 előzménysémája:
`[4, mode, endRule, X, startingTeam, [A, B], durationSeconds, result]`.
Ez külön nyolcelemű rekord, nem használ klasszikus szett/game mezőket.
`result`: ACTIVE = félbehagyva mentett, WIN/LOSS/DRAW = befejezett;
az ACTIVE csak előzményben jelenti a félbehagyást. A betöltés ellenőrzi,
hogy az eredmény a szabály, X és a pontok alapján valóban lehetséges-e.
Az aktív v4 mentés ettől külön formátum marad, milliszekundumos idővel.
Az AM-7 külön v5 checkpointja a már elmentett FIT után még helyi mentésre
váró meccset őrzi; normál folytatás továbbra is v4.
A mezők, mintavételezés és újraindítási szabályok: [AM-7 FIT-adatszerződés](am7-fit-contract.md).
Az előzmény a klasszikus rekordokkal egyezően egész másodperceket tárol.

Az összesítőbe az új mód saját meccseinek pontjai és ideje kerülhetnek.
Az AM-6 rögzítse a döntetlen megjelenítését, valamint azt, hogy a győzelmi
arány nevezőjében minden befejezett meccs, a döntetlen is szerepel.
A szettösszesítést csak tényleges szettek növelik. Régi, pontadat nélküli
rekordok továbbra sem növelik a pontstatisztika nevezőjét.
Egy meccs egy, a viselő részvételét rögzítő FIT-aktivitás; a meglévő
újraindítás utáni aktivitásszegmens-kezelés megmarad.

## AM-2 elfogadási példák

Az alábbi pontozási példák mindkét játékmódra és mindkét kezdő csapatra
érvényesek. Az állapotok pontbeviteli sorozattal, UI és perzisztencia
nélkül előállíthatók.

1. Közös összpontszám, X=24: A=14, B=9 még aktív; B új pontjával 14–10-re
   lezárul, A nyer. További pont elutasítva, az állapot változatlan.
2. Közös összpontszám, X=24: 12–11 után B-ponttal 12–12-es befejezett
   döntetlen. Undo után 12–11 és aktív meccs; A-ponttal 13–11, A nyer.
3. Csapatcél, X=24: 14–10 még aktív. A 23–23-as állásból A-ponttal 24–23,
   A nyer, hosszabbítás nélkül. További pont elutasítva. Undo után újra
   23–23 és aktív meccs; B-ponttal 23–24, B nyer.
4. Ugyanaz a 14–10-es pontállás közös X=24 mellett lezárt, csapatcél X=24
   mellett aktív. Csapatcél X=7 esetén 7–0 és 0–7 is lezárt győzelem.
5. Szabadon megadott X: közös X=17 mellett 9–7 aktív, 9–8 lezárt; közös
   X=18 mellett 9–9 befejezett döntetlen. Csapatcél X=18 mellett 9–9 még
   aktív, 18–17 lezárt. X=1 esetén mindkét szabály egyetlen ponttal zár.
6. Új meccs mindig 0–0 és aktív. A kezdő csapat A/B választása megmarad,
   nem ad pontelőnyt; mindkét csapat kaphatja az első pontot.
7. A, B, B, undo, A sorozat után 2–1 az állás. Üres undo nem változtat
   állapotot; a legutóbbi 20 pont visszavonható. Húsznál hosszabb sorozat
   visszavonása után a régebbi pontok megmaradnak, a szabály és X változatlan.
8. Hibás pontcsapat, kezdő csapat, ismeretlen játékmód vagy lezárási szabály,
   valamint nulla, negatív, nem egész vagy hiányzó X elutasítva. Hibás bevitel
   nem módosít pontállást, lezárást, eredményt vagy undo-előzményt. A domain
   determinisztikus, WatchUi-, Storage- és FIT-függés nélkül tesztelhető.

## Későbbi integráció elfogadási példái

- AM-3: mindkét módban mindkét lezárási szabály, X és mindkét kezdő csapat
  választható; BACK/cancel megőrzi az előző értéket. Az indítás az elfogadott
  beállításokat használja, nem egy korábbi meccs szabályát.
- AM-4: szünetben pontbevitellel nem változik az állás, az aktív játékidő
  nem nő. Lezáráskor eredményre lépés, undo-val visszanyitás működik.
- AM-5: újraindítás után a szabály, X, kezdő csapat, pontállás és játékidő
  megmarad; a folytatás szüneteltetve indul.
- AM-6: korai SAVE & END 2–1-nél félbehagyott meccs. Közös X=24 mellett
  12–12 befejezett döntetlen, nem vereség; a mód, szabály és X az előzményből
  is felismerhető. Régi rekordok és a 20-as korlát megmaradnak.

## Folytatás

AM-1 és AM-2 lezárva. A `source/domain/PointMatchEngine.mc` UI-, tárolás-
és FIT-független domainje mindkét szabályt, X-et és a kezdő csapatot őrzi.
A `source/tests/PointMatchEngineTests.mc` 11 tesztje az összes fenti AM-2
példát mindkét módban és mindkét kezdő csapattal ellenőrzi; FR265 és Enduro
profilon a teljes 73/73 AM-2 tesztcsomag sikeres.
Az AM-3 mód- és meccsbeállítás is kész: alapértelmezett CLASSIC mód;
pontmódban közös X=24, kezdő A, X egyesével 1–999 között állítható.
Mindkét szabály és kezdő csapat választható; cancel megőrzi az előző
értéket. Indítás új engine-nel, 0–0-ról; az elfogadott beállítások a
kezdőképernyőn látszanak. BACK ugyanarra a setupra tér vissza.
FR265 és Enduro profilon 78/78 teszt, build, natív vizuális és indítás/BACK
próba sikeres. AM-4 is kész: élő pontbevitel 500 ms-os védelemmel, undo, szünet,
aktív játékidő, WIN/LOSS/DRAW és a lezáró ponttal visszanyitás.
A megerősített eldobás visszatér a setupra; szünetben és az eredményen
nem nő az aktív idő. FR265 és Enduro profilon 85/85 teszt, optimalizált
build, natív vizuális és nyolckombinációs integrációs próba sikeres.
AM-5 is kész: aktív v4 mentés, szüneteltetett helyreállítás, változatlan
pontállás és játékidő, régi klasszikus mentések olvashatósága. Az undo-napló
újraindításkor üres, a klasszikus meccshez igazodva; a folytatás utáni pontok
visszavonhatók. Lezárt eredmény is helyreáll, fagyasztott idővel.
FR265 és Enduro API 3.4.0: 94/94 teszt, optimalizált build és natív ellenőrzés.
AM-6: eredmény, előzmény és összesítő. AM-7: a saját meccs FIT- és készülékellenőrzése.

Tesztóra nincs csatlakoztatva; ne keress eszközt. Az S2-V2 és a valós órás
készülékkapuk nyitottak. Egy munkamenet egy AM-azonosítót kezel.
