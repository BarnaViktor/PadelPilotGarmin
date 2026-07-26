# Fejlesztési ütemterv

## C0 – Projektalap és szabálymotor

Állapot: elkészült, SDK-val és célórával még fordítandó.

- Connect IQ projektstruktúra;
- domain és UI szétválasztása;
- advantage és no-ad;
- normál szett és tie-break;
- döntő teljes szett vagy match tie-break;
- undo;
- alapszabályok egységtesztjei.

Elfogadási feltétel: a tesztek Connect IQ szimulátorban lefutnak, a prototípus
két gombbal végigjátszható.

## C1 – Meccsbeállítás és stabil pontbevitel

Állapot: elkészült kódszinten, SDK-val és Forerunner 265 szimulátorral még
fordítandó.

- beállítóképernyők;
- Forerunner 265 célkészülék és készülékspecifikus gombkiosztás;
- kezdő adogató csapat;
- szervasorrend és tie-break szervaváltások;
- no-ad döntő pont;
- haptikus visszajelzés;
- pontozási edge case-ek teljes tesztkészlete.

C1-ben még nem készült el: oldalcsere, szünet/folytatás/feladás és no-ad
fogadóoldal-választás.

## C2 – Helyi mentés és visszaállítás

Becsült idő: 3–5 nap.

- meccsállapot tartós mentése;
- alkalmazás bezárása utáni folytatás;
- lezárt meccsek rövid előzménye;
- hibás vagy félbemaradt mentés kezelése.

## C3 – Garmin aktivitás és alapstatisztika

Becsült idő: 1–2 hét.

- FIT-aktivitás indítása és lezárása;
- padel sportbesorolás;
- pulzus, kalória és időtartam;
- eredmény és szettadatok egyedi FIT mezőkben;
- pont- és labdamenet-időpontok;
- Garmin Connect megjelenítés ellenőrzése.

## C4 – Valós órás MVP

Becsült idő: 1–2 hét.

- valós meccsek tesztelése;
- véletlen gombnyomások és izzadt kéz kezelése;
- olvashatóság napfényben és sötétben;
- memória- és akkumulátormérés;
- támogatott készüléklista;
- Connect IQ Store előkészítés.

## Későbbi ágak

- Americano lebonyolítás;
- Mexicano lebonyolítás;
- saját Laravel API;
- Vue statisztikai webalkalmazás;
- részletes többmeccses elemzések.

## Codex munkamenet egy checkpointon belül

1. kiválasztunk egy szűk, ellenőrizhető célt;
2. rögzítjük az elfogadási feltételeket;
3. Codex implementálja a kódot és a teszteket;
4. lefut a szimulátoros, majd a valós órás ellenőrzés;
5. dokumentáljuk a döntést és lezárjuk a checkpointot;
6. csak ezután indul a következő fejlesztési egység.
