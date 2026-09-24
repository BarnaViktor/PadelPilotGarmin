# Fejlesztési ütemterv

## C0 – Projektalap és szabálymotor

Állapot: elkészült és Forerunner 265 szimulátorban ellenőrizve.

- Connect IQ projektstruktúra;
- domain és UI szétválasztása;
- advantage és no-ad;
- normál szett és tie-break;
- döntő teljes szett vagy match tie-break;
- undo;
- alapszabályok egységtesztjei.

Elfogadási feltétel: a tesztek Connect IQ szimulátorban lefutnak, a prototípus
két gombbal végigjátszható.

## C1 – Meccsbeállítás és stabil pontbevitel

Állapot: elkészült és Forerunner 265 szimulátorban ellenőrizve.

- beállítóképernyők;
- Forerunner 265 célkészülék és készülékspecifikus gombkiosztás;
- kezdő adogató csapat;
- szervasorrend és tie-break szervaváltások;
- no-ad döntő pont;
- haptikus visszajelzés;
- pontozási edge case-ek teljes tesztkészlete.

C1 kiegészítésként elkészült a kétlépcsős beállítási felület, a saját/ellenfél
szemléletű pontbevitel, valamint a szünet/folytatás, opcionális kézi
szerválócsapat- és szervaoldal-váltás, valamint a megerősített
mentés/befejezés és eldobás. A pontbevitel game és no-ad 40–40 után is
folyamatos, a meccsképernyő tetején pedig látható a pontos idő.

## C2 – Helyi mentés és visszaállítás

Állapot: elkészült és Forerunner 265 szimulátorban ellenőrizve.

- meccsállapot tartós mentése;
- alkalmazás bezárása utáni folytatás;
- lezárt és félbehagyva mentett meccsek rövid előzménye;
- előzményrekordok egyenkénti, megerősített törlése;
- hibás vagy félbemaradt mentés kezelése.

A mentési formátum verziózott. Az aktív meccs pont-, game-, szett-, tie-break-,
szerva- és időállapota minden változás után frissül, valamint az alkalmazás
leállásakor is mentődik. Újraindításkor a meccs folytatható vagy elvethető;
a folytatás biztonsági okból szüneteltetett állapotban indul. A hibás aktív
mentés törlődik, a hibás előzményrekordok pedig kimaradnak a listából.
Szünetből a meccs az aktuális game-, pont- vagy tie-break állással együtt
félbehagyottként menthető, vagy mentés nélkül eldobható. A SAVE & END a helyi
rekordot és a FIT-aktivitást is menti; sikertelen FIT-mentésnél az aktív
meccsállapot megmarad, és a művelet újrapróbálható.

## C3 – Garmin aktivitás és alapstatisztika

Állapot: implementálva és a Forerunner 265 szimulátor ActivityRecording
API-jával ellenőrizve. Valós órás FIT-fájl és Garmin Connect megjelenítés még
ellenőrizendő.

- FIT-aktivitás indítása és lezárása;
- padel sportbesorolás;
- pulzus, kalória és időtartam;
- eredmény és szettadatok egyedi FIT mezőkben;
- pont- és labdamenet-időpontok;
- Garmin Connect megjelenítés ellenőrzése.

A FIT session `racket/padel` sportbesorolással indul. A Garmin natív
aktivitásmotorja rögzíti az időt, az engedélyezett pulzusszenzor adatait és az
ezekből számolt kalóriát. Developer mezőként bekerülnek a pontesemények, a
szettenkénti game-eredmények, a szettarány, a győztes és az összesített
szetteredmény. A pause megállítja, a folytatás újraindítja a FIT időzítőt. A
teljesítménymetrikákat az alkalmazás nem ismétli meg a meccsvégi képernyőn;
azok a mentett FIT-aktivitásban maradnak a Garmin Connect számára.

Technikai korlát: a Garmin ActivityRecording session objektuma folyamatok
között nem állítható vissza. Ha az alkalmazás aktív meccs közben teljesen
bezáródik, az addigi FIT-rész biztonságosan lezárul és mentődik; a C2-ből
visszaállított meccs új FIT-szegmenst kezd. A pontozási állapot ettől még
folyamatosan helyreáll.

## C4 – Valós órás MVP

