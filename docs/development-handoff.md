# Fejlesztési átadás – 2026-10-07

> Aktuális kiadási csomag: **1.3.0 produkció**, 2026-10-07. A produkciós csomag,
> verziózás és Store-szöveg: [kiadási jegyzet](releases/1.3.0.md).
> Az alábbi korábbi checkpointok dátumozott fejlesztési bizonyítékok;
> az 1.1.0 fájlnevek és a korábbi béta telepítése történeti adatok.
> Következő egység: I2-1 (Instinct 2 korlátok és vizuális tokenek); AM-7 automatikus kapu lezárva 2026-10-07-én.


## Aktuális folytatási pont – I2-1

**AM-7 automatikus kapu lezárva, 2026-10-07.**

2026-10-07: a pontmódos FIT az indítás, pont/undo, szünet/folytatás,
automatikus eredmény, mentés és eldobás teljes útjára bekötve.
A 11 tényleges mező közvetlen pontokat őriz, szett/game mezők nélkül.
A mezők és a mintavételezés: [FIT-adatszerződés](am7-fit-contract.md).

Sikertelen indításkor ACTIVITY ERROR / RETRY ACTIVITY jelenik meg.
A false indítás ugyanazzal az inicializált rögzítővel újrapróbálható;
a rögzítő korai eldobása és újralétrehozása a szimulátorban elvesző
felvételeket okozott. Mentési/eldobási hiba megtartja az aktív meccset.
Sikeres FIT után v5 aktív checkpoint jelzi a még helyi mentésre váró
állapotot. Újraindítás FINISH SAVE nézetet ad, új FIT és undo nélkül.

Az onStop megkísérli a már leállított FIT mentését akkor is, ha az időzítő
újraindítása false értéket ad. A natív VM-cserés bejáró ezért kifejezetten
befejezi a termék onStop callbackjét az új VM indítása előtt; a szimulátor
monkeydo appcseréje versenyezhet a leállással.

Tizenhárom új teszt a mezőformátumra, 999-es pontokra, eredményekre,
undo/időzítőre, közös debounce-ra, false/exception save/discard hibákra,
FIT utáni historyhibára és újraindításra, v4/v5 migrációra, tulajdonosra,
indítási/stop hibákra és a két kijelzőméretre. **FR265 és Enduro: 116/116 teszt**, optimalizált build és `git diff --check` sikeres.

Mindkét profil natív eredménye: 8 újraindítási, 8 teljes és 4 korai mentés/eldobás
folyamat; külön valós FIT-siker + előzményhiba után újraindított befejezés.
Profilonként mind a 27 várt FIT-fájl CRC-je és developer mezői ellenőrizve a Garmin
Python SDK-val. Külön visszaállított DRAW meccs 0 / 0,001 másodperces új
szegmense is menthető (FR265 / Enduro). A 20 rekordos előzmény, 920 pontos állapot és
20 elemű undo mellett megfigyelt Enduro-memória: 86,9 / 123,8 kB.
Ez szimulátoros, fejlesztői bejárós mérés; valós órás FIT/Connect kapu nyitott.

Naplók, képek, FIT-fájlok, CRC/mező jegyzőkönyvek és dekóder:
`build/am7-review/`. Az indító minden alkalommal külön XDG_CONFIG_HOME-ot
használ a virtuális compositorhoz, a felhasználó asztali beállításaihoz
nem nyúl. Indítás: `python3 build/am7-review/start.py`; bejáró:
`python3 build/am7-review/review.py <fr265|enduro>`.
A tesztapp külön alkalmazásazonosítóval dolgozik; csak saját aktív,
előzmény- és driver tesztkulcsait kezeli.

Verzió, kiadási manifest és az archivált 1.2.0 csomag változatlan.
Commit/push, Store-kiadás és órára másolás nem történt.

Végleges build-bizonyítékok (SDK 9.2.0, API-minimum 3.4.0):

- `build/test-1.2.0-fr265-vz8_x742/build-info.json`;
- `build/test-1.2.0-enduro-h6jkvvte/build-info.json`;
- `build/build-1.2.0-fr265-n3p87_0h/build-info.json` (64 604 bájt);
- `build/build-1.2.0-enduro-bltf0p73/build-info.json` (74 108 bájt).

A natív bejáró KeyEvent-helyettesítő és ideiglenes diagnosztikai logging
miatt `-l 0` fordítással készül. A termék és a tesztek normál típusellenőrzést
használnak. Az Enduro végső vizuális ismétlése 9 képet, a FR265 teljes
bejárója 37 képet rögzít; a flow naplók az összes végigjárt kombinációt őrzik.
A végső FIT-listák: `enduro-fit-verification.json`, `fr265-fit-verification.json`;
a külön lezárt helyreállítás: `*-completed-verification.json` és `*-completed.fit`.
A mezők CRC-ellenőrzése után külön új streamből dekódolunk.
A gyors pontok utolsó record-frissítése mintavétel miatt kimaradhat;
a session pontok és eredmény ezért külön is ellenőrzöttek.

**Következő azonosító: I2-1**, Instinct 2 API 3.4 / 176 × 176 / 96 KiB /
monokróm korlátok és vizuális tokenek. Ebben még nincs implementáció vagy
release manifest bővítés. S2-V2, D-kapuk és az AM-7 valós órás FIT/Connect,
memória- és akkumulátorpróbája nyitott, eszközkeresés nem szükséges.
A saját háttérszimulátor a munkamenet végén leállt.

## AM-6 – Előző checkpoint

**AM-6 lezárva, 2026-10-07.** Az Americano/Mexicano meccs végén START
nyitja a SAVE MATCH / DISCARD MATCH menüt. Szünetben RESUME / SAVE & END /
DISCARD MATCH választható, UP felfelé, DOWN lefelé lép és körbefordul.
Mentés és eldobás külön YES/NO megerősítéssel, NO alapértékkel működik;
BACK vagy NO visszatér a menübe, onnan BACK az eredményre vagy a játékba.
Az eredményről BACK továbbra is visszavonja a lezáró pontot.

A v4 pontelőzmény külön nyolcelemű séma:
`[4, mode, endRule, X, startingTeam, [A, B], durationSeconds, result]`.
ACTIVE az előzményben félbehagyva mentett, WIN/LOSS/DRAW befejezett rekord.
Betöltéskor a domain ellenőrzi a beállításokat, a pontok lehetségességét
és a tárolt eredmény egyezését. Régi v1/v2/v3 klasszikus rekordok
olvashatók maradnak; a közös tároló legfeljebb 20 meccset őriz.
Az aktív v4 séma nem változott. Az előzmény egész másodperces,
az aktív helyreállítás továbbra is milliszekundumos időt őriz.

A pontmódos előzménylistán a mód és WIN/LOSS/DRAW/STOPPED felirat,
A/B pontok és idő látható. A részletekben két lap van: mód/szabály/X,
eredmény, A/B pontok, kezdő csapat és idő; majd pontarány és meccsidő.
Nincs fiktív szett/game lap. A meglévő, NO alapértékű törlési megerősítés
és az összesítő frissülése mindkét rekordfajtán működik.

Az összesítő külön DRAWS mutatót kapott. Döntetlen befejezett meccs,
a győzelmi arány nevezőjében is szerepel; félbehagyott meccs nem.
A pontmódok pontjai és ideje növelik az összesítést, szettet nem hoznak létre.
Régi, pontadat nélküli rekord nem növeli a pontstatisztika nevezőjét.
Az ötjegyű pontösszegek kisebb betűvel jelennek meg; 20 darab 998–998-as
rekord 19 960–19 960-as összesítése is olvasható mindkét kijelzőméreten.

Sikertelen előzménymentésnél az aktív meccs és a megerősítés megmarad,
HISTORY SAVE FAILED / START: TRY AGAIN jelenik meg. Siker után az aktív
mentés törlődik, a nézetelrejtés és az onStop nem hozza vissza.
A már kilépett delegate további gombjai/mentése nem hoznak létre második
előzményrekordot. Új meccs mentése a megőrzött setupra, helyreállított
meccsé a főmenübe tér vissza.

