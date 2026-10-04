# Device verification for 1.2.0

Every supported SDK profile passed the current 94-test suite and an optimized
production build. The IQ export contains all 15 SDK product IDs; every
exported PRG was compared by SHA-256 with its individual production build.

`devices/<id>/` contains the production PRG, build metadata and logs, test
metadata and logs, and a native rendering log and 16-frame contact sheet.
`render-source.mc` is the separate sample app entry point used with the
unchanged production domain/UI files and resources. Its app ID was
`39d1c6567c9548538f420716387e0ec5`. It uses synthetic match data and does not
exercise live input or represent real-watch validation. Compiler/test
metadata identifies the actual source snapshot base revision and dirty state;
`source-hashes.json` records the exact application inputs.

Frames: 0 home/version; 1 Classic setup; 2 mode editor; 3 point target editor;
4 Classic scoring; 5 Classic pause; 6 server selection; 7 history;
8 history overview; 9 match record; 10 aggregate point statistics;
11 individual match point statistics; 12 recovered Americano pause;
13 completed Mexicano match; 14 Mexicano pause; 15 point-match recovery.

Store screenshots in `assets/` remain the existing FR265 captures. Contact
sheets include simulator skins and controls and are verification material.
Real-watch matches, FIT/Connect, battery use and long-session checks remain
separate follow-up items. These simulator-tested models are included in the
production release at the user's explicit request.
