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
szemléletű pontbevitel, valamint a szünet/folytatás, kézi szerválócsapat-váltás
és megerősített meccsleállítás. Még nem készült el: oldalcsere és no-ad
fogadóoldal-választás.

## C2 – Helyi mentés és visszaállítás

Állapot: elkészült és Forerunner 265 szimulátorban ellenőrizve.

- meccsállapot tartós mentése;
- alkalmazás bezárása utáni folytatás;
- lezárt meccsek rövid előzménye;
- hibás vagy félbemaradt mentés kezelése.

A mentési formátum verziózott. Az aktív meccs pont-, game-, szett-, tie-break-,
szerva- és időállapota minden változás után frissül, valamint az alkalmazás
leállásakor is mentődik. Újraindításkor a meccs folytatható vagy elvethető;
a folytatás biztonsági okból szüneteltetett állapotban indul. A hibás aktív
mentés törlődik, a hibás előzményrekordok pedig kimaradnak a listából.

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
szetteredmény. A pause megállítja, a folytatás újraindítja a FIT időzítőt.

Technikai korlát: a Garmin ActivityRecording session objektuma folyamatok
között nem állítható vissza. Ha az alkalmazás aktív meccs közben teljesen
bezáródik, az addigi FIT-rész biztonságosan lezárul és mentődik; a C2-ből
visszaállított meccs új FIT-szegmenst kezd. A pontozási állapot ettől még
folyamatosan helyreáll.

## C4 – Valós órás MVP

Becsült idő: 1–2 hét.

- valós meccsek tesztelése;
- véletlen gombnyomások és izzadt kéz kezelése;
- olvashatóság napfényben és sötétben;
- memória- és akkumulátormérés;
- támogatott készüléklista;
- Connect IQ Store előkészítés.

## Későbbi ágak

- Americano lebonyolítás;
- Mexicano lebonyolítás;
- saját Laravel API;
- Vue statisztikai webalkalmazás;
- részletes többmeccses elemzések.

## Codex munkamenet egy checkpointon belül

1. kiválasztunk egy szűk, ellenőrizhető célt;
2. rögzítjük az elfogadási feltételeket;
3. Codex implementálja a kódot és a teszteket;
4. lefut a szimulátoros, majd a valós órás ellenőrzés;
5. dokumentáljuk a döntést és lezárjuk a checkpointot;
6. csak ezután indul a következő fejlesztési egység.