Kilenc új teszt ellenőrzi a nyolc mód/szabály/kezdőcsapat kombinációt,
győzelmet/vereséget/döntetlent/félbehagyást, sérült és lehetetlen rekordokat,
v1/v2/v3/v4 együttolvasást, a közös 20-as korlátot és törlést,
vegyes összesítést és nulla nevezőt, fizikai save/NO/BACK/YES ágakat,
hibás mentés újrapróbálását és az eldobás melletti érintetlen előzményt.
A 280/416 pixeles elrendezéseket és az ötjegyű pontösszegeket is ellenőrzik.
A felhasználó által jelzett módválasztó UP/DOWN csere javítása megmaradt;
a gombteszt mindkét irányt, körbefordulást, save/cancel-t és a numerikus
UP-növelés/DOWN-csökkentés viselkedést ellenőrzi.

A natív bejáró külön alkalmazásazonosítóval dolgozik, a termék domain/UI
forrását használja. Mindkét profilon nyolc kombinációt indít a tényleges
setup START ágon, 900 pont után 20 undo-val, majd fizikai DOWN/UP-val
441–441-re jut. Feltöltött 20-as előzmény mellett ellenőrzi a szünetből
indított NO/cancel és YES/SAVE & END ágat, majd egy befejezett WIN mentését
999-es X-szel és 100 órás idővel. A sikeres mentés utáni onHide nem
hozza vissza az aktív meccset. A helyreállított meccs és a DRAW/LOSS mentés
gombágait az egységtesztek ellenőrzik.

Profilonként 27 natív képernyő: szünet, mentési/eldobási menü és megerősítés,
mentési hiba, vegyes teljes előzmény, DRAW/LOSS/WIN/STOPPED részletek,
pontlap, törlési YES/NO, négy összesítő és 20 pontrekord ötjegyű összesítése.
Az utolsó térközjavítás után külön, hétképes natív ismétlés is sikeres
mindkét profilon: 100 órás szünetképernyő, pontmódos részletek és ötjegyű
összesítés. A FR265 hosszú szünetidő-feliratának gombsúgóval való átfedése
függőleges középre igazítással javítva; a részletek alsó feliratai több
térközt kaptak. A végleges képek `*-layout-visual-*.png` néven vannak.
Endurón a 35 rögzített stressz-/vizuális képen **73,1–78,5 / 123,8 kB**
memória látható. Ez a fejlesztői bejáró szimulátoros mérése, nem valós órás
FIT-/akkumulátormérés. A terhelés előkészítése egyetlen Storage-írással
történik; a termék mentési ága egy rekordot ír a gördülő előzménybe.

Újrafuttatás: `python3 build/am6-review/start.py`, majd
`python3 build/am6-review/review.py <fr265|enduro>`; profilváltás vagy
tesztapp-váltás előtt a saját háttérszimulátort indítsd újra.
Csak az utolsó elrendezési körhöz add meg a `--layout-only` kapcsolót.
A KeyEvent-helyettesítő miatt a bejáró `-l 0` fordítással készül;
a termék és az egységtesztek normál típusellenőrzéssel fordulnak.
Naplók, képek és memóriacsíkok a gitignored `build/am6-review/` alatt.
A tesztapp a saját aktív/előzmény tesztadatait törli, a termékazonosító
adattárolóját nem használja.

Végleges forrás: **FR265 és Enduro profilon 103/103 teszt**, optimalizált
build és `git diff --check` sikeres. SDK 9.2.0, API-minimum 3.4.0.
Az SDK dinamikus konténerekhez kapcsolódó típusfigyelmeztetései megmaradnak;
fordítási hiba nincs. A PRG mérete FR265-ön 60 572, Endurón 69 084 bájt.
Build-bizonyítékok:

- `build/test-1.2.0-fr265-ahtefwf_/build-info.json`;
- `build/test-1.2.0-enduro-cf43bnot/build-info.json`;
- `build/build-1.2.0-fr265-oue9w2mo/build-info.json`;
- `build/build-1.2.0-enduro-tsejf73s/build-info.json`.

A végleges forráshash-ek és az összesített ellenőrzési jegyzőkönyv:
`build/am6-review/source-hashes.json`, `build/am6-review/verification.json`.
A saját háttérszimulátor a munkamenet végén leállt.

**Következő azonosító: AM-7**, pontmódos FIT-indítás, események,
szünet/folytatás, mentés/eldobás és újraindítás utáni szegmenskezelés.
S2-V2 és a D-kapuk külön valós órás ellenőrzések maradnak.
Verzió és kiadási manifest nem változott; az archivált 1.2.0 csomag
nem tartalmazza ezt a fejlesztést. Commit/push, Store-kiadás és órára
másolás nem történt.

## AM-5 – Előző checkpoint

**AM-5 lezárva, 2026-10-04.** Az Americano/Mexicano saját meccs most
verziózott aktív mentést és újraindítás utáni helyreállítást kapott.
A `PointMatchEngine` exportja közvetlen A/B pontpár; helyreállítás előtt
ellenőrzi a típusokat, a nemnegatív pontokat és a szabály szerinti felső
határt. TOTAL esetén A+B nem lépheti túl X-et; a kivonásos ellenőrzés a
legnagyobb Number X-nél sem csordul túl. TEAM esetén mindkét csapat nem
érheti el egyszerre X-et. Hibás állapot sem pontot, sem undo-t nem módosít.

Az `ActiveMatchStore` új pontsémája:
`[4, elapsedMs, [mode, endRule, X, startingTeam], [A, B]]`.
A klasszikus v1/v2/v3 olvasás és a v3 írás megmaradt, másodperces idővel;
a pontág milliszekundumot tárol, így a rész-másodpercek is helyreállnak.
Ismeretlen verzió, hibás alak/típus/beállítás/idő vagy lehetetlen pontállás
csak az `activeMatch` kulcsot törli. Az előzményt ez az ág nem olvassa/írja.

A pontmeccs indításkor csatlakozik az `ActiveMatchSession` modulhoz;
mentés minden elfogadott pont/undo, szünet/folytatás, nézetelrejtés és
alkalmazásleállás után. Csak a csatlakoztatott nézet írhat mentést.
Eldobáskor előbb a modul hivatkozásai és az aktív mentés törlődnek;
a kilépés miatti `onHide` és a későbbi `onStop` nem hozza vissza a meccset.

Újraindításkor a SAVED MATCH nézet pontmódban a módot, A/B pontokat,
szabályt és X-et mutatja; a klasszikus ágon továbbra is szettállást.
START folytat, DOWN eldobja az aktív mentést. Aktív pontmeccs folytatása
szünetben indul, fagyasztott idővel és ponttiltással. START/RESUME vagy
BACK újraindítja a játékidőt. Lezárt WIN/LOSS/DRAW meccsnél közvetlenül
a fagyasztott eredmény áll helyre, további pont tiltott.

Az undo-napló újraindításkor üres, a klasszikus meccshez és az AM-1
specifikációjához igazodva; a folytatás utáni új pontok ismét
visszavonhatók, a húszpontos korláttal. A korábban lezárt pont egy külön
indítás után nem visszavonható. Új meccs megerősített eldobása visszatér
a megőrzött setupra; helyreállított meccsé a főmenübe lép, mert ott nincs
setup a nézetveremben. NO/BACK csak a megerősítést zárja, a mentést őrzi.

