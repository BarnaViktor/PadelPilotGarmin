# Connect IQ Store release checklist — 1.3.0

Production update using the existing application ID/signing key and ten
previously supported SDK profiles. Upload artifact:
`dist/releases/1.3.0/padel-pilot-1.3.0.iq`.

## Prepared and verified

- [x] VERSION and English/Hungarian AppVersion resources: 1.3.0.
- [x] Production IQ export with SDK 9.2.0; archive integrity and SHA-256.
- [x] Device/API scope preserved: ten SDK profiles, minimum API 3.4.0.
- [x] Optimized PRGs and 116-test suite on every supported SDK profile.
- [x] Exported product IDs and PRG bytes compared with device builds.
- [x] AM-7 native FR265/Enduro FIT lifecycle, recovery, retry and memory review.
- [x] English/Hungarian What's new, listing, support and privacy text updated.
- [x] Build evidence and checksums archived in the 1.3.0 release folder.
- [x] Signing key excluded from the release folder.

## Publication and real-watch evidence

- [ ] Upload the IQ to the existing production Store entry; enter 1.3.0.
- [ ] Enter updated listing, release notes, support and privacy URLs.
- [ ] Review/refresh Store screenshots: existing assets depict 1.2.0.
- [ ] Submit the update for Store review.
- [ ] Verify installed 1.3.0 on real FR265/Enduro and other supported models.
- [ ] Verify point-mode FIT/Connect display, GPS/sensor data, battery and memory.

Store publication is separate from the local export and Git push.
Screenshots under `store/assets` are retained historical 1.2.0 assets;
this release does not claim a new Store screenshot set.

The release includes Americano/Mexicano completed/unfinished history,
draw/point/time statistics and FIT activity recording. A restarted match
uses a new FIT segment; a pending history save after an already completed
FIT is recovered without another recording.

See [release notes](../docs/releases/1.3.0.md),
[What's new](whats-new-1.3.0.md) and [FIT contract](../docs/am7-fit-contract.md).
Rebuild with `python3 scripts/dev.py release`; each build gets its own
`build/` directory. The fixed `dist/releases/1.3.0` folder records one export.
