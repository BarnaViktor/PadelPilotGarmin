# Padel Pilot

Garmin Connect IQ óraalkalmazás, amely a kiválasztott szabályok alapján
végigvezeti és rögzíti egy padelmérkőzés eredményét.

## Jelenlegi állapot

Verzió: **1.3.0**, produkciós kiadási csomag (2026-10-07).
Az 1.2.0 óta elkészült az Americano/Mexicano lezárt és félbehagyott
előzménye, döntetlenstatisztikája és Garmin FIT-integrációja, valamint
javult a módválasztó UP/DOWN iránya. A főmenü a VERSION fájlból származó
verziót mutatja.

Kiadási fájl és telepítési tudnivalók:
[1.3.0 kiadási jegyzet](docs/releases/1.3.0.md),
[Store ellenőrzőlista](store/release-checklist.md).
A helyi produkciós export elkészülte nem jelent Store-publikálást;
a valós órás FIT/Connect és készülékkapuk külön nyitottak.

Az Americano/Mexicano eredményéről START nyitja a SAVE MATCH / DISCARD MATCH
menüt; szünetben RESUME / SAVE & END / DISCARD MATCH választható.
A közös előzmény legfeljebb 20 meccset őriz. A döntetlen befejezett meccs,
külön DRAWS mutatóval. A pontmódok pont- és időadatot adnak az összesítőhöz,
a szettstatisztikát csak a klasszikus meccsek növelik.
A FIT utáni előzményhibát újraindításból is új felvétel nélkül lehet befejezni.
Részletek: [FIT-adatszerződés](docs/am7-fit-contract.md).

A kiadások közös helye a `dist/releases/`, verziónként külön mappával.
Az `1.1.0/` és `1.2.0/` megőrzi a korábbi csomagokat;
az `1.3.0/` a jelenlegi IQ-t és ellenőrzési jegyzőkönyveit tartalmazza.

A kiadás funkciói:

- készülékfüggetlen pontozási motor;
- Forerunner 265, tesztelt AMOLED modellek és Enduro 1/2/3 támogatása;
- gombvezérelt meccsbeállító képernyő;
- hagyományos advantage és no-ad / aranypont;
- 1, 3 vagy 5 szettes mérkőzés;
- normál szettek 6–6-os tie-breakkel;
- döntő teljes szett vagy match tie-break;
- beállítható tie-break célpontszám;
- kétpontos különbség;
- kezdő adogató csapat;
- szerváló csapat és csapaton belüli szerváló sorszám követése;
- pontos idő kijelzése játék közben;
- utolsó pont visszavonása;
- legfeljebb 20 pontnyi, memóriában korlátozott undo-előzmény;
- pont-, game-, szett- és meccsvégi rezgéses visszajelzés;
- aktív meccs automatikus helyi mentése és alkalmazás-újraindítás utáni
  folytatása;
- legfeljebb 20 lezárt vagy félbehagyva mentett meccset mutató, egyenként
  törölhető helyi előzmény;
- sérült aktív mentések és előzményrekordok biztonságos kiszűrése;
- Garmin FIT-aktivitás `racket/padel` besorolással;
- GPS-nyomvonal, megtett távolság, valamint aktuális, átlagos és maximális
  sebesség rögzítése;
- aktuális, átlagos és maximális pulzus, Garmin által számított kalória és
  aktivitásidő rögzítése, amikor ezek az adatok elérhetők;
- pontesemények, szetteredmények és győztes egyedi FIT-mezőkben;
- 116 Monkey C teszt a klasszikus és pontmódos domainre, beállításokra,
  mentésre, előzményre, aktivitásrögzítésre és a 280/416 pixeles elrendezésekre.

Az Americano/Mexicano egy saját meccset pontoz, ment és helyreállít,
helyi előzménnyel és FIT-aktivitással. Nem kezel versenysorsolást,
partnerváltást vagy rangsort.
A hőtérkép és a saját szerveres szinkron későbbi bővítés.

## Projektstruktúra