Kilenc új teszt ellenőrzi a nyolc mód/szabály/kezdőcsapat kombinációt,
a hibás és lehetetlen pontállásokat, az aliasmentes export/restore-t,
a rész-másodperceket és a leállás/szünet idejének kihagyását,
a WIN/LOSS/DRAW helyreállítását, a sérült mentés melletti érintetlen
előzményt, mindhárom régi klasszikus verziót, a valódi gombkezelő mentési
ágait, alkalmazásleállást és eldobás utáni újramentés tiltását.
FR265 és első Enduro (`--min-api 3.4.0`) profilon **94/94 teszt** és
optimalizált build sikeres. A dinamikus Storage-konténerekhez kapcsolódó
SDK-figyelmeztetések megmaradnak; fordítási hiba nincs.

A natív bejáró mindkét profilon nyolc külön meccset indított a tényleges
setup START ágon, fizikai `onKey` kezelővel 2–1-re pontozott, majd
alkalmazást újraindítva ellenőrizte a módot/szabályt/X-et/kezdő csapatot,
pontállást és 12 345 ms játékidőt. A tényleges recovery START ág szünetben
folytatott, UP/DOWN nem adott pontot; folytatás után új pont, undo,
megerősítés/cancel, eldobás és főmenübe visszalépés működött. A startup
DOWN/eldobás ág is ellenőrizve. A bejáró külön tesztalkalmazás-azonosítót
használ, siker után törli a saját aktív/előzmény/vezérlő tesztadatait.
Fejlesztői KeyEvent-helyettesítő miatt a héj `-l 0` fordítással fut;
a termék és az egységtesztek normál típusellenőrzéssel készültek.

A végleges vizuális bejárás 16-16 natív képernyőt rögzít: mindkét mód és
szabály, 9–7 és 998/999-es pontállás, helyreállított szünet/eredmény,
100 órás időformátum és YES/NO. A pontállás és a célérték kezdeti
FR265-es átfedése javítva; a klasszikus recovery elrendezése megmaradt.
Az Enduro mintanézetes bejárója 63,1–68,0 / 123,8 kB-t jelzett; ez
fejlesztői mintanézetes mérés. A FR265–Enduro profilváltás és a vizuális
bejáróról az egységtesztekre
váltás elakadt. Újraindításnál a virtuális KWin zárolási képernyője
a szimulátor tesztkapcsolatának felállását is blokkolta; a csak saját
virtuális munkamenetre vonatkozó `--no-lockscreen` indítással sikerült.
Az újrafuttatáshoz a `build/am5-review/start_without_lock.py` segéd
a meglévő indítót használja ezzel az egy opcióval; a felhasználói asztal
beállítását nem módosítja. Friss háttérpéldányból az ellenőrzés sikeres. Ez szimulátoros ellenőrzés,
nem valós órás vagy hosszú meccses/előzményes memóriakapu.

Képek, újrafuttatható bejáró és indítás/folytatás naplók a gitignored
`build/am5-review/` alatt. Végleges képek: `fr265-visual-contact.png`,
`enduro-visual-contact.png`. A `review.py <device>` a nyolc tényleges
újraindítási próbát, a `--visual-only` ág a vizuális mintanézeteket futtatja.
A szimulátoros egységtesztcsomag a helyi tesztadatokat módosítja.

Build-bizonyítékok (SDK 9.2.0, végleges forrás):

- `build/test-1.1.0-fr265-38kc_mh6/build-info.json`;
- `build/test-1.1.0-enduro-fyxwet8w/build-info.json`;
- `build/build-1.1.0-fr265-twapy__o/build-info.json`;
- `build/build-1.1.0-enduro-_f8bnohe/build-info.json`;

**Következő azonosító: AM-6**, saját meccs eredménye/előzménye és összesítő.
A pontmódok helyi történetbe mentése, korai SAVE & END és döntetlen
összesítése még nincs bekötve. A pontmódos FIT az AM-7 külön feladata.
Kiadási manifestek és verzió nem változtak. A korábbi munkafabeli
módosítások megmaradtak; commit/push, Store-kiadás és órára másolás nem
történt. S2-V2 és a D-kapuk nyitva maradnak; tesztóra nincs, ne keress
eszközt. A saját háttérszimulátor a munkamenet végén leállt.

## AM-4 – Előző checkpoint

**AM-4 lezárva, 2026-10-04.** Az AM-3 `PointMatchStartView` kezdőnézete
élő pontozásra bővült; a név és setup belépési pont megmaradt.
DOWN pontot ad MY TEAM/A-nak, UP OPPONENT/B-nek, közös 500 ms-os
védelemmel. BACK legfeljebb húsz pontból von vissza; a lezáró pont
visszavonása az eredményről is újranyit. A kezdő csapat változatlan
első adogatóadat; nincs automatikus szervablokk vagy fordulóváltás.
A pont- és undo-esemény, illetve a meccsvég rezgéses visszajelzést ad.

A `PointMatchSession` külön kezeli a bemenetvédelmet, szünetet és az aktív
játékidőt, kívülről kapott monoton milliszekundumokkal. START szüneteltet;
szünetben UP/DOWN a RESUME/DISCARD MATCH menüt mozgatja, pontot nem ad.
START a RESUME soron vagy BACK folytat. Az aktív játékidő szünetben és
lezárás után megáll. Eredményről undo után továbbmér, az eredményen
eltöltött idő nélkül; a rész-másodpercek a szünetek között megmaradnak.
A nézet látható, aktív állapotában másodperces frissítő fut; szünet,
meccsvég és elrejtés leállítja, folytatás/undo újraindítja.

Lezáráskor WIN/LOSS/DRAW, A/B pontállás, mód, szabály, X, kezdő csapat
és játékidő jelenik meg. UP/DOWN nem ad további pontot, BACK undo.
Az eredményen START, szünetben DISCARD MATCH külön megerősítést nyit,
NO alapértékkel. BACK vagy NO visszatér a szünethez/eredményhez; YES
eldobja a meccset és visszalép ugyanarra a setupra, megőrzött értékekkel
és kijelöléssel. Az érintést/swipe-ot a teljes meccsnézet elfogyasztja,
állapotváltoztatás nélkül. Élő meccsben BACK most undo, nem setupra lépés.

**AM-4-ben nincs pontmódos Storage/FIT/előzmény bekötés.** A meccs csak
memóriában él, az eldobás után nem található előzményben. Nincs SAVE
felirat vagy korai mentés ezen az ágon. A klasszikus Score/FIT/aktívmentés
ág megmaradt; tárolási sémák, kiadási manifestek és verzió nem módosultak.
A korábbi munkafabeli módosítások megmaradtak. Commit/push, Store-kiadás
és órára másolás nem történt. S2-V2 és a valós órás D-kapuk nyitottak;
tesztóra továbbra sincs, ne keress eszközt.

Hét új teszt ellenőrzi a nyolc mód/szabály/kezdőcsapat kombinációt,
500 ms-os határt, hibás pontbevitelt, szünet/eredmény idejének kihagyását,
döntetlent és másik győztessel újranyitást, ezerpontos sorozat húszpontos
undo-korlátját, fizikai gombkezelő ágakat, megerősítés/cancel-t és a
nézet időzítőjének életciklusát. A 280/416-as geometria és eredményfelirat
ellenőrzése a 998/999-es pontállást is bejárja. A végleges forrás FR265
és első Enduro (`--min-api 3.4.0`) profilon **85/85 teszt**, mindkét
optimalizált build sikeres. Az új termékkód és teszt nem ad új
fordítói figyelmeztetést; a meglévő dinamikus konténerfigyelmeztetések
megmaradtak.

A natív integrációs héj mindkét profilon a tényleges setup START,
pontozó `onKey`, szünet, megerősítés és `popView` ágat végigjárta mind
nyolc kombinációban: új 0–0, fagyasztott beállítások, DOWN/UP,
azonnali ismétlés kiszűrése, szünet és eredmény alatti ponttiltás,
fagyasztott idő, lezáró pont undo, megerősítés/cancel, eldobás és
visszatérés ugyanarra a setupra. A héj fejlesztői KeyEvent-helyettesítőt
használ, emiatt `-l 0` fordítással; a termék buildjei és tesztjei a
szokásos típusellenőrzéssel készültek. Ez nem fizikai órás próba.

