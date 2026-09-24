# Fejlesztési átadás – 2026-09-24

## Innen folytasd

Az első **meccstörténet és statisztika checkpoint lezárult**, a második
pontstatisztikai checkpoint pedig implementálva és automatikusan ellenőrizve
van a jelenlegi munkafában. A készüléktámogatás valós órás release-kapuja
változatlanul nyitott.

Az első checkpoint mutatói: összes/befejezett/félbehagyott meccs,
győzelem–vereség és arány, szettgyőzelem–szettvereség és arány, valamint
teljes/átlagos játékidő. Új perzisztens formátum nincs; a számítás a meglévő
legfeljebb 20 rekordból történik, a régi rekordokkal együtt.

A második checkpoint megtartja a 20 rekordos gördülő korlátot, és az újonnan
indított meccsekhez megnyert–elvesztett pontot tárol. A négylapos összesítő
pontlapja ezek összegét, a pontnyerési arányt és a pontadattal rendelkező
meccsek számát mutatja. A régi előzmények olvashatók, de pontadat hiányában
nem kerülnek a pontarány nevezőjébe.

FR265 és Enduro profilon 61/61 teszt, optimalizált build és üres előzményes
natív pontlap-bejárás sikeres. Az FR265 bejárás során talált címke/érték
átfedéseket a `POINT MATCHES` és `POINT RATE` rövidítések javították. Régi és
vegyes rekorddal a natív vizuális ismétlés még nyitott.

Új munkamenet elején olvasd el ezt a fájlt és a
[készüléklistát](supported-devices.md), majd ellenőrizd a `git status` és
`git log -1` eredményét. A már lezárt Enduro-szimulátoros kört ne kezdd újra,
hacsak az érintett UI-kód nem változik.

A hátralévő munka kis kontextusú, egyenként indítható egységei:
[következő munkamenetek](next-work-units.md). A közvetlen következő egység
`S2-V1`; valós tesztóra rendelkezésre állásakor külön `S2-V2` vagy egyetlen
`D-<device-id>` egység indítható. Egy munkamenetben ne vonj össze több
azonosítót.

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
- `source/tests/DisplayLayoutTests.mc`: négy elrendezési teszt; az előzményteszt
  már a négy statisztikalapot is bejárja. A segédek `:debug` jelölésűek.
- A teljes csomag **61 tesztes**; a pontszámlálás/undo, a régi aktív mentés
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

1. `S2-V1`: járd végig a négylapos statisztikát régi és vegyes v2/v3
   előzménnyel FR265 és Enduro szimulátorskin alatt.
2. `S2-V2`: csak elérhető tesztórával ellenőrizd a valós pontösszesítést.
3. Ezután `AM-1`: rögzítsd az Americano/Mexicano termék- és
   szabálydöntéseit; ebben az egységben még ne írj termékkódot.
4. A készülékteszteket modellenként külön `D-<device-id>` egységben végezd;
   csak sikeres valós órás kapu után bővíts release manifestet.

A részletes inputok, korlátok és elfogadási feltételek a
[kis kontextusú feladatbontásban](next-work-units.md) vannak; mindig csak egy
azonosítót indíts.

## Parancsok és helyi bizonyítékok

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