```text
garmin-padel/
├── docs/                       termék- és fejlesztési döntések
├── resources/                  Connect IQ erőforrások
├── source/
│   ├── domain/                 készülékfüggetlen pontozási logika
│   ├── tests/                  Monkey C egységtesztek
│   └── ui/                     Garmin-specifikus nézet és gombkezelés
├── manifest.xml
└── monkey.jungle
```

## Fejlesztői környezet

Szükséges:

1. Visual Studio Code;
2. Garmin Connect IQ bővítmény;
3. Connect IQ SDK Managerrel telepített aktuális SDK;
4. Garmin developer key a fordításhoz.

A fejlesztés alapértelmezett célkészüléke a Forerunner 265 (`fr265`),
az 1.3.0 kiadási csomag a [támogatott készülékek](docs/supported-devices.md)
listájában szereplő további kilenc SDK-profilt is tartalmazza. A Garmin
kompatibilitási táblája szerint a Forerunner 265 Connect IQ API level 5.2
eszköz, 416 x 416 pixeles kerek AMOLED kijelzővel. Részletek:
[docs/forerunner-265-target.md](docs/forerunner-265-target.md).

## Fordítás és automatikus ellenőrzés

A `scripts/dev.py` Python 3-mal fut, külön Python-csomag nem szükséges.
Linuxon automatikusan beolvassa a Garmin SDK Manager aktív SDK-ját, és
alapértelmezetten a helyi `docs/developer_key` aláírókulcsot használja.
Más elérési út a `CIQ_SDK_DIR` és `CIQ_DEVELOPER_KEY` környezeti változóval,
illetve a `--sdk` és `--key` argumentummal adható meg.

```bash
python3 scripts/dev.py build     # optimalizált FR265 PRG órás teszthez
python3 scripts/dev.py test      # fordítás és egységtesztek
python3 scripts/dev.py beta      # privát béta IQ-csomag és archívumellenőrzés
python3 scripts/dev.py release   # produkciós IQ-csomag és archívumellenőrzés
```

Készülékbővítés vizsgálatához a `build` és `test` parancsnál megadható
a Garmin készülékazonosító:

```bash
python3 scripts/dev.py build --device epix2
python3 scripts/dev.py test --device epix2
python3 scripts/dev.py test --device enduro
```

A kiadási manifestben még nem szereplő készülékekhez a parancs külön
tesztmanifestet és a béta alkalmazásazonosítójával kísérleti PRG-t készít.
Ezeknél a `build-info.json` `experimental` mezője `true`.
A `--min-api` csak ilyen kísérleti buildhez használható; a tényleges
API-minimumot a jegyzőkönyv `min_api_level` mezője rögzíti.
A `beta` és `release` továbbra is a saját kiadási manifestjükben felsorolt
készülékekre exportál; ezeknél a `--device` nem használható.
A készülékenkénti előrehaladás: [támogatott készülékek](docs/supported-devices.md).

A `test` előtt indítsd el a Connect IQ szimulátort. Ezen a KDE-s Linux gépen
a háttérben, külön virtuális kijelzőn és hang nélkül is futtatható:

```bash
python3 scripts/simulator_bg.py start
python3 scripts/dev.py test --device enduro
python3 scripts/simulator_bg.py status
python3 scripts/simulator_bg.py stop
```

A háttérpéldány nem jelenik meg az asztalon, ezért nem veszi el a fókuszt a
gépeléstől. A hangkapcsolat csak ennél a folyamatnál tiltott; a böngésző
hangbeállítását nem módosítja. A futási naplók a gitignored
`build/simulator-bg/` könyvtárban vannak. A tesztek a szimulátor helyi
tesztadatait módosítják. A `beta` és `release` ellenőrzéshez `7z` vagy `7zz`
szükséges. Ezek a parancsok helyi csomagokat készítenek; a Store-beküldés a
[kiadási ellenőrzőlista](store/release-checklist.md) szerinti külön lépés.