A végleges felület 16-16 natív képernyőn ellenőrizve: 0–0, mindkét
szabály, 998–998, 999–998, 998–999, WIN/LOSS/DRAW, szünet,
eldobási YES/NO, újranyitott meccs és 100 órás időformátum. Az FR265
körmaszkba érő alsó súgósora feljebb igazítva és függőlegesen középre
zárva javult; a végleges feliratokon átfedés/levágás nincs.
Endurón a képernyőbejáró kb. 51,8–62,8 / 123,8 kB-t jelzett;
ez fejlesztői mintanézetes mérés, nem hosszú meccses/előzményes kapu.
Az első Enduro segéd túl sok mintapontot generált egy rajzoláson belül,
watchdogra futott; a mintakészítés százpontos, külön időzítőlépésekre
bontva sikeres. A termék pontozása eseményenként egy pontot kezel.
A bejáró nem ír Storage/FIT adatot; az egységtesztcsomag a szimulátor
helyi tesztadatait módosítja.

Képek, újrafuttatható bejáró és kombinációs naplók:
`build/am4-review/fr265-contact.png`, `enduro-contact.png`,
`fr265-flow.log`, `enduro-flow.log`. A végleges képekhez `review.py`
`--visual-only` ága, a teljes kombinációs próbához az alapág használható.

Build-bizonyítékok (SDK 9.2.0, a megőrzött munkafa alapján):

- `build/test-1.1.0-fr265-dxkpwkie/build-info.json`;
- `build/test-1.1.0-enduro-gwu5bwxw/build-info.json`;
- `build/build-1.1.0-fr265-7louzqy3/build-info.json`;
- `build/build-1.1.0-enduro-qlsqkvc_/build-info.json`;

**Következő azonosító: AM-5**, verziózott aktív pontmeccsmentés és
helyreállítás, régi klasszikus mentések olvashatóságával. A mentésnek a
módot, szabályt, X-et, kezdő csapatot, pontállást és játékidőt őriznie kell;
folytatás szüneteltetve induljon. A `PointMatchSession` jelenleg friss
idővel indul, és nem állít helyre pontokat/undo-t; ez az AM-5 belépési pont.
Az eredmény/előzmény az AM-6, FIT az AM-7 külön feladata.
A vizuális/test programváltás egyszer beragadt, az azonnali újraindítás
első próbája nem lett kész; friss háttérpéldányból a végleges 85/85 teszt
mindkét profilon sikeres. A munkamenet végén az általa indított
háttérszimulátor leállt.

## AM-3 – Előző checkpoint

**AM-3 lezárva, 2026-10-04.** A beállítás első sora `MODE`: CLASSIC,
AMERICANO vagy MEXICANO. A klasszikus mód hét szabálymezője megmaradt;
a pontmódokban a mód után `END AT`, `POINTS X` és `1ST SERVE` látszik.
Az `END AT` szerkesztő két választása `A + B = X` és `A = X OR B = X`;
a listán ezek `TOTAL X` / `TEAM X` rövidítést kapnak. X alapértéke 24,
egyesével léptethető 1–999 között, a széleken megáll. A 999 csak a felületi
számválasztó határa; a pontozási domain továbbra is pozitív Numbert fogad.
A kezdő csapat alapértéke A; A/B a MY TEAM/OPPONENT csapatot jelöli.

UP/DOWN választ vagy módosít, START szerkeszt/elfogad, BACK elveti a
szerkesztést. A szerkesztőn `START: SAVE` és `BACK: CANCEL` súgó látszik.
A módváltás elvetése az eredeti módot és mezőlistát állítja vissza;
a rejtett klasszikus és pontbeállítások megmaradnak a setup példányban.
A kezdő csapat közös beállítás. A főmenüből új setup továbbra is
alapértékekkel indul; külön tartós beállításmentés nincs.

A `MatchSetupState.createEngine()` minden indításkor új, független
`ScoringEngine` vagy `PointMatchEngine` példányt ad az elfogadott
beállításokból. A klasszikus indítás a meglévő Score/FIT/aktívmentés ágon
marad. Pontmódnál a `PointMatchStartView` 0–0-s kezdőképernyőn mutatja a
módot, szabályt, X-et és kezdő csapatot; BACK ugyanarra a beállításra tér
vissza. **Az új módokban ebben az egységben még nincs élő pontbevitel,
időmérés, aktív mentés, előzmény vagy FIT-rögzítés.** Ezek bekötése
AM-4…AM-7 feladata; a kezdőképernyő az AM-4 belépési pontja.

Öt új setup-teszt és a kiterjesztett 280/416 pixeles elrendezési tesztek
ellenőrzik a módváltást, mentést/elvetést, fizikai gombok kezelőágait,
1/17/18/999 célértékeket, navigációt és az indítás mind a nyolc
mód/szabály/kezdőcsapat kombinációját. A klasszikus setup-teszt az új
MODE sor miatt a SETS sort választja. A végleges forrás FR265 és első
Enduro (`--min-api 3.4.0`) profilon **78/78 teszt**, mindkét optimalizált
build sikeres. Az új kezdőnézet nem ad fordítói figyelmeztetést; a meglévő
dinamikus konténerhozzáférések ismert figyelmeztetései megmaradtak.

A natív szimulátoros vizuális kör profilonként 25 képernyőt rögzített:
mindhárom módválasztás, klasszikus és pontmódos lista, új szerkesztők,
999-es célérték és mindkét kezdő csapat a 0–0-s kezdőnézeten. Levágás
vagy átfedés nem látszott. Endurón a bejáró kb. 57,6 / 123,8 kB-t jelzett;
ez fejlesztői kezdőképernyős mérés, nem hosszú meccses memóriakapu.
A külön natív integrációs próba mindkét profilon a tényleges
`SetupInputDelegate` START és a kezdőnézet BACK ágát is bejárta mind a
nyolc kombinációval: friss 0–0, helyes rögzített szabályok, visszatérés
ugyanarra a setup nézetre, megőrzött értékek és kijelölés. Az UP még nem
ad pontot. A `build/am3-review/` bejárók fejlesztői célúak, nem írnak
Storage/FIT adatot; a teljes tesztcsomag a szimulátor tesztadatait módosítja.
Az integrációs héj fejlesztői KeyEvent-helyettesítőt használ és emiatt
`-l 0` típusellenőrzéssel fordul; a termék tesztjei és optimalizált buildjei
a szokásos típusellenőrzéssel készültek. Ez a próba a valódi
nézetváltást/gombkezelőket ellenőrzi, nem fizikai órás gombeseményt.
Képek: `build/am3-review/fr265-contact.png`, `enduro-contact.png`;
integrációs naplók: `fr265-flow.log`, `enduro-flow.log` ugyanitt.

Build-bizonyítékok (SDK 9.2.0, helyi munkapéldányból):

- `build/test-1.1.0-fr265-6th_6o64/build-info.json`;
- `build/test-1.1.0-enduro-ddncp6n8/build-info.json`;
- `build/build-1.1.0-fr265-40leffk9/build-info.json`;
- `build/build-1.1.0-enduro-er9ztff7/build-info.json`;

**Következő azonosító: AM-4**, élő sajátmeccs-pontozás: DOWN/UP, 500 ms-os
bemenetvédelem, undo, szünet/játékidő, eredményre lépés és a lezáró pont
visszavonása. A fenti kezdőnézetet ehhez kell továbbépíteni vagy kiváltani.
AM-5/AM-6/AM-7 tárolási, előzmény- és FIT-munkáját külön egység kezelje.

Korábbi munkafabeli módosítások megmaradtak. Verzió, klasszikus pontozási
domain, tárolási sémák és kiadási manifestek nem változtak. Commit/push,
Store-kiadás és órára másolás nem történt. Tesztóra továbbra sincs;
ne keress eszközt. S2-V2 és a D-kapuk nyitva maradnak. A munkamenet által
indított háttérszimulátor a végén leállt.

