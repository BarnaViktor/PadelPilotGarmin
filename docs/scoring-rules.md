# Pontozási szabálymodell

## Állapothierarchia

```text
Mérkőzés
└── Szett vagy döntő match tie-break
    └── Game vagy normál tie-break
        └── Pont
```

Az állapotgépet a Garmin felülettől külön kezeljük. A felület eseményt küld
(`TEAM_1_POINT`, `TEAM_2_POINT`, `UNDO`), a motor pedig visszaadja az új
állapotot. Ez teszi lehetővé, hogy később ugyanazt a motort más képernyő,
szimulátor vagy akár mobilalkalmazás is használja.

## Hagyományos game

- 0 → 15 → 30 → 40;
- 40–40 után előny;
- előnyben újabb nyert pont: game;
- előnyben elvesztett pont: vissza 40–40-re.

## No-ad game

- 0 → 15 → 30 → 40;
- 40–40-nél a következő pont megnyeri a game-et;
- a fogadóoldal kiválasztását a felület külön eseményként kezeli majd, mert az
  nem változtatja meg a pontozási eredményt.

## Normál szett

- legalább 6 nyert game;
- legalább 2 game különbség;
- 6–6-nál normál tie-break;
- a tie-break győztese 7–6-ra nyeri a szettet.

## Döntő match tie-break

Ha mindkét csapat egy szettgyőzelemre áll a mérkőzés megnyerésétől, és a
beállítás `MATCH_TIEBREAK`, a következő teljes szett helyett közvetlenül a
beállított célpontszámú tie-break indul.

## Szervarend

- A kezdő adogató csapat a meccsbeállítás része.
- Normál game után a szerváló csapat vált.
- A motor csapatonként 1/2 szerváló sorszámot követ, hogy ugyanazon csapat
  következő adogatóját is jelezni tudja.
- Tie-breakben az első pontot a következő soron lévő szerváló csapat adogatja,
  majd két pontonként vált a szerváló csapat.
- Normál tie-break után a következő szettet az a csapat kezdi adogatással,
  amelyik a tie-break első pontját fogadta.

## Undo

Minden elfogadott pont előtt teljes állapot-pillanatkép készül. Az undo ezt
állítja vissza, ezért game-, szett- és mérkőzéslezárás után is pontosan működik,
beleértve a szerváló csapatot és a csapaton belüli szerváló sorszámot is.
Később memóriaoptimalizálásként a teljes snapshot eseménynaplóra cserélhető.
