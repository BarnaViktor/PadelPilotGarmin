# Connect IQ Store release checklist — 1.2.0 stable

Production update for ten tested Garmin SDK profiles, including Forerunner
265, the tested AMOLED models and Enduro 1/2/3. Previous stable version: 1.1.0.
The upload artifact is `dist/releases/1.2.0/padel-pilot-1.2.0.iq`.
This release uses the existing production application ID and signing key.

## Prepared and verified

- [x] `VERSION`, English/Hungarian app resources and home screen: 1.2.0.
- [x] Production IQ export and optimized PRGs for all ten profiles built with SDK 9.2.0.
- [x] IQ archive integrity verified; SHA-256 recorded in `build-info.json`.
- [x] Production and beta manifests: ten tested profiles, minimum API 3.4.0.
- [x] Regression suite: 94/94 passed on each profile, zero failures/errors.
- [x] Exported IQ product IDs verified against the ten SDK profiles.
- [x] All 15 exported binaries match the individual production device builds.
- [x] Sixteen current native view samples rendered on each of the ten profiles.
- [x] English/Hungarian listing and release notes updated to 1.2.0.
- [x] Classic and point-mode feature boundaries stated accurately.
- [x] Privacy/support text updated for the current modes.
- [x] Existing 500×500 and 128×128 version-independent icons inspected.
- [x] Twelve current native 416×416 sRGB screenshot assets prepared.
- [x] Build evidence, asset inventory and checksums included in release folder.

## Publication and real-watch evidence

- [ ] Upload IQ to the existing production Store entry; enter version 1.2.0.
- [ ] Enter current listing/release notes, icons, screenshots and URLs.
- [ ] Submit the production update for Store review.
- [ ] Record the installed 1.2.0 regression on a real Forerunner 265.
- [ ] Record real-watch match, readability and battery results on the added models.
- [ ] Verify Classic FIT recording and Garmin Connect mobile/web display.

The 1.1.0 production-use confirmation is historical evidence. It does not
establish real-watch validation or Store publication of 1.2.0. No private
Beta package is needed by this submission sequence.

The user explicitly requested the simulator-tested devices in this 1.2.0
production release. Real-watch validation remains a separate follow-up and
is not claimed by the build or simulator evidence.

## Upload material

See [release notes](release-notes.md) and
[asset inventory](assets/README.md). A suggested five-image selection:
home/version, setup, live Classic score, individual match points, Americano
score. Additional screenshots document history, aggregate stats, modes,
Mexicano result and active recovery.

Copy the English/Hungarian update text from [What's new](whats-new.md).

Rebuild the production package with:

```bash
python3 scripts/dev.py release
```

This prints a new artifact path under `build/`; keep the new build record
with that exact file. The fixed `dist/releases/1.2.0` folder records this
specific export, not every future rebuild.

## Review notes

All controls use physical buttons; match touches are consumed. Classic
sensor data is used for its local FIT activity. Point modes persist only
active match state in this version. No Communications permission, external
account, ads or analytics is used. Signing keys are excluded from the package.
