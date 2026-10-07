# AM-7 – Pontmódos FIT-adatok

Az Americano/Mexicano saját meccs Garmin-aktivitása `racket/padel` besorolású.
A normál indítás egy aktivitást hoz létre. A szünet és az eredményképernyő
megállítja a FIT-időzítőt; folytatás és a lezáró pont undo-ja újraindítja.
A SAVE MATCH és SAVE & END először a FIT-et, majd a helyi előzményt menti.
DISCARD az aktuális FIT-szegmenst és az aktív helyi állapotot dobja el.

## Developer mezők

A klasszikus 0–6 mezőazonosítók megmaradnak. Pontmódban csak a 0 és az 5,
valamint a 7–15 mezők jönnek létre: összesen 11 mező, 13 bájtos record- és
61 bájtos session-adattal. A pontok UINT32 értékek, így 255 felett sem
csonkolódnak. Pontmódban nincs szett/game developer mező vagy alkalmazás
által létrehozott szettlap; a platform alapértelmezett lezáró lapja nem szett.

| ID | Mező | FIT-üzenet | Jelentés |
|---|---|---|---|
| 0 | `point_event` | record | 0: nincs új esemény; 1: A pont; 2: B pont; 3: undo |
| 5 | `winner` | session | `-`, `My team`, `Opponent`, `Draw`, `Stopped`, `Interrupted` |
| 7 | `match_mode` | session | `AMERICANO` vagy `MEXICANO` |
| 8 | `end_rule` | session | `TOTAL_POINTS` vagy `TEAM_TARGET` |
| 9 | `point_target` | session | X |
| 10 | `first_server` | session | 0: A; 1: B |
| 11 | `my_points` | record | A aktuális meccspontjai |
| 12 | `opponent_points` | record | B aktuális meccspontjai |
| 13 | `my_match_points` | session | A pontjai a szegmens végén |
| 14 | `opponent_match_points` | session | B pontjai a szegmens végén |
| 15 | `point_sequence` | record | A szegmensben elfogadott pont/undo események sorszáma |

A döntetlen befejezett meccs, `winner = Draw`; félbehagyásnál `Stopped`.
Alkalmazásleálláskor egy aktív meccs szegmense `Interrupted`, a már befejezett
meccs WIN/LOSS/DRAW eredménye megmarad.

A FIT record mezők a Garmin mintavételezésével íródnak. A `setData()` új
értéke felülírhat egy még ki nem írt korábbi értéket, ezért az 500 ms-os
pontvédelmen átjutó bevitelhez sem garantálható külön, pontos időbélyeg.
Az eseményt csak megváltozott `point_sequence` esetén szabad újnak tekinteni;
sorszámugrásnál köztes események lehetnek. A session pontösszegek ettől
függetlenül a mentett végállást adják. [Garmin Field dokumentáció](https://developer.garmin.com/connect-iq/api-docs/Toybox/FitContributor/Field.html).

## Újraindítás és hibás mentés

A meglévő aktivitásszegmens-kezelés folytatódik: rendes alkalmazásleállás
menti és felszabadítja az aktuális FIT-szegmenst. Egy v4 aktív mentés
folytatása új, szüneteltetett FIT-szegmenst indít; a meccs pontjai és
helyi játékideje folyamatosak maradnak. A szegmens eseménysorszáma 0-ról
indul, a korábbi pontok nem válnak új eseménnyé. A session pontok a teljes
meccs aktuális pontjai; több szegmens pontösszegeit nem szabad összeadni.
A FIT natív időzítője szegmensenkénti, a helyi előzmény a teljes meccsidőt őrzi.
A korábban mentett szegmens egy későbbi DISCARD művelettel nem törölhető.

Sikertelen FIT-mentés vagy -eldobás megőrzi a rögzítőt és az aktív meccset,
és ugyanaz a művelet újrapróbálható. A FIT sikeres mentése után a pontállás
már nem változtatható, amíg a helyi előzmény mentése nem fejeződik be.

Ehhez külön, kizárólag befejezésre váró v5 aktív checkpoint készül:
`[5, elapsedMs, [mode, rule, X, startingTeam], [A, B], true]`.
A `true` azt jelenti, hogy a FIT már elkészült. Előzményhiba után újraindítva
a FINISH SAVE képernyő jön vissza, új FIT indítása nélkül. START újrapróbálja
az előzmény írását; pontbevitel, undo és eldobás ekkor nem módosít állapotot.
A klasszikus v1/v2/v3 és a normál pontmódos v4 aktív mentések olvashatók maradnak.

Az aktivitás API-jai és visszatérési értékei:
[Garmin Session dokumentáció](https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityRecording/Session.html).
Mentett fájlok ellenőrzéséhez a [Garmin FIT Python SDK](https://github.com/garmin/fit-python-sdk)
dekóderét használjuk, külön CRC-ellenőrzéssel és friss streamből olvasással.
