# android-emulator-runner

## Launch an Android Emulator in your GitHub Actions workflow

This GitHub Action launches a pre-existing Android Virtual Device (AVD) emulator in your workflow. It is useful for running instrumented tests or any workflow step that requires an Android emulator.

> **Note:** This action assumes the AVD is already created and available on the runner.

## Usage

Add a step to your workflow YAML to launch the emulator:

```yaml
- name: Launch Android Emulator
  uses: ./android-emulator-runner
  with:
    avd-name: test
    emulator-port: 5554
    emulator-boot-timeout: 180
    emulator-options: -no-window -gpu swiftshader_indirect -no-snapshot -noaudio -no-boot-anim
    disable-animations: true
    disable-spellchecker: false
    enable-hw-keyboard: false
    verbose: false
```

## Inputs

| Name                  | Description                                                                                      | Default                                                      |
|-----------------------|--------------------------------------------------------------------------------------------------|--------------------------------------------------------------|
| `avd-name`            | Custom AVD name used for launching the Android Virtual Device                                    | `test`                                                       |
| `emulator-port`       | Port to run emulator on, allows running multiple emulators on the same machine                   | `5554`                                                       |
| `emulator-boot-timeout` | Emulator boot timeout in seconds. If it takes longer, the action fails                         | `180`                                                        |
| `emulator-options`    | Command-line options used when launching the emulator                                            | `-no-window -gpu swiftshader_indirect -no-snapshot -noaudio -no-boot-anim` |
| `disable-animations`  | Whether to disable animations (`true` or `false`)                                                | `true`                                                       |
| `disable-spellchecker`| Whether to disable the Android spell checker framework (`true` or `false`)                       | `false`                                                      |
| `enable-hw-keyboard`  | Whether to enable hardware keyboard (`true` or `false`)                                          | `false`                                                      |
| `verbose`             | Enable verbose log output (`true` or `false`)                                                    | `false`                                                      |

## Outputs

| Name            | Description                        |
|-----------------|------------------------------------|
| `emulator-port` | The port the emulator is running on |

## Example Workflow

```yaml
name: Android Instrumented Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Set up Java and Android SDK as needed here

      - name: Launch Android Emulator
        uses: ./android-emulator-runner
        with:
          avd-name: test
          emulator-port: 5554
          emulator-boot-timeout: 300
          emulator-options: -no-window -gpu swiftshader_indirect -no-snapshot -noaudio -no-boot-anim
          disable-animations: true
          disable-spellchecker: true
          enable-hw-keyboard: false
          verbose: true

      - name: Run Instrumented Tests
        run: ./gradlew connectedAndroidTest
```

## Implementation

- [action.yml](./action.yml): Action definition and input/output specification.
- [action.sh](./action.sh): Bash script that launches and configures the emulator.

# Citations

Portions of this are copyright of the original authors of https://github.com/ReactiveCircus/android-emulator-runner, licensed under [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0.txt)

## License

MIT License

Copyright (c) 2025 ndtp

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Citations

Portions of this are copyright of the original authors of [ReactiveCircus/android-emulator-runner](https://github.com/ReactiveCircus/android-emulator-runner), licensed under [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0.txt)