## AM-2 – Előző checkpoint

**AM-2 lezárva, 2026-10-04.** Az AM-1 jóváhagyott egymeccses szabályaira
elkészült a `source/domain/PointMatchEngine.mc`, külön a klasszikus
`ScoringEngine`-től. A domain az Americano/Mexicano módot, két lezárási
szabályt (A+B=X vagy A=X/B=X), pozitív egész X-et és kezdő adogató csapatot
őrzi. Egy pont egy csapat számlálóját növeli; a kezdő csapat pontelőnyt és
automatikus szervablokk-rendet nem ad.

Az eredmény saját csapathoz viszonyított `ACTIVE`, `WIN`, `LOSS` vagy
`DRAW`; a döntetlen befejezett meccs. Lezárás után nincs további pont.
A legutóbbi 20 pont visszavonható, a lezáró pont undo-ja újranyitja a meccset.
Az undo csak a pontot kapó csapatot tárolja, nem teljes állapotmásolatokat.
A beállítások gettereken át olvashatók, a pontállás védett másolat.
Hibás konstruktorbemenet `Lang.InvalidValueException`; hibás pont és üres
undo `false`, állapotváltozás nélkül.

Integrációs API: `new PointMatchEngine(mode, endRule, target,
startingServerTeam)`, `awardPoint(team)`, `undoLastPoint()`, `getPoints()`,
`isComplete()`, `getResult()`, valamint `getMode()`, `getEndRule()`,
`getTarget()` és `getStartingServerTeam()`. A mód/szabály modulok:
`PointMatchMode`, `PointMatchEndRule`, `PointMatchResult`. A/B = 0/1.
X a meglévő alkalmazás számtípusához igazodó pozitív `Lang.Number`;
nincs 16/24/32-re vagy más önkényes értékre szűkítve. Az AM-3 választó
alapértékei és használható felső határa továbbra is AM-3 megvalósítási részlet.

A `source/tests/PointMatchEngineTests.mc` 11 új tesztje mindkét módot,
szabályt és kezdő csapatot bejárja: határ előtti/utáni állapot, döntetlen,
lezáró pont undo és másik győztes, X=1/7/17/18/24, új meccs, hibás
beállítás/pont, védett pontállás, független meccsek, valamint 1001 pontos
sorozat és pontosan 20 visszavonás. A teljes csomag FR265 és első generációs
Enduro (`--min-api 3.4.0`) profilon **73/73 teszt**, mindkét optimalizált
normál build sikeres. Az új domain nem adott fordítói figyelmeztetést;
a meglévő dinamikus konténerhozzáférések ismert figyelmeztetései megmaradtak.

Build-bizonyítékok (SDK 9.2.0, helyi munkapéldányból):

- `build/test-1.1.0-fr265-3fhpau3f/build-info.json`;
- `build/test-1.1.0-enduro-3rgz3fpg/build-info.json`;
- `build/build-1.1.0-fr265-_6n_uvwa/build-info.json`;
- `build/build-1.1.0-enduro-g54bvr_e/build-info.json`.

**Következő azonosító: AM-3**, módválasztás és meccsbeállítás. A klasszikus /
Americano / Mexicano mód, a két lezárási szabály, egyesével állítható X és
kezdő csapat felületét kell elkészíteni, BACK/cancel megőrzéssel, FR265 és
Enduro elrendezésben. AM-4-ben következik az élő pontozás; AM-5/AM-6-ban
az aktív mentés, eredmény és előzmény. Egy munkamenet egy azonosítót kezel.

Ebben az AM-2 egységben két új forrás és hat dokumentum változott. UI,
tárolás, FIT, klasszikus pontozás és release manifest nem módosult;
a korábbi statisztikai UI-/tesztmódosítások megmaradtak. Új vizuális kör
nem szükséges, mert nincs új UI. Commit és push nem történt.

Tesztóra nincs csatlakoztatva; ne keress eszközt. Az S2-V2 és a D-kapuk
nyitottak; az órán lévő béta nem frissült.

## 2026-10-04 – Összesített és egyedi meccsstatisztika megkülönböztetése

A bétatesztelői visszajelzés szerint az előzménylistán hosszan nyomott UP
hatókörét nem lehetett egyértelműen felismerni. A meglévő funkció az összes
helyben tárolt, legfeljebb 20 meccset összesíti; nem napi statisztika.

A lista új súgója `HOLD UP: ALL STATS`, és az összesítő mind a négy lapján
`ALL SAVED MATCHES` jelölés látható. A kiválasztott meccs részletezője az
eredmény- és szettlapok után két új UP/DOWN-lapozható oldalt tartalmaz:
`MATCH SET STATS` (megnyert/vesztett szettek, arány, meccsidő), valamint
`MATCH POINTS` (megnyert/vesztett pontok, pontnyerési arány). A két nézet
közös statisztikai számítást és rajzolást használ. Régi, pontadat nélküli
rekordnál `--` és `NO POINT DATA` jelenik meg; egy új, nulla ponttal mentett
meccs továbbra is valódi `0–0`, meghatározatlan aránnyal.

FR265 és első generációs Enduro (`--min-api 3.4.0`) profilon **62/62 teszt**
sikeres, és az optimalizált PRG-k lefordultak. Az új teszt a meccslapok
értékeit, körbelapozását, a hiányzó és nulla pontadat különbségét, valamint
az összesítő minden lapjának hatókörjelölését ellenőrzi. A 280/416 pixeles
rajzolásihatár-tesztek a régi és új rekordok új lapjait is bejárják.

Az összesítő és az egyedi meccs új statisztikalapjainak natív megjelenését
FR265 és Enduro skinen is ellenőriztük. Az FR265 bejárás a hosszabb
history-súgó körmaszkba érő szélét megtalálta; a súgó feljebb igazítva,
függőlegesen középre zárva javítva. Az Enduro bejáráson minden új felirat
olvasható, átfedés nincs; memóriahasználat a képeken kb. 59 kB / 123,8 kB.
A kizárólag fejlesztői, tárhelyet nem módosító képernyőbejáró és a képek a
gitignored `build/history-scope-review/` alatt vannak. Ez a vizuális kör
nem helyettesíti az `S2-V2` valós órás pontsorozatát és gombos próbáját.

Build-bizonyítékok:

- `build/test-1.1.0-fr265-i98qtj57/build-info.json`;
- `build/test-1.1.0-enduro-r7mv825p/build-info.json`;
- `build/build-1.1.0-fr265-cky3ejn3/build-info.json`;
- `build/build-1.1.0-enduro-opy6skh3/build-info.json`.

Ez helyi fejlesztői módosítás; az órára korábban másolt béta PRG nem
frissült. A rekordformátum és a kiadási manifest változatlan. A következő
órás feladat továbbra is `S2-V2`, az új lapok vizuális és gombos
ellenőrzésével együtt.

## Statisztikai checkpointok és az órás folytatás

Az első **meccstörténet és statisztika checkpoint lezárult**, a második
pontstatisztikai checkpoint implementálva, automatikusan ellenőrizve, és a
vegyes rekordos natív szimulátoros bejárása (`S2-V1`) is kész. A valós órás
pontstatisztikai próba (`S2-V2`) és a készüléktámogatás valós órás
release-kapuja továbbra is nyitott.

Az első checkpoint mutatói: összes/befejezett/félbehagyott meccs,
győzelem–vereség és arány, szettgyőzelem–szettvereség és arány, valamint
teljes/átlagos játékidő. Új perzisztens formátum nincs; a számítás a meglévő
legfeljebb 20 rekordból történik, a régi rekordokkal együtt.

A második checkpoint megtartja a 20 rekordos gördülő korlátot, és az újonnan
indított meccsekhez megnyert–elvesztett pontot tárol. A négylapos összesítő
pontlapja ezek összegét, a pontnyerési arányt és a pontadattal rendelkező
meccsek számát mutatja. A régi előzmények olvashatók, de pontadat hiányában
nem kerülnek a pontarány nevezőjébe.

