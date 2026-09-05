# MVP termékscope

## Cél

Az óra a mérkőzés előtt kiválasztott szabályok alapján vezesse végig a
játékost a teljes padelmérkőzésen, csökkentse a fejben követendő állapotokat,
majd őrizze meg a végeredményt és a később definiált alapstatisztikákat.

## Első kiadás

### Meccsbeállítások

- mérkőzés: 1, 3 vagy 5 szettből a szükséges többség;
- kezdő adogató csapat;
- game-pontozás:
  - hagyományos advantage;
  - no-ad / aranypont;
- normál szett:
  - 6 nyert game;
  - legalább két game különbség;
  - 6–6-nál tie-break;
- döntő szett:
  - teljes szett;
  - match tie-break;
- normál és döntő tie-break célpontszám;
- minden tie-breakben legalább két pont különbség.

### Meccs közben

- pont az 1. csapatnak;
- pont a 2. csapatnak;
- utolsó pont visszavonása;
- aktuális pont-, game- és szettállás;
- pontos idő a meccsképernyő tetején;
- szerváló csapat és oldal;
- game-, szett- és mérkőzésvégi rezgés;
- szüneteltetés és folytatás;
- félbehagyott meccs eredményének és aktivitásának mentése, vagy a meccs
  mentés nélküli eldobása;
- hibás vagy véletlen bevitel elleni megerősítések.

### Elsőként tárolandó adatok

- végeredmény;
- szettenkénti eredmény;
- teljes játékidő;
- szettenkénti idő;
- összes pont és game;
- pontok időpontja;
- labdamenet becsült időtartama a két pontbevitel között;
- lezárt és félbehagyott meccsek helyi előzménye, egyenkénti törléssel.

## Nem része az első kiadásnak

- hőtérkép;
- automatikus pont- vagy ütésfelismerés;
- Americano;
- Mexicano;
- saját backend és webalkalmazás;
- ellenfél- vagy partnerprofilok;
- több mérkőzésből számított fejlődési statisztikák.

## Nyitott termékdöntések

1. Eldöntve: az első Store-kiadás kizárólag a Forerunner 265 modellt támogatja.
2. Az 1 szettes meccsnél értelmezhető legyen-e külön döntőszett-mód?
3. Eldöntve: no-ad 40–40-nél nincs külön fogadóoldal-választás; a
   következő pont megszakítás nélkül lezárja a game-et.
4. A „labdamenet ideje” a megelőző pont lezárásától vagy külön indítással
   számolódjon?
5. Kell-e a pontbevitelhez azonnali, rövid visszavonási képernyő?
