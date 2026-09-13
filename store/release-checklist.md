# Connect IQ Store release checklist — 1.1.0

The user confirmed that production version `1.1.0` is in active use. This
checklist retains the package preparation history and outstanding evidence
for future updates. Store publication status and the installation channel
have not been recorded here; production use alone does not establish them.

## Binary

- [x] Store name standardized to Padel Pilot.
- [x] Release-candidate `.iq` exported and archive-verified as
  `dist/padel-pilot-1.1.0.iq`.
- [x] Manifest contains only the intended MVP device (`fr265`).
- [x] Private Beta manifest uses the separate application ID
  `998e196669f54d34a1519db8ecaa0bbe`.
- [x] Private Beta `.iq` exported and archive-verified as
  `dist/padel-pilot-1.1.0-beta.iq`.
- [x] Hungarian and English languages declared.
- [x] FIT, FitContributor, Positioning and Sensor permissions declared.
- [x] A pre-2026-09-05 version was used and tested on a real Forerunner 265.
- [x] Production `1.1.0` is in active use, confirmed by the user.
- [ ] Targeted regression results recorded for the production `1.1.0` in use.
- [ ] FIT file and Garmin Connect display verified.
- [ ] Store/Beta-installed build tested after the final export.
- [ ] Signing key backed up securely for future Store updates.

Release export command:

```bash
python3 scripts/dev.py release
```

Private Beta export command:

```bash
python3 scripts/dev.py beta
```

These commands now create separate directories under `build/`, print the
artifact path, verify the IQ archive with 7z, and save `build-info.json`
alongside it. The `dist/` paths above identify the earlier exports. Use the
newly printed path for a new submission and retain its SHA-256 build record
with the real-watch test results. SDK/key overrides and test commands are
documented in [README.md](../README.md#fordítás-és-automatikus-ellenőrzés).

## Store metadata

- [x] English and Hungarian listing prepared for version 1.1.0.
- [x] Final 500 × 500 sRGB Store icon prepared.
- [x] Optional 128 × 128 sRGB AMOLED Store icon prepared.
- [x] Privacy notice finalized with public contact details.
- [x] Support email and support URL supplied.
- [x] Stable public privacy-policy URL selected.
- [x] Store category `Sports` and price `Free` confirmed.
- [x] Five 416 × 416 final screenshots captured without personal data or
  simulator controls.
- [ ] App version, release notes, assets and URLs entered in the Store
  submission form.

## Recommended screenshots

1. `store/assets/screenshots/01-match-setup.png`;
2. `store/assets/screenshots/02-live-score.png`;
3. `store/assets/screenshots/03-server-selection.png`;
4. `store/assets/screenshots/04-match-summary.png`;
5. `store/assets/screenshots/05-match-history.png`.

Use screenshots from the final release build. Do not include personal Garmin
Connect data, desktop chrome or simulator controls in the uploaded images.

## Submission sequence for future updates

Use the installed production `1.1.0` for current usage feedback and Connect
checks. The private Beta sequence below is available for testing future
changes; it is not a prerequisite for collecting production feedback.

1. Run `python3 scripts/dev.py beta` and upload its printed `.iq` path as a
   private Beta App.
2. Install the beta through Connect IQ and complete the targeted real-watch
   regression for the changes introduced after the previously tested build.
3. Save and sync completed and stopped matches; verify native metrics and the
   custom result fields in Garmin Connect mobile and web.
4. Re-export with the production manifest, upload the production listing and
   send it for public review only after the two open verification gates pass.

## Review notes

- All match interaction is available through physical buttons.
- Touches are consumed during a match to prevent accidental scoring.
- Sensor data is used only for the locally created FIT activity.
- No Communications permission, external account, advertising or analytics is
  used.
