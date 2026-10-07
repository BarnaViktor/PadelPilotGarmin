# Padel Pilot 1.3.0 — produkciós kiadás

Dátum: 2026-10-07. Előző stabil kiadási csomag: 1.2.0.
A csomag a meglévő tíz támogatott SDK-profilra készül; a készüléklista
és az API-minimum nem változik.

## Feltölthető fájl

[`dist/releases/1.3.0/padel-pilot-1.3.0.iq`](../../dist/releases/1.3.0/padel-pilot-1.3.0.iq)

A produkciós alkalmazásazonosító `e6b2455dd36646098e6f53e16d77df8f`.
API-minimum: 3.4.0. A főmenü és a csomag verziója a `VERSION` fájlból
származik; a Store verziómezőjébe **1.3.0** kerüljön.
Az aláírókulcs nem része a kiadási mappának.

## Változások az 1.2.0-hoz képest

- A módválasztó UP gombja felfelé, DOWN gombja lefelé lép.
- Americano/Mexicano SAVE MATCH és korai SAVE & END, megerősített eldobással.
- Pontmódos lezárt/félbehagyott előzmény, törlés, egyedi pont- és időadatok;
  közös 20 meccses korlát a klasszikus rekordokkal.
- Külön DRAWS mutató; döntetlen befejezett meccs, nem vereség vagy félbehagyás.
- Pontmódos Garmin `racket/padel` FIT, közvetlen pontokkal, móddal,
  szabállyal, X-szel, kezdő csapattal és eredménnyel; szünet/folytatás és undo.
- Mentési/indítási hibák újrapróbálhatók. A már elmentett FIT utáni
  előzményhibát külön checkpoint őrzi, így újraindítás sem hoz létre új FIT-et.
- Régi klasszikus és pontmódos mentések olvasása megmarad.

A módok egy saját, kétcsapatos meccset kezelnek. Tornaszervezés, partnerváltás
és rangsor nincs. Rendes alkalmazásleállás menti a pillanatnyi FIT-szegmenst;
folytatás új szegmenst indít, a helyi pontok és meccsidő megőrzésével.
A Garmin mintavételezése miatt egy gyors ponthoz nem garantálható külön
record-időbélyeg; a session pontösszegek a mentett végállást adják.
Részletek: [FIT-adatszerződés](../am7-fit-contract.md).

## Ellenőrzés és kiadási bizonyítékok

A kiadási mappa a fordítási/tesztjegyzőkönyveket, archívumellenőrzést,
készülékbuildjeit, forráshash-eket és SHA-256 listát tartalmazza.
A készülék- és exportmátrix: `device-matrix.json`, `release-info.json`.

A kiadást megelőző AM-7 kör FR265/Enduro profilon 116/116 teszttel,
54 tényleges FIT-fájl és két külön lezárt helyreállítási FIT visszaolvasásával
ellenőrzött. Endurón a 20 rekordos FIT-terhelés megfigyelt memóriamaximuma
86,9 / 123,8 kB volt. Ezek szimulátoros eredmények; valós órás FIT/Connect,
memória- és akkumulátorpróba külön nyitott.

Store-publikálás nem történt a csomag elkészítésével.
A [magyar/angol újdonságok](../../store/whats-new-1.3.0.md) és a
[Store-leírás](../../store/store-listing.md) használhatók a meglévő
produkciós Store-bejegyzés frissítéséhez.

Következő fejlesztési egység: **I2-1**, Instinct 2 korlátok és vizuális tokenek.
