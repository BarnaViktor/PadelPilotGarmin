# Támogatott készülékek

## Éles támogatás és aktív bővítés

A jelenlegi fejlesztési, szimulátoros és első Store-kiadási célkészülék:

- Garmin Forerunner 265 (`fr265`).

Ennek oka, hogy a felületet 416 × 416 pixeles, kerek AMOLED-kijelzőre és az
ötgombos UP/DOWN/START/BACK vezérlésre terveztük. Az `1.1.0` Store-kiadás
kizárólag a Forerunner 265 modellt támogatja; a felhasználó az éles kiadást
saját használatra megfelelőnek találja, működési hibát nem tapasztalt.
A következő, első prioritású bővítés további Garmin órák támogatása.
További készülék a megjelenítési és működési kompatibilitás külön
ellenőrzése után kerülhet a kiadási manifestbe.

## Első kör – fordítás és szimulátoros tesztek

A Connect IQ SDK 9.2.0 helyi készülékprofiljai alapján az alábbi modellek
azonos 416 × 416-as kerek AMOLED-felületet, 768 KiB watch-app memóriakeretet és
a szükséges fizikai gombokat kínálják. A 2026-09-13-i ellenőrzésen mindegyikre
sikeresen lefordult az optimalizált PRG és a tesztbuild, és készülékenként
mind az 51 egységteszt sikeres volt (összesen 357, az FR265 kontrollal).
Kódbázis: `1.1.0`, `9df380b` Git-alap, a munkafában bővített fejlesztői
parancsokkal; az alkalmazás Monkey C forrása ebben a körben nem változott.

| Készülékazonosító | SDK-név | API-szint | Érintés | Állapot |
|---|---|---:|---:|---|
| `fr265` | Forerunner 265 | 5.2 | igen | 1.1.0 éles; 2026-09-14: 55/55 kontrollteszt |
| `d2mach1` | D2 Mach 1 | 5.2 | igen | PRG + 51/51 teszt; UI és órás próba nyitott |
| `epix2` | epix Gen 2 / quatix 7 Sapphire | 5.2 | igen | PRG + 51/51 teszt; UI és órás próba nyitott |
| `epix2pro47mm` | epix Pro Gen 2 47mm / quatix 7 Pro | 5.2 | igen | PRG + 51/51 teszt; UI és órás próba nyitott |
| `fenix843mm` | fēnix 8 43mm | 6.0 | igen | PRG + 51/51 teszt; UI és órás próba nyitott |
| `fenixe` | fēnix E | 6.0 | igen | PRG + 51/51 teszt; UI és órás próba nyitott |
| `instinct3amoled50mm` | Instinct 3 AMOLED 50mm | 6.0 | nem | PRG + 51/51 teszt; UI és órás próba nyitott |

A fordító a meglévő dinamikus konténerhozzáférésekhez típusellenőrzési
figyelmeztetéseket adott; fordítási hiba és sikertelen teszt nem volt.
A fordítási naplók és a pontos binárisazonosítók a futások `build/`
almappáiban találhatók.

A D2 Air X10, Venu 2 és Venu 2 Plus felbontása megfelelő, de nincs meg a
jelenlegi gombvezérléshez szükséges teljes fizikai gombkészlet, ezért nem
jelöltek. A Forerunner 265S 360 × 360-as felbontása külön reszponzív UI-munkát
igényel.

