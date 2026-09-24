# Következő, kis kontextusú munkamenetek

Ez a lista a hátralévő munkát egymástól elválasztható fejlesztési egységekre
bontja. Egy új Codex-munkamenet egyszerre csak **egy azonosítót** kapjon meg,
például: „Folytasd az `S2-V1` egységgel”. Az egységek sorrendjét csak külön
termékdöntéssel változtasd meg.

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

## AM – Americano / Mexicano

Az `AM` egységek az S2 ellenőrzések után következnek. Az első egység még nem
ír termékkódot.

### AM-1 – Szabály- és termékdöntések

**Cél:** egy rövid specifikációban rögzíteni:

- Americano és Mexicano támogatott változata;
- játékosok és pályák száma;
- párosítás és partner-/ellenfél-rotáció;
- fix pontszám vagy időlimit;
- fordulók száma és lezárási feltétel;
- holtverseny-kezelés;
- órán tárolt játékosnevek/azonosítók;
- egyéni és páros eredmények;
- megszakítás, undo és helyreállítás szabálya.

**Kimenet:** új, jóváhagyott specifikáció a `docs/` alatt, elfogadási
példákkal. Nyitott termékdöntés mellett ne induljon `AM-2`.

### AM-2 – Tiszta domainmodell

**Cél:** UI és perzisztencia nélkül megvalósítani a forduló-, párosítás- és
pontozási modellt.

**Elfogadás:** determinisztikus tesztek kis és maximális támogatott
létszámra, páratlan/hibás bemenetekre és holtversenyre. A klasszikus
`ScoringEngine` viselkedése változatlan marad.

### AM-3 – Beállítás és navigáció

**Cél:** játékmódválasztás, játékos-/fordulóbeállítás és indítás, még teljes
élő meccsképernyő nélkül.

**Elfogadás:** BACK/cancel nem veszít jóváhagyott adatot; minden felirat
elfér FR265 és Enduro elrendezési teszten.

### AM-4 – Élő fordulókezelés

**Cél:** pontbevitel, aktuális párosítás, fordulóváltás, undo és szünet.

**Elfogadás:** egy teljes kisméretű torna végigjátszható, és minden
állapotátmenet domain-teszttel fedett.

### AM-5 – Mentés és helyreállítás

**Cél:** verziózott aktív tornaállapot, újraindítás utáni folytatás és hibás
mentés biztonságos eldobása.

**Elfogadás:** régi normál meccsmentések változatlanul olvashatók; az új
tornaformátum nem keveredik a `matchHistory` rekordjaival.

### AM-6 – Eredmény és előzmény

**Cél:** végeredmény, rangsor és fordulóbontás megjelenítése, törlése és
helyi tárolási korlátja.

**Elfogadás:** előbb külön tárhely-/memóriadöntés készül az első Enduróra;
csak utána rögzíthető a rekordkorlát.

### AM-7 – FIT és készülékkapu

**Cél:** eldönteni, egy torna egy vagy több FIT-aktivitás legyen-e, majd a
jóváhagyott modellt implementálni.

**Elfogadás:** FR265 és Enduro teszt/build, utána külön valós órás próba.
Ebben az egységben ne bővíts release manifestet.

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

Verziózott JSON-séma normál meccshez és később tornához; idempotencia,
időzóna, törlés és konfliktuskezelés. Kódolás előtt minta payloadokkal
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