A 2026-09-24-i ellenőrzésen FR265 és Enduro profilon 61/61 teszt,
optimalizált build és üres előzményes
natív pontlap-bejárás sikeres. Az FR265 bejárás során talált címke/érték
átfedéseket a `POINT MATCHES` és `POINT RATE` rövidítések javították. Régi és
vegyes rekorddal a natív vizuális ismétlés 2026-09-25-én lezárult.

Új munkamenet elején olvasd el ezt a fájlt és a
[készüléklistát](supported-devices.md), majd ellenőrizd a `git status` és
`git log -1` eredményét. A már lezárt Enduro-szimulátoros kört ne kezdd újra,
hacsak az érintett UI-kód nem változik.

A hátralévő munka kis kontextusú, egyenként indítható egységei:
[következő munkamenetek](next-work-units.md). A pontos következő órás egység
`S2-V2`, ha FR265 vagy cél-Enduro tesztóra rendelkezésre áll. Tesztóra
hiányában az AM-4 lezárása után AM-5 következik. Egy
munkamenetben ne vonj össze több azonosítót.

Az `S2-V2` valós órás próbához a
[részletes mérési lap](s2-v2-real-watch-point-test.md) elkészült: rövid
félbehagyott meccs undo-val és újraindítással, majd 6–0-s lezárt meccs,
végül a félbehagyott rekord törlése. 2026-09-25-én a felhasználó FR265 órát
csatlakoztatott. A külön béta alkalmazásazonosítójú, aktuális 1.1.0 tesztbuild
elkészült és USB/MTP-n az óra `GARMIN/Apps` mappájába került. A PRG-t
visszaolvastuk; SHA-256 egyezett. A pontos azonosítók a mérési lapon vannak.
A felhasználó az órán ellenőrizte az alkalmazás indulását és alapműködését;
ez sikeres. A pontos `S2-V2` pontsorozatot, újraindítást és törlést még nem
járta végig, így az elfogadási értékek nyitottak. A következő órás
azonosító továbbra is `S2-V2`.

Az FR265 béta alkalmazás kiinduló, meccs nélküli állapotában a felhasználó
`MATCHES 0`, `POINT MATCHES 0` és pont W–L `0–0` értéket olvasott le.
2026-09-25-én idő hiányában a részletes órás tesztet nem végezte el;
akkor a munkamenet lezárását, commitot és push-t kérte. Ha később van
tesztóra, a béta frissítése után az `S2-V2` mérési lap
**1. Félbehagyott meccs: 3–1 pont** szakaszával folytasd. A 24–0-s lezárt meccs és a törlési próba ezután következik.
Az `S2-V2` sikerét csak a tényleges kijelzett értékek birtokában rögzítsd.

## 2026-09-25 – S2-V1 lezárva

A kizárólag fejlesztői célú, induláskor betöltött előzmény három rekordból
állt: egy v1 vereség (120 s), egy v2 félbehagyott meccs (180 s) és egy v3
győzelem (300 s, 80–70 pont). Az FR265 és az eredeti Enduro natív
szimulátorskinjén az előzménylistáról hosszan nyomott UP megnyitotta az
összesítőt. Mind a négy lapot, a DOWN és UP körbelapozást, valamint a BACK
visszalépést képernyőképpel ellenőriztük.

Mindkét profilon azonos, helyes értékek jelentek meg: 3 meccs, 2 befejezett,
1 félbehagyott; 1–1 meccs, 50%; 3–2 szett, 60%; 10m teljes és 3m átlagos
idő; 80–70 pont, 53% és `POINT MATCHES 1`. A pontarány nevezőjébe csak a v3
rekord került. Szövegátfedést vagy körmaszk miatti levágást a 416 × 416 és
280 × 280 pixeles natív nézeten nem láttunk. Az Enduro legnagyobb kijelzett
memóriahasználata ezen a bejáráson 55,1 / 123,8 kB volt.

A képek: `build/s2-v1-review/fr265-all-pages.png`,
`build/s2-v1-review/enduro-all-pages.png`, valamint a könyvtárban a
körbelapozás és BACK egyedi képei. A vegyes előzményt csak a két helyi
ellenőrző PRG-be tett ideiglenes indítási tesztadat állította elő; a forrás
és a szimulátor beállítása visszaállt, a létrehozott átmeneti appadatok
törölve. A pontos rekordhármas a
`ScoringEngineTests.mc` `historyStatisticsSummarizeCompletedStoppedAndLegacyRecords`
tesztjében van; megismétléskor ezt kizárólag fejlesztői buildben kell a
`matchHistory` kulcsra betölteni. Termékkód, rekordformátum, 20-as korlát és
release manifest nem változott. A korábbi 61/61 automatikus tesztet nem
ismételtük, mert a visszaállított termékkód változatlan.

Az első Enduro-váltáskor a szimulátor beragadt; friss példányból a natív
bejárás sikerült. A következő azonosító `S2-V2`, valós tesztórával.

## Felhasználói döntések és sorrend

Az **éles 1.1.0 használatban van**. A felhasználó működési hibát vagy zavaró
viselkedést nem tapasztalt, saját használatra teljesen megfelelőnek találja.
A részletes FIT-/Garmin Connect- és akkumulátormérési eredmények nincsenek
dokumentálva. Az éles használat ténye nem azonos a Store publikációs
állapotának ellenőrzésével.

Jóváhagyott fejlesztési sorrend:

1. További Garmin órák támogatása, **Enduro / Enduro 2 / Enduro 3** is.
2. Meccstörténet és statisztikák.
3. Americano / Mexicano játékmód.
4. **Instinct 2 támogatása**, külön monokróm grafikai adaptációval.
5. Saját szinkron és webes felület.

Az Instinct 2-t a felhasználó kifejezetten a saját weboldal elé, külön
negyedik feladatként helyezte. Annak 176-os monokróm UI-fejlesztése még nem
indult el. A többi funkcióbővítés részletes specifikációja későbbi feladat.

## Repository-állapot és meglévő implementáció

A 2026-09-24-i lezárás indulásakor a munkafa tiszta volt, a HEAD és az
`origin/master` egyaránt:

`9f7e3e4` – „további eszköz specifikus fejlesztések, statisztika bővítés elkezdése”.

A commit tartalmazza a statisztikai domainmodult, a háromlapos nézetet és
delegáltját, az előzménylistás belépést, a két új számítási tesztet, az
elrendezési bejárást és az addigi dokumentációt. A korábbi képek és helyi
segédek a gitignored `build/ui-review-2026-09-17/` könyvtárban vannak.

Meglévő implementáció:

- `source/ui/PadelTheme.mc`: `PadelTheme.canvas()` és `PadelScaledCanvas`.
  Kizárólag 280 × 280-as DC esetén skálázza a 416-os terv koordinátáit;
  köztes teljes képernyős bitmap nincs.
- A hat `*View.mc` a közös adaptert használja. A 416-as felületek közvetlenül
  a natív DC-t kapják vissza, a betűméret natív rendszerbetű marad.
- `source/ui/SetupView.mc`: a számérték-szerkesztő ASCII `-` jelet használ,
  mert a natív Enduro fontból hiányzott a korábbi Unicode mínusz.
- `source/domain/MatchHistoryStatistics.mc`: a helyi rekordokból számolt
  meccs-, szett-, idő- és pontösszesítés, külön összesítő-perzisztencia nélkül.
- `source/ui/MatchHistoryStatsView.mc`: négylapos összesítő; az
  előzménylistáról MENU / hosszan nyomott UP nyitja meg.
- `source/tests/DisplayLayoutTests.mc`: négy elrendezési és egy
  statisztikai feliratteszt; az előzményteszt a négy összesítőlapot és
  az egyedi meccslapokat is bejárja. A segédek `:debug` jelölésűek.