A felbontásokat és API-szinteket a
[Garmin kompatibilitási listájával](https://developer.garmin.com/connect-iq/compatible-devices/)
is összevetettük. A gombkészlet és memóriakeret ellenőrzésének forrása a
telepített SDK `Devices/<id>/simulator.json` és `compiler.json` profilja.

## Enduro család – kifejezett támogatási cél

A felhasználó kérésére az Enduro család is az első prioritású
készülékbővítés része. Mindhárom generáció 280 × 280-as, 64 színű MIP
kijelzőt és a szükséges fizikai gombokat használja. Az API-/kijelzőadatokat
a [Garmin készüléklistája](https://developer.garmin.com/connect-iq/compatible-devices/),
a memóriakereteket a helyi SDK-profilok alapján rögzítettük.

| Modell | SDK-azonosító | API-szint | Watch-app memória | Teendő |
|---|---|---:|---:|---|
| Enduro | `enduro` | 3.4 | 128 KiB | adapter + 55/55 teszt + teljes UI/gomb + 200+ pontos memóriapróba; valós órás próba nyitott |
| Enduro 2 | `fenix7x` | 5.2 | 768 KiB | adapter + 55/55 teszt + natív font/szín/gomb próba; valós órás próba nyitott |
| Enduro 3 | `enduro3` | 6.0 | 768 KiB | adapter + 55/55 teszt + natív font/szín/gomb próba; valós órás próba nyitott |

Az Enduro 2 a Garmin SDK-ban a fēnix 7X-szel közös készülékprofilhoz
tartozik; külön `enduro2` termékazonosítót nem használunk.

Az eredeti Enduro fordítása a jelenlegi `minApiLevel="4.1.6"` mellett
API-eltéréssel leáll. A külön tesztmanifest `3.4.0` API-minimumával viszont
az optimalizált alkalmazás lefordult, és az 51 teszt is sikeres volt.
Ez a 2026-09-13-i, SDK 9.2.0-val végzett kísérleti ellenőrzés eredménye;
a kiadási manifestelemek API-minimuma továbbra is `4.1.6`.
A régi generáció támogatásához a teljes UI API-kompatibilitását és a
128 KiB-os futásidejű memóriakeretet is ellenőrizni kell.
A kisebb PRG-fájlméret önmagában nem bizonyítja,
hogy az alkalmazás futás közben belefér ebbe a memóriába.

A felület adaptációja és szimulátoros ellenőrzése mindhárom Enduro
generáción elkészült. A modellek csak a valós órás meccs-, FIT-/Connect-,
olvashatósági és akkumulátorpróba után kerülhetnek a kiadási manifestbe.

### 2026-09-14 – Enduro-adapter és elrendezési tesztek

A `PadelTheme.canvas()` a 280 × 280-as kijelzőn a `PadelScaledCanvas`
adaptert adja a hat közös nézetnek. A koordinátákat és alakzatokat a
416-as tervből a natív kijelzőre képezi le; köztes bitmapet nem foglal.
A natív rendszerbetűket használja. A 416-as AMOLED-kijelző közvetlenül a
korábbi rajzolási kontextussal működik. Az Instinct 2-höz ez az adapter
nem aktiválódik, annak külön feladata a 4. prioritásban marad.

Az Enduro főmenüje és több beállítási nézete natívan megjelent a
szimulátorban. A számérték-szerkesztő Unicode mínuszjele hiányzó karaktert
adott; ezt ASCII `-` jelre cseréltük. A kezdeti képernyőn a szimulátor
48,1 / 123,8 kB memóriahasználatot jelzett; ez nem hosszú meccses mérés.

A `DisplayLayoutTests.mc` négy új tesztje a főmenü, beállítások,
pontozás, szünet, szervaválasztás, megerősítések, visszaállítás,
összegzés és előzmény vizsgált állapotaiban ellenőrzi a rajzolási
koordinátákat 280-as, illetve 416-os kijelzőhatárok mellett.
Mindhárom Enduro-profilon és FR265-ön 55/55 teszt sikeres.
A teszt rajzolási helyettesítőt használ: nem méri a natív szöveg
kiterjedését, kontrasztját, a kör alakú maszkot vagy az átfedéseket.

A 2026-09-14-i első kattintássorozat nem volt megbízható; az akkori
`build/ui-review-2026-09-14/enduro/` fájlnevek ezért továbbra sem
tesztbizonyítékok.

### 2026-09-17 – natív Enduro UI- és memóriapróba

A Wayland-kompozitor natív bemenetével az eredeti Endurón végigjártuk a
beállítások, pontozás, undo, szünet, szervaválasztás, megerősítések,
befejezett meccs, összegzés, mentés, előzmény, törlés és újraindítás utáni
visszaállítás állapotait. A javított ASCII mínusz és a hosszú feliratok
olvashatók, a körmaszk nem vágja őket, az MIP-színek elkülönülnek.

Az Enduro 2 és Enduro 3 natív skinjén a főmenü, beállítás, számérték-
szerkesztő, hosszú választó, élő pontozás, szünet és megerősítés mintája
szintén rendben volt. Élő meccsnél 42,1 / 763,6 kB, illetve
42,2 / 763,6 kB memóriahasználatot mutattak.

Az első Endurón 220 pontbeviteli esemény terhelte a mérkőzés- és undo-
állapotot. A 200-as sorozatból egy eseményt a bemenetvédelem kihagyott,
ezért a plusz 20 esemény biztosította a 200+ rögzített pontot. A kijelzett
memória 52,0 / 123,8 kB-ról 61,1 / 123,8 kB-ra nőtt; tíz undo után
56,6 / 123,8 kB volt. A megállított hosszú meccs mentése, előzményének
megjelenítése és törlése sikerült. A befejezett meccs összegzőjén látott
maximum 61,3 / 123,8 kB. Összeomlás vagy állapotromlás nem történt.

A képernyőképek és contact sheetek a gitignored
`build/ui-review-2026-09-17/` könyvtárban vannak. A pontos útvonalakat és
a következő belépési pontot a [fejlesztési átadás](development-handoff.md)
rögzíti. Ezek szimulátoros eredmények; a valós órás kapu nyitott marad.

## Instinct 2 – külön grafikai adaptációs feladat

Állapot: **felírva, megvalósítás és készülékes ellenőrzés előtt**.
A felhasználó kifejezett támogatási célként kérte az Instinct 2-t, a
kijelzőtípusból adódó grafikai eltérések külön kezelésével. A felhasználó
által megadott sorrendben ez a **4. prioritás**: az Americano/Mexicano után,
a saját szinkron és webes felület előtt következik. Az első készülékbővítési
kör az AMOLED-jelölteket és az Enduro családot viszi tovább.

Az `instinct2` profil 176 × 176 pixeles, kétszínű MIP-kijelzőt használ,
`semi-octagon` geometriával és API 3.4 támogatással a
[Garmin készüléklistája](https://developer.garmin.com/connect-iq/compatible-devices/)
szerint. A helyi SDK-profil alapján a watch-app memóriakeret 96 KiB,
érintés nincs, az UP/DOWN/START/BACK fizikai gombok rendelkezésre állnak.

Teendők:

- [ ] Önálló monokróm elrendezés kialakítása a 176 × 176-as hasznos
  kijelzőterületre, a geometria és a takart területek ellenőrzésével.
- [ ] A csapatok, szerváló, kijelölés és megerősítés egyértelmű jelölése
  szöveggel, formával vagy inverz megjelenítéssel; a jelenlegi cián/piros/lime
  színek jelentésének átültetése kétszínű kijelzésre.
- [ ] Betűméretek, sortörések, menüsorok és lapozás újratervezése; a
  pontállás játék közbeni gyors leolvashatóságának megőrzése.
- [ ] Monokróm ikonok, trófeák és megerősítő grafikák előkészítése;
  bitmap-erőforrások méretének és kontrasztjának ellenőrzése.
- [ ] API 3.4-re készülő kísérleti build, a tesztcsomag futtatása és a
  96 KiB-os memóriahatár mérése hosszú meccs és feltöltött undo mellett.
- [ ] Minden képernyő és gombművelet bejárása szimulátorban, majd valós órán;
  FIT-mentés, szinkron, olvashatóság és akkumulátor ellenőrzése.

Tervezési döntés: a pontozási és mentési logika közös marad, a megjelenítés
készülékprofilhoz igazodik. A 416-as AMOLED-felület egyszerű lekicsinyítése
nem tekinthető kész Instinct 2-adaptációnak. Fordítási vagy teszteredményt
ehhez a modellhez még nem rögzítettünk; éles támogatás a felvételi feltételek
teljesítése után jelölhető.

## Ellenőrzés megismétlése

Nyitott Connect IQ szimulátor mellett:

```bash
python3 scripts/dev.py build --device epix2
python3 scripts/dev.py test --device epix2
python3 scripts/dev.py build --device fenix7x  # Enduro 2
python3 scripts/dev.py test --device enduro3
python3 scripts/dev.py build --device enduro --min-api 3.4.0
python3 scripts/dev.py test --device enduro --min-api 3.4.0
```

A `--device` a táblázat bármely készülékazonosítójával használható.
A kiadási manifestben még nem szereplő modell külön tesztmanifestet kap,
a meglévő béta alkalmazásazonosítójával. A PRG, a naplók és az SHA-256
azonosítót tartalmazó `build-info.json` a kiírt `build/` almappába kerülnek.
Az ilyen futás `experimental: true` jelölésű. A szimulátoros tesztek a
pontozási, mentési és aktivitásrögzítési kódot ellenőrzik; a képernyők
vizuális és gombos bejárása külön ellenőrzés.

A `--min-api` kizárólag a kiadási manifestben még nem szereplő készülék
kísérleti buildjénél vagy tesztjénél használható. Az alkalmazott minimum
a `build-info.json` `min_api_level` mezőjébe kerül.

Az eltérő felbontású órák a következő UI-adaptációs körbe kerülnek.
A jelenlegi nézetekben sok rögzített koordináta van, ezért például a
360 × 360-as Forerunner 265S támogatásához önmagában a fordítás nem elég.

## Új készülék felvételi kapuja

Egy jelölt csak akkor kerülhet a kiadási manifestbe, ha:

1. normál és tesztbuildje sikeres;
2. a teljes egységtesztcsomag lefut a készülék szimulátorán;
3. minden képernyőn ellenőrzött a levágás és olvashatóság;
4. a fizikai gombkiosztás végig használható;
5. legalább egy teljes valós meccs és FIT-szinkron sikeres az adott modellen.