Minden futás külön `build/` almappába kerül, a korábbi kiadásokat megőrzi.
A parancs kiírja az elkészült fájl elérési útját. A `VERSION` az egyetlen
verzióforrás: a parancs az angol és magyar `AppVersion` erőforrást is
frissíti, így az órán kijelzett verzió és a fájlnév egyezik. A mellette lévő
`build-info.json` tartalmazza a verziót, alkalmazásazonosítót, Git-revíziót,
a nem commitolt módosítások jelzését, SDK-verziót, fájlméretet, SHA-256
azonosítót és az adott futás ellenőrzéseit. A fordítás és tesztelés naplója
ugyanitt található. Sikertelen ellenőrzésnél nincs sikeres build-jegyzőkönyv.
Az órás eredménylaphoz őrizd meg a tesztelt csomagot és a `build-info.json`-t.

## Gombkiosztás

Beállítás:

- UP/DOWN: menüpont kiválasztása;
- START: a kiválasztott beállítás megnyitása;
- a beállításon belül UP/DOWN: érték módosítása;
- a beállításon belül START: mentés, BACK: módosítás elvetése;
- START GAME menüponton START: meccs indítása.
- MATCH HISTORY menüponton START: a legutóbbi lezárt vagy félbehagyva mentett
  meccsek megnyitása;
- az előzménylistán MENU / hosszan nyomott UP (`HOLD UP: ALL STATS`): az
  összes helyben tárolt, legfeljebb 20 meccs négylapos meccs-, szett-, idő-
  és pontstatisztikája; minden lap `ALL SAVED MATCHES` jelölést kap. Ez nem
  napi összesítés; a pontlap csak a teljes pontadattal mentett meccseket számolja;
- az előzménylistán START: a kiválasztott meccs részletei; UP/DOWN lapozza
  az eredményt, a szetteket, majd az adott meccs szett- és pontstatisztikáját
  (`MATCH SET STATS`, `MATCH POINTS`). Régi, pontadat nélküli rekordnál
  `--` és `NO POINT DATA` jelenik meg;
- az előzmény részletein START: az adott rekord törlése megerősítés után.

Alkalmazás-újraindítás után:

- érvényes aktív mentésnél START és a zöld pipa folytatja a meccset;
- DOWN és a piros X elveti az aktív mentést;
- a folytatott meccs szüneteltetett állapotban nyílik meg.

Meccs közben:

- DOWN: pont a saját csapatnak;
- UP: pont az ellenfél csapatának;
- BACK: utolsó pont visszavonása.
- START/STOP: szünetmenü megnyitása.

A pontbevitel game, szett, oldalcsere-helyzet és no-ad 40–40 után is
megszakítás nélkül folytatódik. A szerváló csapat vagy oldal csak a
szünetmenüből, opcionálisan bírálható felül.

A meccs indításakor egy Garmin FIT-aktivitás is elindul. Szünetben a FIT-időzítő
megáll, folytatáskor újraindul. A meccs mentése a FIT-aktivitást is menti, az
elvetés pedig a FIT-rögzítést is eldobja.

Szünet közben:

- UP/DOWN: választás a szerváló oldal módosítása, a félbehagyott meccs mentése
  és a meccs mentés nélküli eldobása között;
- START a szerváló oldal módosításán: négy pályanegyedes választó megnyitása;
- UP/DOWN választ pályanegyedet, START menti a szerváló csapatot és a
  jobb/bal oldalt, majd a játék azonnal folytatódik;
- START a SAVE & END vagy DISCARD MATCH soron: külön megerősítő kérdés
  megnyitása;
- SAVE & END megőrzi az aktuális game-, pont- vagy tie-break állást az
  előzményben és menti a FIT-aktivitást; DISCARD MATCH mindkettőt eldobja;
- BACK: folytatás.

## Meccskijelző

- a cián A és piros B oldal nagy számokkal mutatja a pontállást;
- legfelül a pontos idő, alatta a lezárt szettek, majd az aktuális set/game
  állás látható;