- A teljes csomag jelenleg **85 tesztes**; a pontszámlálás/undo, a régi
  aktív mentés
  hiányos pontadatának kizárása, a 20 rekordos korlát és a hibás v3 pontadat
  szűrése külön tesztet kapott.
- `scripts/dev.py`: normál build, egységteszt, béta- és produkciós export,
  `--device`, kísérleti készülékekhez `--min-api`, naplók és SHA-256
  build-jegyzőkönyv. A kiadási manifestek továbbra is csak FR265-re szólnak.

## Korábbi automatikus ellenőrzés

Connect IQ SDK / compiler: **9.2.0**.

| Készülék | Profil | API-minimum a tesztben | Eredmény |
|---|---|---|---|
| Enduro | `enduro` | `3.4.0`, kísérleti manifest | 55/55 teszt, normál PRG lefordult |
| Enduro 2 | `fenix7x` | `4.1.6` | 55/55 teszt, normál PRG lefordult |
| Enduro 3 | `enduro3` | `4.1.6` | 55/55 teszt, normál PRG lefordult |
| Forerunner 265 | `fr265` | `4.1.6` | 55/55 teszt, normál PRG lefordult |

Ezek a 2026-09-14-i eredmények. A 2026-09-17-i munkamenetben nem futottak
újra, mert termékkód nem változott. A fordító korábban ismert, dinamikus
konténerhozzáféréshez kapcsolódó típusellenőrzési figyelmeztetéseket adott.

A hat további AMOLED-jelöltön 2026-09-18-án készülékenként 55/55 teszt
futott le, normál optimalizált PRG is készült, és lezárult a natív
UI-/gombos bejárás. Részletek: [készüléklista](supported-devices.md).

## 2026-09-24-én lezárt statisztikai checkpoint

Az FR265 és az első generációs Enduro profilon tiszta `9f7e3e4` commitból
**57/57 teszt** sikeres, és mindkettőhöz elkészült az optimalizált normál
build. Az Enduro futás `3.4.0` API-minimumú kísérleti manifestet használt; a
régi 128 KiB-os profilon a tesztalkalmazás is végigfutott. A fordító csak a
korábbról ismert, dinamikus konténertípusokra vonatkozó figyelmeztetéseket
adta. Az első Enduro-próba a szimulátor készülékváltásakor időtúllépett,
teszteket nem indított; friss szimulátorból az ismétlés hibátlanul lefutott.

Ellenőrzött új esetek: üres lista; új, régi és félbehagyott rekordok vegyes
összesítése; győzelmi és szettarány; átlagidő; valamint a három új lap
rajzolási határa 416 × 416 és 280 × 280 képponton. Natív FR265 és Enduro
szimulátorskin alatt üres és vegyes előzménnyel működött a MENU / hosszan
nyomott UP megnyitás, az UP/DOWN lapozás és a BACK. A bejárás két valódi
elrendezési hibát talált és javított: a 280 pixeles időcímke/érték átfedését,
valamint az FR265 `SET WIN RATE` / `100%` összeérését. A nulla nevezős
arányok explicit `--` értéket kapnak. Valós órás ismétlés teszteszköz
hiányában továbbra is nyitott.

## 2026-09-17-i natív szimulátoros eredmények

### Enduro – teljes bejárás

A natív Enduro 3.4.2 skin alatt a tényleges állapotot minden fontos lépésnél
képernyőképpel ellenőriztük:

- főmenü és minden beállítási sor/szerkesztő;
- az ASCII mínusz, valamint a hosszú `NO-AD`, `MATCH TIE-BREAK`, `TIE-BREAK`
  és `WIN BY TWO` feliratok;
- élő pontozás mindkét csapatnak, undo, szünet;
- a szervaválasztó mind a négy negyede és a kiválasztás visszaírása;
- mentés/befejezés és eldobás: YES, NO és BACK ágak;
- teljes, 6–0 6–0-s mérkőzés összegzése, szettlapjai, összegzésről undo,
  újrabefejezés és mentés;
- előzménylista, meccs- és szettrészlet, törlés és üres lista;
- aktív meccs újraindítás utáni visszaállítása: folytatás szüneteltetve,
  megőrzött 30–0 állás, majd külön újraindításból eldobás.

A feliratok olvashatók, nem lógnak ki a körmaszkból, az MIP-színek
elkülönülnek. A szervaválasztó szándékosan szín- és negyed-alapú, szöveges
címkét nem használ.

Kiemelt bizonyítékok a gitignored mappában:

- `build/ui-review-2026-09-17/setup-sequence-1.png`
- `build/ui-review-2026-09-17/setup-sequence-2.png`
- `build/ui-review-2026-09-17/setup-sequence-3.png`
- `build/ui-review-2026-09-17/live-pause-sequence.png`
- `build/ui-review-2026-09-17/pause-server-sequence.png`
- `build/ui-review-2026-09-17/pause-confirm-sequence.png`
- `build/ui-review-2026-09-17/summary-sequence.png`
- `build/ui-review-2026-09-17/history-sequence.png`
- helyreállítás: `71-recovery-screen.png`, `75-recovery-continued-paused.png`,
  `76-recovery-resumed-live.png`, `77-home-after-recovery-discard.png`.

A `69`, `70`, `72` és `73` kezdetű köztes képek fókuszálási próbák, ne
használd őket bizonyítékként.

### Enduro 2 és Enduro 3

Az Enduro 2 az SDK közös `fenix7x` profilján, az Enduro 3 az `enduro3`
profilon futott. Mindkettőn ellenőriztük a főmenüt, a beállítási listát,
az ASCII mínuszt, a hosszú `MATCH TIE-BREAK` választót, az élő pontozást,
a szünetet és az eldobási megerősítést. A natív fontok, a MIP-kontraszt és
a körmaszk rendben volt; levágást nem láttunk.

- Enduro 2 élő képernyő: **42,1 / 763,6 kB**.
- Enduro 3 élő/szünet képernyő: **42,2 / 763,6 kB**.
- Contact sheet: `build/ui-review-2026-09-17/enduro2-sequence.png` és
  `build/ui-review-2026-09-17/enduro3-sequence.png`.

### 128 KiB-os Enduro memória- és undo-terhelés

Az induló főmenü **48,1 / 123,8 kB**, a friss élő meccs **52,0 / 123,8 kB**
értéket mutatott. Advantage pontozásban felváltott A/B bemenetekkel 220
pontbeviteli eseményt küldtünk. A 200-as sorozatból egy esemény láthatóan
a bemenetvédelmi ablakba esett, ezért további 20 esemény adott biztonsági
tartalékot a 200+ rögzített pont eléréséhez.

- 200 esemény után: **61,1 / 123,8 kB**; nem volt összeomlás vagy
  állapotromlás.
- További 20 esemény, majd tíz undo után: **56,6 / 123,8 kB**; az undo
  végig működött.
- A hosszú meccs `SAVE & END` művelete sikerült. A megállított előzmény
  `MATCH STOPPED`, `0-0 GAMES • 40-AD` és `SET 1 STOPPED` állapotai helyesen
  jelentek meg; a tesztrekordot ezután töröltük.
- Contact sheet: `build/ui-review-2026-09-17/enduro-stress-sequence.png`.

Egy korábban befejezett 6–0 6–0 mérkőzés összegzőjén a kijelzett maximum
**61,3 / 123,8 kB** volt. A mérés szimulátoros, nem helyettesít valós órás
memória- vagy akkumulátortesztet.

## 2026-09-18-i AMOLED szimulátoros eredmények

Az `epix2`, `d2mach1`, `epix2pro47mm`, `fenix843mm`, `fenixe` és
`instinct3amoled50mm` profilokon készülékenként **55/55 teszt** és normál
optimalizált build sikerült.

