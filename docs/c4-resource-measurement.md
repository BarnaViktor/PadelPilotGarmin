# C4 – Memória- és akkumulátormérés

Állapot: szimulátoros memória-stresszteszt elkészült, valós órás mérés
szükséges.

## Memória

A pontozómotor legfeljebb 20 teljes állapot-pillanatképet őriz az undo számára.
Az ennél régebbi állapotok automatikusan kiesnek, ezért a pontszámmal együtt
nem nő korlátlanul a memóriafoglalás. A tesztcsomag egy 1000 pontos,
folyamatos deuce-helyzetet is végigjátszik, majd ellenőrzi a 20 lépéses
undo-korlátot.

A valós órás teszt előtt és után rögzítendő:

- a telepített PRG fájlmérete;
- a Connect IQ szimulátor induló memóriahasználata;
- a memóriahasználat meccsindítás után;
- a memóriahasználat legalább 200 pont után;
- történt-e out-of-memory hiba, újraindulás vagy érezhető lassulás.

Elfogadási feltétel: a 200 pontos állapot után is maradjon legalább 25% szabad
alkalmazásmemória, és a 20 pontos undo-ablak feltöltődése után a foglalás ne
növekedjen tovább pontonként.

## Akkumulátor

Az első valós meccs egyben előzetes akkumulátormérés. A meccs elején és végén
egész százalékban fel kell jegyezni a töltöttséget, valamint a FIT-aktivitás
időtartamát. A normalizált fogyasztás:

`fogyasztás óránként = (induló % - záró %) / időtartam órában`

A mérés feltételei:

- az óra ne legyen töltőn a kezdés előtti 30 percben;
- az akkumulátor induláskor 30–90% között legyen;
- maradjon a felhasználó szokásos fényerő-, értesítés- és csuklómozdulat
  beállítása;
- GPS-t vagy zenelejátszást csak akkor használj, ha az összehasonlító mérésben
  is aktív;
- jegyezd fel a firmware-verziót, a környezeti hőmérsékletet és minden más,
  párhuzamosan futó funkciót.

Az első mérés tájékoztató. Elfogadási döntéshez két, legalább 60 perces Padel
Pilot mérés és egy hasonló időtartamú natív padelaktivitás szükséges. A Padel
Pilot akkor felel meg, ha az átlagos óránkénti fogyasztása legfeljebb 2
százalékponttal magasabb a natív aktivitásénál, és egyik futás alatt sincs
váratlan újraindulás vagy 15%-nál nagyobb óránkénti fogyasztás.

## Mérési lap

| Mező | Pilot 1 | Pilot 2 | Natív kontroll |
|---|---:|---:|---:|
| Dátum | | | |
| Firmware | | | |
| Időtartam (perc) | | | |
| Induló akkumulátor (%) | | | |
| Záró akkumulátor (%) | | | |
| Fogyasztás (%/óra) | | | |
| GPS aktív | | | |
| Zene aktív | | | |
| Hőmérséklet | | | |
| Hiba vagy újraindulás | | | |
