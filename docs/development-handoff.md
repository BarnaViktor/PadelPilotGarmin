# Fejlesztési átadás – 2026-09-14

## Innen folytasd

Aktív munka: **további Garmin órák támogatása**, ezen belül az **Enduro
280 × 280-as felületének ellenőrzése**. A rajzolási adapter már a kódban
van, a teljes vizuális és gombos elfogadás még nincs kész. A felhasználó
ennek a munkának a folytatását, majd az állapot új chathez történő
rögzítését kérte.

Először olvasd el ezt a fájlt, a [készüléklistát](supported-devices.md),
majd nézd meg a `git status` és `git log` eredményét. A folytatáshoz nem
kell újrakezdeni a már sikeresen lefutott korábbi ellenőrzéseket.

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
negyedik feladatként helyezte. Annak 176-as monokróm UI-fejlesztése még
nem indult el. A többi funkcióbővítés részletes specifikációja későbbi feladat.

## Kódbázis és az utolsó munkamenet változásai

A munkamenet indulásakor a Git-munkafa tiszta volt, a HEAD:
`5432a19` – „eszköz támogatás bővítése és további fejlesztési igények sorrendezése”.
Ebben már benne volt a korábbi fejlesztési automatizálás, a prioritások
és a megkezdett Enduro-adapter. Ebben a munkamenetben nem készült új commit.

Már meglévő implementáció:

- `source/ui/PadelTheme.mc`: `PadelTheme.canvas()` és `PadelScaledCanvas`.
  Kizárólag 280 × 280-as DC esetén skálázza a 416-as terv koordinátáit;
  a vonalvastagság legalább egy pixel, a téglalapok közös szélei azonos
  pixelre kerülnek. Köztes teljes képernyős bitmap nincs.
- A hat `*View.mc` `onUpdate()` elején a `PadelTheme.canvas(dc)` hívás.
  A 416-as felületek közvetlenül a natív DC-t kapják vissza.
- A betűméret natív rendszerbetű marad; a szöveg szélességét az adapter
  nem méretezi és nem ellenőrzi.
- `scripts/dev.py`: normál build, egységteszt, béta- és produkciós export,
  `--device`, kísérleti készülékekhez `--min-api`, naplók és SHA-256
  build-jegyzőkönyv. A kísérleti készülékek a tesztalkalmazás azonosítóját
  használják. A kiadási manifestek továbbra is FR265-re szólnak.

Ebben a munkamenetben készült:

- `source/ui/SetupView.mc`: a natív Enduro betűkészlettel hibásan megjelenő
  Unicode mínuszjel cseréje ASCII `-` jelre a számérték-szerkesztőben.
- `source/tests/DisplayLayoutTests.mc`: négy új teszt. A rajzolási
  helyettesítő a főmenü, minden beállítási sor/szerkesztő, pontozás,
  szünet, négy szervanegyed, mentési/eldobási kérdés, visszaállítás,
  meccs-/szettösszegzés és előzmény vizsgált állapotainak koordinátáit
  ellenőrzi. A teljes csomag így **55 tesztes**. A tesztsegédek `:debug`
  jelölésűek, így a release PRG méretét és memóriáját nem növelik.
- README, ütemterv, készüléklista és ez az átadási jegyzet frissítve.

## Ellenőrzési eredmény és korlátai

Connect IQ SDK / compiler: **9.2.0**.

| Készülék | Profil | API-minimum a tesztben | Eredmény |
|---|---|---|---|
| Enduro | `enduro` | `3.4.0`, kísérleti manifest | 55/55 teszt, normál PRG lefordult |
| Enduro 2 | `fenix7x` | `4.1.6` | 55/55 teszt, normál PRG lefordult |
| Enduro 3 | `enduro3` | `4.1.6` | 55/55 teszt, normál PRG lefordult |
| Forerunner 265 | `fr265` | `4.1.6` | 55/55 teszt, normál PRG lefordult |

A tesztekben 51 korábbi domain/mentés/FIT-teszt és 4 új elrendezési
teszt van. A `LayoutBoundsDc` **nem natív képernyőkép-ellenőrzés**:
nem méri a betűk tényleges kiterjedését, a körmaszk miatti levágást,
az elemek átfedését vagy a kontrasztot. Fizikai gombokat sem szimulál.
A fordító ismert, dinamikus konténerhozzáféréshez kapcsolódó
típusellenőrzési figyelmeztetéseket adott.

Korábbi, 2026-09-13-i ellenőrzések: a hat további AMOLED-jelölt normál
buildje és 51/51 tesztje sikeres volt. Az új 55-ös csomagot ebben a
munkamenetben ezekre a további profilokra nem futtattuk újra.
Részletes modellnevek és felvételi feltételek: [készüléklista](supported-devices.md).

