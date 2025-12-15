# Igir & RomM

**This is building upon the original documentation from RomM: [Igir Collection Manager](https://docs.romm.app/latest/Tools/Igir-Collection-Manager/)**

[Igir](https://igir.io/) is a zero-setup ROM collection manager that sorts, filters, extracts or archives, patches, and reports on collections of any size on any OS. It can be used to rename your ROMs to match the RomM database, and to move them into a new directory structure.

## Setup

### Directory structure

The directory structure is important for running the bulk ROM renaming script. Before running the bulk ROM renaming script, set up your directories as follows:

```shell
.
├── dats/ # DAT files from no-intro.org
├── roms/ # Original ROM collection
├── roms-unverified/ # Working copy of ROMs
└── igir-romm-cleanup.sh
```

### Initial Setup Steps

1. **Create a working copy of your ROMs:**  
    `cp -r roms/ roms-unverified/`  
    This provides a safe working environment and allows for easy script adjustment if needed.
2. **Download DAT Files:**
    - For cartridge-based systems:
        - Visit [No-Intro.org Daily Download](https://datomatic.no-intro.org/index.php?page=download&op=daily)
        - Download the latest DAT compilation
    - For optical media (e.g., PlayStation):
        - Visit [redump.org](http://redump.org/downloads/)
        - Download platform-specific DAT files
    Extract the DAT files to your `dats` directory. You can optionally extract a subset of the .dat files into the directory instead.

## Configuration

### cleanup script

**Prerequisites before running the script**

* Create the `roms-unverified/` directory and populate it with a copy of your ROM collection (e.g., `cp -r roms/ roms-unverified/`).
* Create the `dats/` directory and place your No-Intro/Redump DAT files inside it.
* **No need to create `roms-verified/`** — Igir will automatically create this directory and its system subdirectories (under `{romm}/`) during processing.

**Create the cleanup script `igir-romm-cleanup.sh` with the contents below:**

```shell
#!/usr/bin/env bash
set -ou pipefail
cd "$(dirname "${0}")"

INPUT_DIR=roms-unverified
OUTPUT_DIR=roms-verified

# Documentation: https://igir.io/
# Uses dat files: https://datomatic.no-intro.org/index.php?page=download&op=daily
time npx -y igir@latest \
  move \
  extract \
  report \
  test \
  -d dats/ \
  -i "${INPUT_DIR}/" \
  -o "${OUTPUT_DIR}/{romm}/" \
  --input-checksum-quick false \
  --input-checksum-min CRC32 \
  --input-checksum-max SHA256 \
  --only-retail
```

**Detailed  description:**

* `set -ou pipefail` configures bash to exit on errors (-e), treat unset variables as errors (-u), and propagate errors through pipes (pipefail) for robust execution.
* `cd "$(dirname "${0}")"` changes the working directory to where the script is located, ensuring relative paths (like INPUT_DIR) work consistently regardless of where the script is called from.
* `INPUT_DIR=roms-unverified` defines the input directory where unverified ROM files (e.g., .zip archives or raw ROMs) are stored for processing.`
* `OUTPUT_DIR=roms-verified` defines the output directory where verified ROMs will be moved after processing, with subdirectories created based on system type.
* `time npx -y igir@latest` runs the `igir` npm package (latest version) via npx, with  `-y` to auto-confirm installation if needed; `time` measures execution duration.
* `move` moves verified ROM files from the input directory to the output directory after processing.
* `extract` extracts ROM files from archives (e.g., `.zip`) in the input directory, making them accessible for verification.
* `report` generates a CSV report detailing known and unknown ROM files, based on DAT file comparisons, useful for tracking results.
* `test` tests the moved ROM files to ensure they match expected standards (e.g., checksums) after being relocated.
* `-d dats/` specifies the directory ('dats/') containing DAT files used for verifying ROM authenticity against known databases.
* `-i "${INPUT_DIR}/"` sets the input directory (roms-unverified) where 'igir' looks for ROM files or archives to process.
* `-o "${OUTPUT_DIR}"` sets the output directory (roms-verified) with '{romm}' as a replaceable symbol, organizing ROMs into RomM system-specific subdirectories (e.g., 'gb' for Game Boy).
* `--input-checksum-quick false` disables quick checksum checking, forcing full decompression of archives for accurate checksum calculation rather than relying on headers.
* `--input-checksum-min CRC32` sets the minimum checksum level to CRC32, a basic hash for initial verification of ROM integrity which will be compared with the `.dat` file.
* `--input-checksum-max SHA256` sets the maximum checksum level to SHA256, a more robust hash, ensuring thorough verification across a range of methods which will be compared with the `.dat` file.
* `--only-retail` filters the process to include only retail ROM releases, excluding non-retail versions like debug, demo, or homebrew by enabling related "no" options.

**Make the script executable and run it:**

`chmod a+x igir-romm-cleanup.sh`
`./igir-romm-cleanup.sh`

### 1G1R script

> "1G1R" stands for "One Game, One ROM." In the context of collected gaming ROMs, it refers to a method of organizing ROM sets where only one version of each game is kept, rather than including multiple regional variants, revisions, or duplicates. The goal is to create a streamlined collection that avoids redundancy while still preserving a playable and representative version of each game.

**Create the 1g1r (1 game 1 rom) script `igir-romm-1g1r.sh` with the contents below:**

```shell
#!/usr/bin/env bash
set -ou pipefail
cd "$(dirname "${0}")"

INPUT_DIR=roms-unverified
OUTPUT_DIR=roms-verified

# Documentation: https://igir.io/
# Uses dat files: https://datomatic.no-intro.org/index.php?page=download&op=daily
time npx -y igir@latest \
  report \
  move \
  extract \
  test \
  -v \
  -d dats/ \
  -i "${INPUT_DIR}/" \
  -o "${OUTPUT_DIR}/" \
  --input-checksum-quick false \
  --input-checksum-min CRC32 \
  --input-checksum-max SHA256 \
  --only-retail \
  --single \
  --prefer-region GER,EUR,WORLD,JPN \
  --prefer-language DE,EN,JA \
  --prefer-revision newer
```

**Additional parameters in comparison to the cleanup script:**

* `--single` enables 1G1R mode, ensuring only one ROM per game is kept based on the specified preferences.
* `--prefer-region GER,EUR,WORLD,JPN` sets the region preference order: Germany (GER), Europe (EUR), World (WORLD), Japan (JPN) for selecting the desired ROM version. It is important that those are comma-separated without blanks.
* `--prefer-language DE,EN,JA` sets the language preference order: German (DE), English (EN), Japanese (JA) for prioritizing ROMs with these languages. It is important that those are comma-separated without blanks.
* `--prefer-revision newer` prefers newer revisions of a game when multiple versions are available, ensuring the most updated ROM is selected.

**Make the script executable:**

`chmod a+x igir-romm-1g1r.sh`

## Usage

### Run the script

Run the script. It will generate a new output directory named `roms-verified`, moving the files from `roms-unverified` if its checksum matches any of the known checksums in the DAT files provided. Any ROMs not identified will remain in the `roms-unverified` directory.

Be aware that if, for instance, you have `.bin` or `.cue` files, they will automatically be organized into a folder structure. The `.dat` file will serve as the single source of truth defining this structure.

Example:

```
├── Game A (Part 1).bin
├── Game A (Part 2).bin
├── Game A (Part 3).bin
└── Game A.cue
```

would be transferred to:

```
├── Game A
	├── Game A (Part 1).bin
	├── Game A (Part 2).bin
	├── Game A (Part 3).bin
	└── Game A.cue
```


### Manually move over remaining files

The script may not identify all of the ROMs in your input directory. You can choose to migrate them over manually:

```
npx -y igir@latest \
  move \
  -i roms-unverified/ \
  -o roms-verified/ \
  --dir-mirror
```

This will move your ROMs from the input to the output directory, preserving the subdirectory structure. It also cleans up file extensions in the process.

### Reorganize multi-disc games

The Igir script will move games that have multiple discs to separate folders. This can confuse RomM's game detection, and those games need to be reorganized into single folders with many discs.

To do this enter your platform directory, such as `ps` or `psx` and run the following:

```
ls -d *Disc* | while read dir; do
  game=$(echo "${dir}" | sed -r 's/ \(Disc [0-9]+\)//')
  mkdir -p "${game}"
  mv "${dir}"/* "${game}/"
  rm -rf "${dir}"
done
```

This will find any directory with `(Disc` in the name and move the files into a new directory without the `(Disc #)` string. For example:

Before:

```
Game A (Disc 1) (USA)
Game A (Disc 2) (USA)
```

Gets combined to:

```
Game A (USA)
```
