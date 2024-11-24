# setup-OSGeo4W

GitHub Action to install and setup an OSGeo4W environment

## Usage

Without any packages, will only run the plain installer:

```yaml
- name: Setup OSGeo4W environment
  uses: echoix/setup-OSGeo4W@v0.2.0
```

Installing various packages available in the OSGeo4W repos, and using the OSGeo4W shell afterwards

```yaml
- name: Setup OSGeo4W environment
  id: setup-osgeo4w
  uses: echoix/setup-OSGeo4W@v0.2.0
  with:
    # Using line folding replacing newlines by a space, and striping the final newlines
    # See https://yaml-multiline.info/
    packages: >-
      cairo-devel
      freetype-devel
      gdal-devel
      geos-devel
      libjpeg-turbo-devel
      liblas-devel
      libpng-devel
      libpq-devel
      libtiff-devel
      netcdf-devel
- run: o-help
  shell: cmd /D /E:ON /V:OFF /S /C "CALL C:/OSGeo4W/OSGeo4W.bat "{0}""
```

## Options

| Name         | Description                                                                                                                                                                             | Default                                  |
| ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| packages     | List of OSGeo4W packages to install. Use newlines, spaces, or commas in between package names                                                                                           | base                                     |
| root         | Root installation directory                                                                                                                                                             | `C:\OSGeo4W`                             |
| package-dir  | Location where to download packages. Using a folder in a faster drive, like `D:\OSGeo4W_pkg`, reduces installation time. Use a different folder than the one used for the `root` input. |                                          |
| site         | Download site URL to use                                                                                                                                                                | "https://download.osgeo.org/osgeo4w/v2/" |
| upgrade-also | Also upgrade installed packages                                                                                                                                                         | "true"                                   |

## Outputs

| Name | Description                                                                                                                              |
| ---- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| root | The root installation directory used. Equivalent to the OSGEO4W_ROOT environment variable. The path is resolved in order to be absolute. |

## Full example

```yaml
name: Full example

on:
  push:
    branches:
      - main
  pull_request:
jobs:
  root:
    concurrency:
      group: >-
        ${{ github.workflow }}-${{ github.event_name == 'pull_request' && github.head_ref || github.sha }}-${{
        'root-dir-variations' }}-${{  matrix.os }}-${{ matrix.root-dir }}-${{ matrix.pkg-dir }}
      cancel-in-progress: true
    runs-on: ${{ matrix.os }}
    env:
      TEST_O4W_ROOT: ${{ matrix.root-dir }}
    strategy:
      matrix:
        os:
          - windows-2019
          - windows-2022
          - windows-latest
        root-dir:
          - "C:\\OSGeo4W"
          - "D:\\OSGeo4W"
          - "D:/OSGeo4W"
          - "C:/otherFolder/"
        pkg-dir:
          - "${{ github.workspace }}/OSGeo4W_pkg"
    steps:
      - name: Checkout Code
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - name: Setup OSGeo4W environment
        id: setup-osgeo4w
        uses: ./
        with:
          root: ${{ matrix.root-dir }}
          package-dir: ${{ matrix.pkg-dir }}
          # Using line folding replacing newlines by a space, and striping the final newlines
          # See https://yaml-multiline.info/
          packages: >-
            grass-dev
            saga
      - name: Display all outputs as JSON
        run: |
          echo "${{ toJSON(steps.setup-osgeo4w.outputs) }}"
      - name: Show OSGeo4W root
        run: echo "${{ steps.setup-osgeo4w.outputs.root }}"
      - run: o-help
        shell: cmd /D /E:ON /V:OFF /S /C "CALL %TEST_O4W_ROOT%/OSGeo4W.bat "{0}""
      - run: pip install pytest-timeout
        shell: cmd /D /E:ON /V:OFF /S /C "CALL %TEST_O4W_ROOT%/OSGeo4W.bat "{0}""
```
