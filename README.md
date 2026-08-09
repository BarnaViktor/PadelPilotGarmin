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
- aktív meccs automatikus helyi mentése és alkalmazás-újraindítás utáni
  folytatása;
- legfeljebb 20 lezárt meccset mutató helyi előzmény;
- sérült aktív mentések és előzményrekordok biztonságos kiszűrése;
- Garmin FIT-aktivitás `racket/padel` besorolással;
- pulzus-, kalória- és aktivitásidő-rögzítés;
- pontesemények, szetteredmények és győztes egyedi FIT-mezőkben;
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

- UP/DOWN: menüpont kiválasztása;
- START: a kiválasztott beállítás megnyitása;
- a beállításon belül UP/DOWN: érték módosítása;
- a beállításon belül START: mentés, BACK: módosítás elvetése;
- START GAME menüponton START: meccs indítása.
- MATCH HISTORY menüponton START: a legutóbbi lezárt meccsek megnyitása.

Alkalmazás-újraindítás után:

- érvényes aktív mentésnél START és a zöld pipa folytatja a meccset;
- DOWN és a piros X elveti az aktív mentést;
- a folytatott meccs szüneteltetett állapotban nyílik meg.

Meccs közben:

- DOWN: pont a saját csapatnak;
- UP: pont az ellenfél csapatának;
- BACK: utolsó pont visszavonása.
- START/STOP: szünetmenü megnyitása.

A meccs indításakor egy Garmin FIT-aktivitás is elindul. Szünetben a FIT-időzítő
megáll, folytatáskor újraindul. A meccs mentése a FIT-aktivitást is menti, az
elvetés pedig a FIT-rögzítést is eldobja.

Szünet közben:

- UP/DOWN: választás a szerváló oldal módosítása és a meccs leállítása között;
- START a szerváló oldal módosításán: négy pályanegyedes választó megnyitása;
- a megérintett negyed meghatározza a szerváló csapatot és a jobb/bal oldalt,
  majd a játék azonnal folytatódik;
- START a meccs leállításán: megerősítő kérdés megnyitása;
- a megerősítésnél START és a zöld pipa leállítja, DOWN és a piros X
  visszalép a szünetmenübe;
- BACK: folytatás.

## Meccskijelző

- az oszlopok rendre a szettet (`S`), game-et (`G`) és pontot (`P`) mutatják;
- a felső piros sor az ellenfél, az alsó zöld sor a saját csapat eredménye;
- a külső színes negyedív jelzi a szerváló csapatot és az automatikusan
  váltakozó jobb/bal szervaoldalt;
- a meccs végén lapozható összegzés mutatja a végeredményt, az időtartamot és
  a szettenkénti bontást.
- az összegzésen START nyitja meg a mentési kérdést; a kijelzőszéli zöld pipa
  a START gombnál menti helyben, a piros X a DOWN gombnál elveti a meccset,
  majd mindkét művelet visszatér a beállításokhoz.

Az érintés a szünetmenü négy pályanegyedes szervaválasztójában szükséges;
a többi alapművelet gombokkal használható.

## Következő checkpoint

Valós órás MVP:

- valós meccsek tesztelése;
- FIT-fájl és Garmin Connect megjelenítés ellenőrzése;
- olvashatóság, memória és akkumulátor mérése;
- Connect IQ Store előkészítése.

Részletek: [docs/development-roadmap.md](docs/development-roadmap.md)
