# Garmin Padel

Garmin Connect IQ óraalkalmazás, amely a kiválasztott szabályok alapján
végigvezeti és rögzíti egy padelmérkőzés eredményét.

## Jelenlegi állapot

Az első fejlesztési checkpoint elkészült:

- készülékfüggetlen pontozási motor;
- Forerunner 265 célkészülék (`fr265`);
- gombvezérelt meccsbeállító képernyő;
- hagyományos advantage és no-ad / aranypont;
- 1, 3 vagy 5 szettes mérkőzés;
- normál szettek 6–6-os tie-breakkel;
- döntő teljes szett vagy match tie-break;
- beállítható tie-break célpontszám;
- kétpontos különbség;
- kezdő adogató csapat;
- szerváló csapat és csapaton belüli szerváló sorszám követése;
- utolsó pont visszavonása;
- pont-, game-, szett- és meccsvégi rezgéses visszajelzés;
- Monkey C egységtesztek a C1 pontozási és szervarend szabályokra.

A hőtérkép, az Americano, a Mexicano, a FIT-aktivitás és a szerveres
szinkron nem része ennek a checkpointnak.

## Projektstruktúra

```text
garmin-padel/
├── docs/                       termék- és fejlesztési döntések
├── resources/                  Connect IQ erőforrások
├── source/
│   ├── domain/                 készülékfüggetlen pontozási logika
│   ├── tests/                  Monkey C egységtesztek
│   └── ui/                     Garmin-specifikus nézet és gombkezelés
├── manifest.xml
└── monkey.jungle
```

## Fejlesztői környezet

Szükséges:

1. Visual Studio Code;
2. Garmin Connect IQ bővítmény;
3. Connect IQ SDK Managerrel telepített aktuális SDK;
4. Garmin developer key a fordításhoz.

A repository jelenlegi célkészüléke a Forerunner 265 (`fr265`). A Garmin
kompatibilitási táblája szerint a Forerunner 265 Connect IQ API level 5.2
eszköz, 416 x 416 pixeles kerek AMOLED kijelzővel. Részletek:
[docs/forerunner-265-target.md](docs/forerunner-265-target.md).

## Gombkiosztás

Beállítás:

- UP/DOWN: mező kiválasztása;
- MENU és BACK: érték módosítása;
- START/STOP: meccs indítása.

Meccs közben:

- UP: pont az 1. csapatnak;
- DOWN: pont a 2. csapatnak;
- BACK: utolsó pont visszavonása.

Az érintés csak kiegészítő lehetőség; az alkalmazás teljesen használható
gombokkal.

## Következő checkpoint

Helyi mentés és visszaállítás:

- meccsállapot tartós mentése;
- alkalmazás bezárása utáni folytatás;
- lezárt meccsek rövid előzménye;
- hibás vagy félbemaradt mentés kezelése.

Részletek: [docs/development-roadmap.md](docs/development-roadmap.md)