Az Enduro főmenüje és több beállítási nézete a natív szimulátorban is
megjelent. Az induló főmenü képe:
`build/ui-review-2026-09-14/enduro/00-initial.png`.
Itt a szimulátor **48,1 / 123,8 kB** memóriahasználatot jelzett.
Ez rövid megfigyelés, nem 200 pontos vagy valós órás stresszteszt.

A Linux/Xwayland/XTest kattintássorozat nem megbízhatóan a kívánt
képernyőkre jutott. Emiatt a `build/ui-review-2026-09-14/enduro/`
többi fájlnevét és a contact sheet címkéit **nem szabad sikeres
tesztjegyzőkönyvként értelmezni**. A vizuálisan látott mínuszjel-hibát
javítottuk, de a javítás utáni natív képernyőképes ellenőrzés is nyitott.
A kipróbált kattintósegédet nem hagytuk a repositoryban.

## Következő konkrét munkalépések

1. Indítsd a friss Enduro PRG-t, és ellenőrizd natív képen a javított
   mínuszjelet és a többi írásjelet. Ezután járd be a pontozási, szünet-,
   szervaválasztó, megerősítő, összegző, visszaállító és előzményképernyőket.
   Minden lépésnél ellenőrizd a tényleges állapotot; a sikeres kattintóparancs
   önmagában nem bizonyítja a helyes navigációt.
2. Ellenőrizd az Enduro 2 / Enduro 3 natív fontjait és MIP-színeit is.
   Külön figyelj a hosszabb szövegekre, a sokszettes eredményre és a
   feltöltött előzmény lapjelzőire. A tesztben jelenleg két előzményrekord van.
3. Mérj natív memóriahasználatot hosszú meccsnél, legalább 200 pont és
   feltöltött undo mellett, elsősorban a **128 KiB-os első Endurón**.
4. Zárd a még hiányzó AMOLED vizuális/gombos ellenőrzéseket. Az előző
   munkamenetben az Epix Gen 2 főmenüje és beállítása megjelent, de a
   teljes hatmodellnyi bejárás nem készült el.
5. Az érintett készülékek valós órás meccs-/FIT-/Connect-ellenőrzése
   után értékeld a kiadási manifest bővítését. A modellnevek felírása
   és a sikeres fordítás önmagában még nem éles támogatás.

## Parancsok és megőrzött bizonyítékok

A jelenlegi helyi SDK-t a Garmin SDK Manager konfigurációja jelöli.
A `scripts/dev.py` alapértelmezetten ezt és a helyi, gitignored
`docs/developer_key` fájlt használja. A kulcsot nem kell kiolvasni vagy
közzétenni.

```bash
CIQ_SDK_DIR="$(cat "$HOME/.Garmin/ConnectIQ/current-sdk.cfg")"
"$CIQ_SDK_DIR/bin/connectiq"
```

Nyitott szimulátor mellett, egymás után:

```bash
python3 scripts/dev.py test --device enduro --min-api 3.4.0
python3 scripts/dev.py test --device fenix7x
python3 scripts/dev.py test --device enduro3
python3 scripts/dev.py test --device fr265
python3 scripts/dev.py build --device enduro --min-api 3.4.0
```

Normál alkalmazás indítása a buildparancs által kiírt PRG-útvonallal:

```bash
"$CIQ_SDK_DIR/bin/monkeydo" /absolute/path/to/generated.prg enduro
```

A tesztek egy közös szimulátort használnak, ezért ne indíts rajta
párhuzamos futásokat. A `monkeydo` sikeres tesztcsomagnál is adhat 1-es
kilépési kódot; a fejlesztői script a végső `PASSED` összesítést is vizsgálja.

A hiteles naplók és `build-info.json` fájlok a `build/` futáskönyvtárakban
maradnak, a `/tmp` nem tartós. A tesztjegyzőkönyvek ezen a gépen:

- `build/test-1.1.0-enduro-ioan3wzx/build-info.json`
- `build/test-1.1.0-fenix7x-dc1f4yal/build-info.json`
- `build/test-1.1.0-enduro3-_yhp4iew/build-info.json`
- `build/test-1.1.0-fr265-ry35emyy/build-info.json`

A legutóbbi Enduro PRG a javított mínuszjellel és a release-ből kizárt
tesztsegédekkel:
`build/build-1.1.0-enduro-hqj301o_/padel-pilot-1.1.0-enduro.prg`
(49 868 bájt; pontos SHA-256 a mellette lévő `build-info.json`-ban).

A `build/` gitignored; másik gépen a fenti parancsokkal újra előállítandó.
Az `1.1.0` verziószám továbbra is a munkafa kiinduló verziója, új Store-kiadás
ebben a munkamenetben nem történt.
