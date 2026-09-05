# Connect IQ Store release checklist — 1.1.0

The Store release candidate is being prepared for Garmin Forerunner 265. The
remaining unchecked real-device and Garmin Connect gates must pass before the
public production submission is sent for review.

## Binary

- [x] Store name standardized to Padel Pilot.
- [x] Release-candidate `.iq` exported and archive-verified as
  `dist/padel-pilot-1.1.0.iq`.
- [x] Manifest contains only the intended MVP device (`fr265`).
- [x] Hungarian and English languages declared.
- [x] FIT, FitContributor, Positioning and Sensor permissions declared.
- [ ] Full real-watch match test passes.
- [ ] FIT file and Garmin Connect display verified.
- [ ] Store/Beta-installed build tested after the final export.
- [ ] Signing key backed up securely for future Store updates.

Release export command:

```bash
SDK_DIR=/path/to/connectiq-sdk
APP_VERSION="$(tr -d '[:space:]' < VERSION)"
"$SDK_DIR/bin/monkeyc" -e -f monkey.jungle \
  -o "dist/padel-pilot-${APP_VERSION}.iq" \
  -y /path/to/developer_key -r -O 3 -w
```

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

## Submission sequence

1. Export and upload a private Beta App with an alternate application UUID.
2. Install the beta through Connect IQ and complete a real-watch match test.
3. Save and sync completed and stopped matches; verify native metrics and the
   custom result fields in Garmin Connect mobile and web.
4. Re-export with the production UUID, upload the production listing and send
   it for public review only after the two open verification gates pass.

## Review notes

- All match interaction is available through physical buttons.
- Touches are consumed during a match to prevent accidental scoring.
- Sensor data is used only for the locally created FIT activity.
- No Communications permission, external account, advertising or analytics is
  used.
