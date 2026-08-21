# Padel Pilot

Garmin Connect IQ óraalkalmazás, amely a kiválasztott szabályok alapján
végigvezeti és rögzíti egy padelmérkőzés eredményét.

## Jelenlegi állapot

Verzió: **1.1.0**, helyi Forerunner 265 készülékteszteléshez. Ez még nem
Connect IQ Store-kiadás.

Az első helyi tesztkiadás elkészült:

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
- legfeljebb 20 pontnyi, memóriában korlátozott undo-előzmény;
- pont-, game-, szett- és meccsvégi rezgéses visszajelzés;
- aktív meccs automatikus helyi mentése és alkalmazás-újraindítás utáni
  folytatása;
- legfeljebb 20 lezárt meccset mutató helyi előzmény;
- sérült aktív mentések és előzményrekordok biztonságos kiszűrése;
- Garmin FIT-aktivitás `racket/padel` besorolással;
- GPS-nyomvonal, megtett távolság, valamint aktuális, átlagos és maximális
  sebesség rögzítése;
- aktuális, átlagos és maximális pulzus, kalória, aktivitásidő és az órán
  elérhető kadenciaadatok rögzítése;
- meccsvégi aktivitás-összegzés távolság-, sebesség-, pulzus- és
  kalóriaadatokkal;
- pontesemények, szetteredmények és győztes egyedi FIT-mezőkben;
- Monkey C egységtesztek a C1 pontozási és szervarend szabályokra.

A hőtérkép, az Americano, a Mexicano és a saját szerveres szinkron nem része
ennek a checkpointnak.

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

A pontbevitel game, szett, oldalcsere-helyzet és no-ad 40–40 után is
megszakítás nélkül folytatódik. A szerváló csapat vagy oldal csak a
szünetmenüből, opcionálisan bírálható felül.

A meccs indításakor egy Garmin FIT-aktivitás is elindul. Szünetben a FIT-időzítő
megáll, folytatáskor újraindul. A meccs mentése a FIT-aktivitást is menti, az
elvetés pedig a FIT-rögzítést is eldobja.

Szünet közben:

- UP/DOWN: választás a szerváló oldal módosítása és a meccs leállítása között;
- START a szerváló oldal módosításán: négy pályanegyedes választó megnyitása;
- UP/DOWN választ pályanegyedet, START menti a szerváló csapatot és a
  jobb/bal oldalt, majd a játék azonnal folytatódik;
- START a meccs leállításán: megerősítő kérdés megnyitása;
- a megerősítésnél START és a zöld pipa leállítja, DOWN és a piros X
  visszalép a szünetmenübe;
- BACK: folytatás.

## Meccskijelző

- a cián A és piros B oldal nagy számokkal mutatja a pontállást;
- felül a lezárt szettek, alul az aktuális set/game állás látható;
- a lime labdajelölés mutatja a szerváló csapatot;
- a meccs végén lapozható összegzés mutatja a végeredményt, az időtartamot és
  a szettenkénti bontást.
- az összegzésen START nyitja meg a mentési kérdést; a kijelzőszéli zöld pipa
  a START gombnál menti helyben, a piros X a DOWN gombnál elveti a meccset,
  majd mindkét művelet visszatér a beállításokhoz.

Meccs közben az érintés szándékosan nem módosít állapotot: minden művelet
fizikai gombbal végezhető. A gyorsan ismétlődő pontgomb-események közül csak
az első kerül feldolgozásra.

## Következő checkpoint

Valós órás MVP:

- valós meccsek tesztelése;
- FIT-fájl és Garmin Connect megjelenítés ellenőrzése;
- olvashatóság, memória és akkumulátor mérése;
- Connect IQ Store előkészítése.

Részletek: [docs/development-roadmap.md](docs/development-roadmap.md)
