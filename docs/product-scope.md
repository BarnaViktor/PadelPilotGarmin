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


## Következő bővítés – Americano / Mexicano saját meccs

2026-10-04-i felhasználói döntés: az óra kizárólag egy saját mérkőzés
pontjait számolja és azt vezesse végig. A bővítés a saját csapat és az
ellenfél pontállását, undo-t, szünetet, eredményt és meccsmentést kezeli.
Tornaszervezés, párosítás, partnerrotáció, fordulósorozat, más pálya
eredménye, játékoslista és ranglista nem része a funkciónak.

AM-1 lezárva: meccs előtt választható közös összpontszám (A+B=X) vagy
csapatcél (A=X vagy B=X), megadható pozitív egész X és kezdő csapat.
A meccs a választott pontszabály teljesülésekor ér véget. A részletek és
elfogadási példák az [AM-1 specifikációban](americano-mexicano-spec.md)
vannak. AM-2 elkészült: önálló pontozási domain, két szabály, eredmény és
20 pontos undo. AM-3 is elkészült: módválasztó, két szabály, egyesével
állítható 1–999 X (alapérték 24), kezdő A/B és új 0–0-s meccs indítása.
AM-4 elkészült: DOWN/UP pontbevitel 500 ms-os védelemmel, 20 pontos
undo, szünet, aktív játékidő és WIN/LOSS/DRAW eredmény; a lezáró pont
visszavonása újranyit. Eldobás külön megerősítéssel, NO alapértékkel.
AM-5 is elkészült: verziózott aktív mentés, pontállás és pontos játékidő
helyreállítása, újraindítás után szüneteltetett folytatás vagy eldobás.
A korábbi klasszikus mentések olvashatók maradnak. Az undo-napló
újraindításkor üres; a lezárt meccs eredménye és ideje megmarad.
Az új módok előzménye és FIT-je AM-6/AM-7 feladata.
Az első kiadás klasszikus meccsscope-ja változatlan.
