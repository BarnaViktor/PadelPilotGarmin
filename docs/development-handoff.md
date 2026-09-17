# Fejlesztési átadás – 2026-09-17

## Innen folytasd

Aktív munka: **további Garmin órák támogatása**. Az Enduro / Enduro 2 /
Enduro 3 szimulátoros UI- és gombos ellenőrzése elkészült, beleértve az első
Enduro 128 KiB-os memóriakeretének hosszú meccses próbáját is. A következő
szimulátoros lépés a még nyitott 416 × 416-as AMOLED-jelöltek teljes vizuális
és gombos bejárása. Valós Enduro órán végzett meccs-, FIT-, Connect- és
akkumulátorpróba továbbra sincs dokumentálva.

Új munkamenet elején olvasd el ezt a fájlt és a
[készüléklistát](supported-devices.md), majd ellenőrizd a `git status` és
`git log -1` eredményét. A már lezárt Enduro-szimulátoros kört ne kezdd újra,
hacsak az érintett UI-kód nem változik.

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

A 2026-09-17-i ellenőrzés indulásakor a munkafa tiszta volt, a HEAD és az
`origin` egyaránt:

`2458cdf32bc6fd9309eb4970dc08ceae358e895f` – „eszköz támogatások és fixek hozzá”.

Ebben a munkamenetben termékkód és teszt nem változott, commit nem készült.
Csak a dokumentáció módosult; a képek és a helyi segédek a gitignored
`build/ui-review-2026-09-17/` könyvtárban vannak.

Meglévő implementáció:

- `source/ui/PadelTheme.mc`: `PadelTheme.canvas()` és `PadelScaledCanvas`.
  Kizárólag 280 × 280-as DC esetén skálázza a 416-os terv koordinátáit;
  köztes teljes képernyős bitmap nincs.
- A hat `*View.mc` a közös adaptert használja. A 416-as felületek közvetlenül
  a natív DC-t kapják vissza, a betűméret natív rendszerbetű marad.
- `source/ui/SetupView.mc`: a számérték-szerkesztő ASCII `-` jelet használ,
  mert a natív Enduro fontból hiányzott a korábbi Unicode mínusz.
- `source/tests/DisplayLayoutTests.mc`: négy elrendezési teszt; a teljes
  csomag **55 tesztes**. A segédek `:debug` jelölésűek.
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

A további AMOLED-jelölteken 2026-09-13-án 51/51 teszt futott le. Az új 55-ös
csomag és a teljes UI-/gombos bejárás rajtuk még nyitott. Részletek:
[készüléklista](supported-devices.md).

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

## Következő konkrét munkalépések

1. Folytasd a készüléktámogatási prioritást a még nyitott AMOLED-profilok
   teljes natív UI-/gombos bejárásával. Elsőként az `epix2` profilt vedd elő,
   ahol korábban csak a főmenü és a beállítás eleje jelent meg; utána
   `d2mach1`, `epix2pro47mm`, `fenix843mm`, `fenixe`,
   `instinct3amoled50mm`.
2. Az AMOLED-jelölteken futtasd le az 55-ös tesztcsomagot is, mert rajtuk
   eddig csak a korábbi 51/51 eredmény van dokumentálva.
3. Ha rendelkezésre állnak a készülékek, végezz Enduro / Enduro 2 / Enduro 3
   valós órás teljes meccs-, FIT-, Garmin Connect-, olvashatósági és
   akkumulátorpróbát. A szimulátoros eredmény önmagában nem nyitja meg a
   kiadási manifestet.
4. Csak a modell felvételi kapujának teljesítése után bővítsd a release
   manifestet. Ezután következhet a jóváhagyott sorrend második pontja,
   a meccstörténet és statisztikák bővítése.

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

Az `1.1.0` verziószám változatlan; új Store-kiadás ebben a munkamenetben
nem történt.
