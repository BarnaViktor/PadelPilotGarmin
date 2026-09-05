# Támogatott készülékek

## Jelenlegi fejlesztési cél

A jelenlegi fejlesztési, szimulátoros és első Store-kiadási célkészülék:

- Garmin Forerunner 265 (`fr265`).

Ennek oka, hogy a felületet 416 × 416 pixeles, kerek AMOLED-kijelzőre és az
ötgombos UP/DOWN/START/BACK vezérlésre terveztük. Az `1.1.0` Store-kiadás
kizárólag a Forerunner 265 modellt támogatja, és a valós órás elfogadási
tesztet is ezen végezzük. További készülék csak a megjelenítési és működési
kompatibilitás külön ellenőrzése után kerülhet a manifestbe.

## Fordítási jelöltek

A Connect IQ SDK 9.2.0 helyi készülékprofiljai alapján az alábbi modellek
azonos 416 × 416-as kerek AMOLED-felületet, 768 KiB watch-app memóriakeretet és
a szükséges fizikai gombokat kínálják. Ideiglenes tesztmanifesttel mindegyikre
sikeresen lefordult az alkalmazás.

| Készülékazonosító | SDK-név | API-szint | Érintés | Állapot |
|---|---|---:|---:|---|
| `fr265` | Forerunner 265 | 5.2 | igen | 1.1.0 támogatott |
| `d2mach1` | D2 Mach 1 | 5.2 | igen | fordítható jelölt |
| `epix2` | epix Gen 2 / quatix 7 Sapphire | 5.2 | igen | fordítható jelölt |
| `epix2pro47mm` | epix Pro Gen 2 47mm / quatix 7 Pro | 5.2 | igen | fordítható jelölt |
| `fenix843mm` | fēnix 8 43mm | 6.0 | igen | fordítható jelölt |
| `fenixe` | fēnix E | 6.0 | igen | fordítható jelölt |
| `instinct3amoled50mm` | Instinct 3 AMOLED 50mm | 6.0 | nem | fordítható jelölt |

A D2 Air X10, Venu 2 és Venu 2 Plus felbontása megfelelő, de nincs meg a
jelenlegi gombvezérléshez szükséges teljes fizikai gombkészlet, ezért nem
jelöltek. A Forerunner 265S 360 × 360-as felbontása külön reszponzív UI-munkát
igényel.

## Új készülék felvételi kapuja

Egy jelölt csak akkor kerülhet a kiadási manifestbe, ha:

1. normál és tesztbuildje sikeres;
2. a teljes egységtesztcsomag lefut a készülék szimulátorán;
3. minden képernyőn ellenőrzött a levágás és olvashatóság;
4. a fizikai gombkiosztás végig használható;
5. legalább egy teljes valós meccs és FIT-szinkron sikeres az adott modellen.