Állapot: a felhasználó megerősítette, hogy az éles `1.1.0` van használatban.
A saját használatra szánt MVP-t megfelelőnek találja: működési hibát vagy
zavaró viselkedést nem tapasztalt, jelenleg nincs bejelentett javítási igény.
A Store-csomag, az ikonok és a beküldési metaadatok elkészültek.
A Garmin Connect-megjelenítés és a memória-/akkumulátormérés részletes
eredménye még nincs dokumentálva. Külön béta telepítése nem előfeltétele
az éles kiadás tapasztalatai feldolgozásának.

- valós meccsek tesztelése;
- véletlen gombnyomások és izzadt kéz kezelése;
- olvashatóság napfényben és sötétben;
- memória- és akkumulátormérés;
- támogatott készüléklista;
- Connect IQ Store előkészítés.

A fordítás és ellenőrzés a `scripts/dev.py` paranccsal automatizálva:
FR265 PRG, szimulátoros egységtesztek, béta- és produkciós IQ-export,
archívumellenőrzés és SHA-256 azonosítót tartalmazó build-jegyzőkönyv.
Ez a következő javítások ellenőrzését segíti; a részletes valós készülékes
mérési eredmények még nincsenek dokumentálva.
Használat: [README.md](../README.md#fordítás-és-automatikus-ellenőrzés).

## C5 – Kibővített aktivitásmérés és eredményszinkron

Állapot: implementálva, 51 egységteszttel és Forerunner 265 szimulátorban
ellenőrizve. Az éles `1.1.0` használatát a felhasználó megerősítette.
A FIT-fájl tartalmának és a Garmin Connect-megjelenítésnek a valós meccses
ellenőrzési eredménye még nincs dokumentálva.

### Több aktivitásadat rögzítése

- megtett távolság rögzítése a Garmin natív FIT-mezőiben;
- aktuális, átlagos és maximális sebesség rögzítése;
- GPS-nyomvonal rögzítése folyamatos helyadatokkal;
- a Forerunner 265 és a támogatni kívánt további órák által elérhető natív
  aktivitás- és szenzoradatok felmérése;
- az aktuális, átlagos és maximális pulzus, kalória, aktivitásidő és az órán
  elérhető kadenciaadatok natív rögzítése;
- termékdöntés: a meccsvégi órás összegzés nem mutat külön teljesítményoldalt;
  a távolság-, sebesség-, pulzus- és kalóriaadatok a FIT-aktivitásba kerülnek;
- a mérések pontosságának összehasonlítása a Garmin natív padelaktivitásával,
  különösen beltéri pályán, ahol a GPS-alapú távolság és sebesség pontatlan
  lehet;
- a `Positioning` jogosultság felvéve; a valós memória-, akkumulátor- és
  beltéri pontosságmérés még elvégzendő.

### Meccseredmény szinkronizálása és megjelenítése

- valós órán ellenőrizni, hogy a már rögzített egyedi FIT-mezők — győztes,
  szettarány és szettenkénti eredmény — bekerülnek-e a szinkronizált
  aktivitásba;
- ellenőrizni, hogy ezek az adatok megjelennek-e a Garmin Connect mobil- és
  webes aktivitásnézetében;
- ha a Garmin Connect nem jeleníti meg megfelelően az egyedi mezőket, felmérni
  a támogatott alternatív megjelenítési lehetőségeket;
- a Garmin Connect developer-mezők ellenőrzéséhez béta- vagy Store-alkalmazás
  feltöltése és onnan történő telepítése szükséges; a közvetlenül USB-n
  telepített PRG önmagában ezt nem teszi lehetővé;
- későbbi saját API-s szinkron esetén a végeredményt, a szettenkénti eredményt
  és a meccs alapstatisztikáit is továbbítani, majd az alkalmazásban vagy a
  webes felületen megjeleníteni;
- a sikertelen vagy megszakadt szinkron felismerése és biztonságos
  újrapróbálása.

Elfogadási feltétel: egy valós órán rögzített tesztmeccs után a kiválasztott
új metrikák a FIT-aktivitásban ellenőrizhetők, a meccseredmény pedig legalább
egy támogatott szinkronizált felületen egyértelműen megjelenik. A nem
támogatható vagy nem kellően pontos mérések dokumentált döntéssel kerülnek ki
a fejlesztési körből.

## Következő fejlesztések – jóváhagyott prioritás

Az éles `1.1.0` a felhasználó saját használatára megfelelő. A bővítések
felhasználó által meghatározott sorrendje:

1. **További Garmin órák támogatása, az Enduro családdal együtt.**
   Felhasználói kiegészítés: az Enduro, Enduro 2 és Enduro 3 is támogatási cél.
   Első lépés a meglévő 416 × 416-as,
   fizikai gombokkal vezérelt felülethez közeli készülékek fordítási és
   szimulátoros ellenőrzése. Ezután képernyőnkénti UI-/gombkezelési és valós
   órás ellenőrzés következik. Az Enduro családhoz 280 × 280-as MIP-felület
   szükséges. Az első Enduro régebbi API-ja és kisebb memóriakerete külön
   kompatibilitási munkát igényel; az Enduro 2 SDK-azonosítója `fenix7x`,
   az Enduro 3-é `enduro3`.
2. **Meccstörténet és statisztikák.** A meglévő helyi előzmények bővítése,
   többmeccses összesítések; a pontos mutatók a munka kezdetén választandók ki.
3. **Americano / Mexicano játékmód.** Lebonyolítás és kapcsolódó pontozás;
   a részletes szabályok a fejlesztési egység elején rögzítendők.
4. **Instinct 2 támogatása, külön grafikai adaptációval.** 176 × 176-as
   monokróm MIP-elrendezés, színektől független jelölések, kisebb grafikák
   és szövegek, API 3.4-kompatibilitás és 96 KiB-os memóriakeret vizsgálata.
   A felhasználó kérésére az Americano/Mexicano után, a saját webes felület
   előtt következik. Állapota: felírva, megvalósítás előtt; részletes
   [feladatlista](supported-devices.md#instinct-2--külön-grafikai-adaptációs-feladat).
5. **Saját szinkron és webes felület.** Saját Laravel API és Vue
   statisztikai webalkalmazás a korábbi elképzelések szerint.

Aktív fejlesztési egység: **meccstörténet és statisztikák bővítése**.
A készüléktámogatás valós órás kapuja továbbra is nyitott; a
készülékenkénti állapot: [supported-devices.md](supported-devices.md).

2026-09-18-i folytatási állapot: az Enduro család és a hat 416 × 416-as
AMOLED-jelölt natív szimulátoros vizuális/gombos ellenőrzése elkészült; az
AMOLED-jelölteken készülékenként 55/55 teszt is sikeres. Az első Enduro
128 KiB-os keretében a 200+ pontos, feltöltött undo-előzményű terhelés,
a hosszú meccs mentése és a megállított előzmény megjelenítése stabil volt;
a kijelzett maximum 61,3 / 123,8 kB. A következő kapu a felvenni kívánt
modellek valós órás teljes meccs-, FIT-/Connect-, olvashatósági és
akkumulátorpróbája. Tesztóra hiányában a felhasználó úgy döntött, hogy ez a
kapu nyitva marad, és közben elindul a meccstörténet és statisztikák
bővítése. Az új chat konkrét belépési pontja:
[fejlesztési átadás](development-handoff.md).

### Meccstörténet és statisztikák – 1. checkpoint

A 2026-09-18-án indított első, eszköz nélkül is ellenőrizhető bővítés a
meglévő, legfeljebb 20 helyi előzménybejegyzésből számol. Nem vezet be új
tárolási formátumot, ezért a korábbi rekordok olvashatósága megmarad, és
előzménytörlés után az összesítés automatikusan frissül.

Az első mutatók:

- összes, befejezett és félbehagyott meccs;
- győzelem–vereség és győzelmi arány a befejezett meccsekből;
- megnyert–elvesztett befejezett szettek és szettgyőzelmi arány;
- teljes és átlagos játékidő az összes mentett bejegyzésből.

Az előzménylistán a MENU / hosszan nyomott UP gomb nyitja meg a háromlapos
statisztikai nézetet; UP/DOWN lapoz, BACK visszalép. Üres előzménynél a
darabszámok nullák, a nem értelmezhető arányok `--` jelölést kapnak.

Elfogadási állapot: **lezárva**. FR265 és első generációs Enduro profilon,
tiszta `9f7e3e4` commitból 57/57 teszt és optimalizált build sikeres. A
csomag tartalmazza a vegyes új/régi/félbehagyott rekordok számítását, a
nullával osztás elkerülését és a 416 × 416 / 280 × 280 elrendezési
határvizsgálatot. Mindkét natív szimulátorskin alatt üres és vegyes
előzménnyel végigjártuk a megnyitást, a három lapot és a visszalépést. A
bejárás során talált idő- és arányfelirat-átfedések javítva lettek. Valós
órás vizuális és gombos ismétlés eszköz hiányában nyitott.

### Meccstörténet és statisztikák – 2. checkpoint

Állapot: **implementálva, az automatikus elfogadási kapu lezárva**. A
scope-döntés 2026-09-24-én, az új kontextusablak elején megszületett.

A helyi előzmény továbbra is a legutóbbi **20 meccs gördülő pillanatképe**
marad. Ez kiszámítható tárhely- és memóriahasználatot őriz az első generációs,
128 KiB-os Endurón, és nem próbálja a későbbi saját szinkron hosszú távú
archívumszerepét átvenni. A korlát csak valós órás tárhelymérés vagy a saját
szinkron adatmegőrzési tervének elkészülte után vizsgálandó felül.

A checkpoint új adata a meccs során ténylegesen megnyert pontok páronkénti
összesítése. Ebből az előzmény statisztikai nézete megnyert–elvesztett
pontszámot és pontnyerési arányt mutat. Ez a legkisebb hasznos adatkör, amely
valóban új rekordformátumot igényel: a pontos pontszám a korábbi szett-, game-
és pillanatnyi pontállásokból nem rekonstruálható. A régi rekordok továbbra is
olvashatók, de nem kerülnek a pontstatisztika nevezőjébe; a nézet jelzi, hány
mentett meccshez áll rendelkezésre pontadat.

Elfogadási feltételek:

- minden elfogadott pontbevitel pontosan egy csapat összesítőjét növeli, az
  undo pedig ezt is hiánytalanul visszaállítja;
- a pontösszesítő aktív meccs mentése és újraindítás utáni folytatása során
  megmarad;
- a lezárt és a félbehagyott új rekordok verziózott formátumban tárolják a
  két pontösszeget, miközben az 5, 6 és 9 elemű régi rekordok olvashatók
  maradnak;
- az összesített nézet külön lapon mutatja a megnyert–elvesztett pontokat, a
  pontnyerési arányt és a pontadattal rendelkező meccsek számát; nulla
  pontadatnál az arány `--`;
- célzott domain-, migrációs és 416 × 416 / 280 × 280 elrendezési tesztek
  készülnek, majd az összes teszt és az optimalizált build sikeresen lefut
  FR265 és első generációs Enduro profilon.

Elfogadási eredmény: FR265 és első generációs Enduro profilon **61/61 teszt**
sikeres, benne a pontszámlálás, undo, új és régi aktív mentés, v1/v2/v3
előzmény, hibás v3 pontadat, a 20 rekordos gördülő korlát, vegyes összesítés,
nulla nevező és a négylapos nézet 416 × 416 / 280 × 280-as rajzolási határa.
Mindkét profilon elkészült az optimalizált normál build; az Enduro változat
API 3.4.0 minimumon, 54 396 bájtos PRG-vel fordult.
Üres előzménnyel a natív FR265 és Enduro skinen is működött a megnyitás,
lapozás és BACK. Az FR265 bejárás megtalálta a hosszú pontmeccs- és
pontarány-címkék átfedését a jobb oldali értékekkel; a rövidített
`POINT MATCHES` és `POINT RATE` címkékkel javítva.

Az aktív mentés v3 sémája külön jelzi a pontadat teljességét. Egy korábbi
verzióból folytatott meccs pontszáma nem rekonstruálható, ezért az ilyen
meccs később is v2 előzményként, pontadat nélkül mentődik, és nem torzítja a
pontarányt. Újonnan indított meccsnél a lezárt és félbehagyott v3 rekord is
teljes pontösszesítést kap. Valós órás vizuális és gombos ismétlés továbbra
is a készüléktámogatási kapu része; régi és vegyes rekordos natív
szimulátoros ismétlés még nyitott.

## Codex munkamenet egy checkpointon belül

A további feladatok kis, önálló kontextusablakokra bontott azonosítói,
bemenetei és elfogadási kapui:
[következő munkamenetek](next-work-units.md).

1. kiválasztunk egy szűk, ellenőrizhető célt;
2. rögzítjük az elfogadási feltételeket;
3. Codex implementálja a kódot és a teszteket;
4. lefut a szimulátoros, majd a valós órás ellenőrzés;
5. dokumentáljuk a döntést és lezárjuk a checkpointot;
6. csak ezután indul a következő fejlesztési egység.
