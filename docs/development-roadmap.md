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

Aktív fejlesztési egység: **készüléktámogatás bővítése**.
A készülékenkénti állapot: [supported-devices.md](supported-devices.md).

2026-09-14-i folytatási állapot: elkészült a közös nézetek 280 pixeles
rajzolási adaptere, amely köztes teljes képernyős bitmap nélkül működik.
Az Enduro beállítóképernyőjén hiányzó Unicode mínuszjelet ASCII mínuszra
cseréltük. Négy új elrendezési teszttel a csomag 55 tesztesre bővült;
az Enduro, Enduro 2 (`fenix7x`), Enduro 3 és FR265 profilján 55/55 sikeres.
A teljes natív vizuális/gombos bejárás és a valós órás mérés még nyitott.
Az új chat konkrét belépési pontja: [fejlesztési átadás](development-handoff.md).

## Codex munkamenet egy checkpointon belül

1. kiválasztunk egy szűk, ellenőrizhető célt;
2. rögzítjük az elfogadási feltételeket;
3. Codex implementálja a kódot és a teszteket;
4. lefut a szimulátoros, majd a valós órás ellenőrzés;
5. dokumentáljuk a döntést és lezárjuk a checkpointot;
6. csak ezután indul a következő fejlesztési egység.
