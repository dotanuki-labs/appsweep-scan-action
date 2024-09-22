# appsweep-scan-action

## What

> A Github Action to scan Android and iOS deployables for security issues

This Github Action is an opinionated wrapper around the official
[guardsquare-cli](https://help.guardsquare.com/en/articles/161270-using-the-guardsquare-cli)
delivering security scans on top of
[Guardsquare Appsweep](https://appsweep.guardsquare.com/)

It extends functionality from
[Guardsquare/appsweep-action](https://github.com/Guardsquare/appsweep-action)
with a few goodies, in particular adding support to iOS deployables.

## Using

An example Workflow

```yaml
name: CI
on: [push]
jobs:
  build-and-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@latest

      # Run any tasks that output a deployable artifact
      # eg ./gradlew app:assembleRelease
      - run: ./build/my/product.sh

      # .
      # .
      # .

      - uses: dotanuki-labs/appsweep-scan-action@latest
        with:
          archive-file: app/build/outputs/apk/release/my-product.apk
        env:
          # Don't forget to add this as an environment variable
          APPSWEEP_API_KEY: ${{ secrets.APPSWEEP_MY_PRODUCT_KEY }}
```

> [!WARNING]
>
> **Avoid using `@latest`, replace it with proper pinned tags or commit shas**

This action accepts the following inputs:

| Input            | Required | Description                             |
|------------------|----------|-----------------------------------------|
| archive-file     | YES      | Path to the deployable file to scan     |
| symbols          | No       | Path to symbols related to a deployable |
| wait-for-summary | No       | Waits for the scan and shows a summary  |

Regarding values accepted by the inputs:

- `archive-file` accepts '.aab', '.apk', '.ipa', '.xcarchive' file
- `symbols` accepts either a `mapping.txt` file (Android) or folder with dSyms (iOS)
- `wait-for-summary` accepts any string to flag opt-in

In addition to that:

- The `archive-file` input is sensitive to the aforementioned file extensions
- The `symbols` input is not needed when scanning `.xcarchive` artifacts (iOS)

Last, but not least, `APPSWEEP_API_KEY` is mandatory in the execution since it's
required by `guardsquare-cli`. You can provision it scoped to a
Step (like the previous example), to Job or Workflow

## License

Copyright (c) 2024 - Dotanuki Labs - [The MIT license](https://choosealicense.com/licenses/mit)