Mindegyiken natív skinnel és fizikai gombpontokkal ellenőriztük a főmenüt,
az összes beállítási sort és szerkesztőt, a hosszú `MATCH TIE-BREAK`
feliratot, a számérték-szerkesztő ASCII mínuszát, mindkét csapat pontgombját,
az undo, szünet, szervaválasztás, SAVE & END és DISCARD MATCH ágakat. Az
érintés nélküli `instinct3amoled50mm` teljes mintája kizárólag a skin fizikai
gombjaival is működött. Natív font-, körmaszk- vagy kontraszthibát, levágást
és összeomlást nem láttunk.

Az `epix2` mély bejárása ezen felül tartalmazta:

- egy 6–0-s teljes meccs összegzését, szettlapját, összegzésről undo-t,
  újrabefejezést és mentést;
- előzménylistát, meccs- és szettrészletet, NO/YES törlési ágakat és üres
  előzményt;
- aktív 15–0-s meccs újraindítás utáni helyreállítását, szüneteltetett
  folytatását és külön újraindítás utáni eldobását.

Kiemelt contact sheetek:

- `build/ui-review-2026-09-17/amoled/epix2-setup-a-contact.png`
- `build/ui-review-2026-09-17/amoled/epix2-live-pause-contact.png`
- `build/ui-review-2026-09-17/amoled/epix2-summary-contact.png`
- `build/ui-review-2026-09-17/amoled/epix2-history-contact.png`
- `build/ui-review-2026-09-17/amoled/epix2-recovery-evidence.png`
- `build/ui-review-2026-09-17/amoled/d2mach1-actions-contact.png`
- `build/ui-review-2026-09-17/amoled/epix2pro47mm-contact.png`
- `build/ui-review-2026-09-17/amoled/fenix843mm-contact.png`
- `build/ui-review-2026-09-17/amoled/fenixe-contact.png`
- `build/ui-review-2026-09-17/amoled/instinct3amoled50mm-contact.png`

Az `epix2` köztes `61`, `65`–`67` és `70` képei betöltési/időzítési próbák;
a helyreállítás bizonyítékaként a `62`–`64`, `68` és `69` képeket használd.

## Következő konkrét munkalépések

1. `AM-3`: készítsd el a módválasztást, valamint az új módok lezárási
   szabályának, X-ének és kezdő csapatának beállítását. Használd az AM-2
   ellenőrzött domainjét; élő pontozási és tárolási integráció később.
2. `S2-V2`: ha később van tesztóra, az aktuális béta telepítése után
   ellenőrizd a valós pontösszesítést és az új statisztikalapokat.
3. A készülékteszteket modellenként külön `D-<device-id>` egységben végezd;
   csak sikeres valós órás kapu után bővíts release manifestet.

A részletes inputok, korlátok és elfogadási feltételek a
[kis kontextusú feladatbontásban](next-work-units.md) vannak; mindig csak egy
azonosítót indíts.

## Parancsok és helyi bizonyítékok

### Háttérszimulátor a 2026-09-25-i munkamenettől

A helyi KDE gépen az automatizált Connect IQ tesztekhez a
`scripts/simulator_bg.py` külön virtuális KWin/Xwayland kijelzőn indítja a
szimulátort. Az ablak nem kerül a munkasztalra, a `PULSE_SERVER` csak a
szimulátornál elérhetetlen címet kap, így nincs új szimulátoros hangfolyam.
A `start`, `status`, `stop` parancsok a gitignored `build/simulator-bg/`
állapotfájlt és naplókat használják. `start` után a `scripts/dev.py test`
változatlanul használható. Az Enduro profil 61/61 tesztje így sikerült; a
gazdaasztal aktív ablaka a futás alatt nem változott, a hangfolyamok között
csak a Chrome szerepelt. Natív képernyőképhez látható szimulátor szükséges.

A helyi SDK-t a Garmin SDK Manager konfigurációja jelöli; a `scripts/dev.py`
a gitignored `docs/developer_key` fájlt használja. A kulcsot ne olvasd ki és
ne tedd közzé.

```bash
CIQ_SDK_DIR="$(cat "$HOME/.Garmin/ConnectIQ/current-sdk.cfg")"
"$CIQ_SDK_DIR/bin/connectiq"
python3 scripts/dev.py test --device epix2
python3 scripts/dev.py build --device epix2
```

A tesztek egy közös szimulátort használnak, ezért ne indíts párhuzamos
futásokat. A `monkeydo` sikeres tesztcsomagnál is adhat 1-es kilépési kódot;
a fejlesztői script a végső `PASSED` összesítést is vizsgálja.

A 2026-09-17-i UI-bejárásnál a Wayland-kompozitor natív EIS bemenetét
használtuk. A helyi, gitignored segédek:

- `build/ui-review-2026-09-17/eis_click.py`
- `build/ui-review-2026-09-17/activate-ciq.js`
- `build/ui-review-2026-09-17/inspect-ciq.js`

Ezek gép-, ablakpozíció- és skinfüggő diagnosztikai segédek, nem termékkódok;
új környezetben a koordinátákat újra kell kalibrálni. A `build/` teljesen
gitignored, másik gépen a bizonyítékok és binárisok újra előállítandók.

A bejárt PRG-k:

- `build/build-1.1.0-enduro-75jlfi_c/padel-pilot-1.1.0-enduro.prg`
  — 49 868 bájt,
  `a3f6b1b04e3daad9d175ee4bccb3f1d35119592f1d3f1c37e83fbff1311b19bc`;
- `build/build-1.1.0-fenix7x-olqpt_8p/padel-pilot-1.1.0-fenix7x.prg`
  — 39 980 bájt,
  `de8cd11b5bc914eff17f945ea2c1cc0a88035bc184dace5ad4bfb265c333c4e2`;
- `build/build-1.1.0-enduro3-2k2yc79p/padel-pilot-1.1.0-enduro3.prg`
  — 39 980 bájt, ugyanazzal a SHA-256 azonosítóval.

AMOLED PRG-k: az `epix2`, `d2mach1`, `epix2pro47mm`, `fenix843mm` és
`fenixe` buildje 45 740 bájtos, SHA-256:
`fb595f6236f05beada8597edfe984bf52f86f80500ef7c5626641943004937a6`.
Az `instinct3amoled50mm` buildje 45 260 bájtos, SHA-256:
`0e5dd1b3472500e828edd6021df44efdf34b84a0f805a19f8a6c0d24ab9920cd`.
Az egyedi build- és tesztjegyzőkönyvek a megfelelő, 2026-09-18-án létrejött
`build/build-1.1.0-<device>-*` és `build/test-1.1.0-<device>-*`
könyvtárakban vannak.

Az `1.1.0` verziószám változatlan; új Store-kiadás ebben a munkamenetben
nem történt.

A második checkpoint jelenlegi munkafából készült ellenőrzései:

- FR265: `build/test-1.1.0-fr265-srxsolfx` – 61/61;
  `build/build-1.1.0-fr265-q6du_ayf` – 49 436 bájt, SHA-256
  `3f4498270aee0c70e69f6dcd8b1f10c58dacb92d191ee48f10f03b2ae406d949`.
- Enduro: `build/test-1.1.0-enduro-wa6a9g03` – 61/61;
  `build/build-1.1.0-enduro-tdx2w90n` – 54 396 bájt, SHA-256
  `e088f5352d0af692e17d51d65b187198cc3e71a1c0b6cd8054d40000e1478972`.

A lezáró, tiszta `9f7e3e4` futások:

- FR265: `build/test-1.1.0-fr265-0ego__3a` – 57/57;
  `build/build-1.1.0-fr265-8yepxtke` – 48 348 bájt, SHA-256
  `579713ef6bf9dd8d7161d886258ed755598167474c85d5bce065f85618dae3f0`.
- Enduro: `build/test-1.1.0-enduro-bo3u0sky` – 57/57;
  `build/build-1.1.0-enduro-q3ggb7f5` – 52 892 bájt, SHA-256
  `3bdf9303981e1146278a0a98d7dc3012466b94b164555220f9296c0b70ceb89a`.
