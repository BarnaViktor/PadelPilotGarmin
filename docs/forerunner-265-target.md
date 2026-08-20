# Forerunner 265 célkészülék

Állapot: C1 célkészülék.

## Ellenőrzött eszközadatok

- Connect IQ kompatibilitás: Forerunner 265 támogatott Connect IQ eszköz, API
  level 5.2.
- Kijelző: 416 x 416 pixeles, kerek AMOLED.
- Forerunner 265S eltérés: 360 x 360 pixeles, kerek AMOLED. A C1 célja a
  normál Forerunner 265, nem a 265S.
- Fizikai vezérlés: LIGHT, UP, DOWN, START/STOP és BACK gomb.
- Érintés: a kézikönyv szerint a kijelzőn lehet koppintani, görgetni és jobbra
  húzással visszalépni; az érintés általános használatra és aktivitásokra külön
  testreszabható, illetve kikapcsolható.
- Általános memória/előzmény tárhely: 8 GB a Garmin termék-összehasonlító
  alapján.
- Connect IQ appkorlátok: a Garmin az alkalmazások számát és tárhelyét
  eszközönként korlátozza, a Connect IQ Store szabályozza. Ez külön kezelendő
  az óra általános 8 GB-os tárhelyétől. A pontos Forerunner 265 futásidejű
  app-memóriakeretet ebben a fejlesztői környezetben nem sikerült helyi SDK-ból
  kiolvasni, mert a Connect IQ SDK nincs telepítve.

Források:

- Garmin Connect IQ Compatible Devices:
  https://developer.garmin.com/connect-iq/compatible-devices/
- Garmin Forerunner 265 Series Watch Owner's Manual, Overview:
  https://www8.garmin.com/manuals/webhelp/GUID-F41EAFB3-6CC9-42DE-9C6C-9E358DBB0671/EN-US/GUID-F04730B5-B214-4E08-AA64-61D1C197F35F.html
- Garmin Forerunner 265 Series Watch Owner's Manual, Touchscreen:
  https://www8.garmin.com/manuals/webhelp/GUID-F41EAFB3-6CC9-42DE-9C6C-9E358DBB0671/EN-US/GUID-C8435F75-31AA-497C-88E8-2944AA182AEA.html
- Garmin Support, Connect IQ App Limits:
  https://support.garmin.com/en-US/?faq=tFmJJnTfs83yuPc8kttAh7
- Garmin Product Compare, Forerunner 265:
  https://www.garmin.com/en-US/compare/?compareProduct=1611937&compareProduct=886785

## C1 gombkiosztás

Az alkalmazás kizárólag fizikai gombokkal használható.

Beállító képernyő:

- UP: előző beállítási mező;
- DOWN: következő beállítási mező;
- MENU: érték növelése vagy következő opció;
- BACK: érték csökkentése vagy előző opció;
- START/STOP: meccs indítása az aktuális beállításokkal.

Meccs képernyő:

- UP: pont az 1. csapatnak;
- DOWN: pont a 2. csapatnak;
- BACK: utolsó pont visszavonása.

Érintés a beállítás során:

- a beállító képernyőn koppintás a következő mezőre lép;
- húzás fel/le mezőt vált;
- húzás bal/jobbra értéket vált.

## C4 beviteli védelem

- Aktív meccs közben az érintés nem módosít állapotot, így izzadság vagy ruha
  sem tud véletlen pontot bevinni.
- A pontbevitel game és no-ad 40–40 után is automatikusan folytatódik.
- A kézi szerválóváltás opcionálisan, fizikai gombokkal érhető el.
- A négy pályanegyedes szervaválasztóban UP/DOWN mozgatja a kijelölést, START
  menti azt, BACK pedig visszalép.
- Az 500 ms-on belül ismétlődő pontgomb-eseményekből csak az első érvényes;
  undo után a védelem azonnal alaphelyzetbe áll.

## Ismert C1 korlátozások

- A csapaton belüli szerváló játékos csak 1/2 sorszámként jelenik meg, nincs
  játékosnév.
- No-ad 40–40-nél nincs külön fogadóoldal-választó.
- Nincs tartós mentés, aktivitásrögzítés, backend, webalkalmazás,
  szinkronizáció vagy hőtérkép.
- Fordítás és szimulátoros ellenőrzés csak telepített Connect IQ SDK-val
  végezhető el.