- a lime labdajelölés mutatja a szerváló csapatot;
- a meccs végén lapozható összegzés csak a végeredményt, az időtartamot és a
  szettenkénti bontást mutatja; a teljesítményadatok a mentett FIT-aktivitásban
  maradnak a Garmin Connect számára;
- az összegzésen START nyitja meg a mentési kérdést; a kijelzőszéli zöld pipa
  a START gombnál menti helyben, a piros X a DOWN gombnál elveti a meccset,
  majd mindkét művelet visszatér a beállításokhoz.

Meccs közben az érintés szándékosan nem módosít állapotot: minden művelet
fizikai gombbal végezhető. A gyorsan ismétlődő pontgomb-események közül csak
az első kerül feldolgozásra.

## Következő checkpoint

A saját használatra bevált `1.1.0` után a jóváhagyott bővítési sorrend:

1. további Garmin órák támogatása, az Enduro / Enduro 2 / Enduro 3
   modellekkel együtt – a szimulátoros kör kész, a valós órás kapu nyitott;
2. meccstörténet és statisztikák – a meccs/szett/idő összesítő után a
   pontstatisztikai checkpoint is implementálva és automatikusan ellenőrizve;
3. Americano / Mexicano játékmód – egy saját meccs pontozása;
4. Instinct 2 támogatása, külön monokróm grafikai adaptációval;
5. saját szinkron és webes felület.

Részletek: [docs/development-roadmap.md](docs/development-roadmap.md)

Kis kontextusablakban, egyenként indítható következő egységek:
[docs/next-work-units.md](docs/next-work-units.md).

**AM-7 automatikus kapu lezárva; következő eszköz nélküli egység: I2-1, Instinct 2 korlátok és vizuális tokenek.**
Az [egymeccses specifikáció](docs/americano-mexicano-spec.md) két csapat
saját meccsét kezeli: közös összpontszám (A+B=X) vagy csapatcél
(A=X vagy B=X), meccs előtt beállítható 1–999 X és kezdő A/B.
CLASSIC/AMERICANO/MEXICANO mód választható; pontmódban új 0–0-s
meccs indul. DOWN pontot ad a MY TEAM, UP az OPPONENT csapatnak,
500 ms-os közös bemenetvédelemmel. BACK az utolsó pontot vonja vissza,
legfeljebb húsz pontból. START szüneteltet, szünetben START a RESUME
soron vagy BACK folytat. Szünetben UP/DOWN csak a menüt mozgatja.
Az aktív játékidő szünetben és az eredményen nem nő.
Lezáráskor WIN/LOSS/DRAW, pontállás, mód, szabály, X és játékidő
látszik; UP/DOWN már nem ad pontot, BACK visszanyitja a meccset.
Az eredményen START, szünetben DISCARD MATCH külön megerősítéssel
eldobja a meccset és visszatér a megőrzött setupra. A megerősítés
alapértéke NO; BACK elveti a kilépést. Élő meccsben az érintés nem
módosít állapotot. A pontmeccs aktív állapota automatikusan mentődik;
újraindításkor START szünetben folytatja, DOWN eldobja. Mód, szabály, X,
kezdő csapat, pontállás és játékidő megmarad. Az undo-napló újraindításkor
üres, a klasszikus meccshez igazodva; a folytatás utáni pontok ismét
visszavonhatók. Visszaállított lezárt meccsnél a fagyasztott eredmény látszik.
A folytatott meccs megerősített eldobása vagy mentése a főmenübe lép vissza.
Az AM-6 az előzményt és a korai mentést is beköti; az AM-7 a pontmódos FIT-et is kezeli.
Az AM-6/AM-7 ellenőrzése és a build-jegyzőkönyvek az átadási jegyzetben vannak;
a régi klasszikus mentések olvashatók maradnak.
Az S2-V2 valós órás próba továbbra is nyitott; az új statisztikalapok
ellenőrzéséhez az 1.3.0 produkciós csomagot használd.

Új fejlesztői munkamenethez: [átadási jegyzet](docs/development-handoff.md).
