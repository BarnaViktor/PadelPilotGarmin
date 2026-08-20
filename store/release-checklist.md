# Connect IQ Store release checklist (future draft)

The app is still under development. This checklist does not declare a release
version or release readiness; it is only a future submission aid. Store images
must not be prepared until the new design is final.

## Binary

- [x] Store name standardized to Padel Pilot.
- [ ] Final release `.iq` exported with the selected version number.
- [x] Manifest contains only the intended MVP device (`fr265`).
- [x] Hungarian and English languages declared.
- [x] FIT, FitContributor and Sensor permissions declared.
- [ ] Full real-watch match test passes.
- [ ] FIT file and Garmin Connect display verified.
- [ ] Final `.iq` exported after the real-watch fixes.

Release export command template (run only when a release is approved):

```bash
SDK_DIR=/path/to/connectiq-sdk
"$SDK_DIR/bin/monkeyc" -e -f monkey.jungle \
  -o "dist/padel-pilot-${APP_VERSION}.iq" \
  -y /path/to/developer_key -r -O 3
```

## Store metadata

- [x] English and Hungarian draft listing prepared.
- [ ] Final 500 × 500 sRGB Store icon prepared after design approval.
- [x] Privacy notice draft prepared.
- [ ] Support email and support URL supplied.
- [ ] Privacy notice published at a stable public URL.
- [ ] Store category and price confirmed.
- [ ] At least three final screenshots captured after design approval.
- [ ] App version/release notes entered in the Store submission form.

## Recommended screenshots

1. live scoring screen with a non-zero score;
2. service-side or court-change prompt;
3. completed match summary;
4. optional match-history screen.

Use screenshots from the final release build. Do not include personal Garmin
Connect data, desktop chrome or simulator controls in the uploaded images.

## Review notes

- All match interaction is available through physical buttons.
- Touches are consumed during a match to prevent accidental scoring.
- Sensor data is used only for the locally created FIT activity.
- No Communications permission, external account, advertising or analytics is
  used.
