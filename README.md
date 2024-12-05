# checksum

[![test](https://github.com/kojix2/checksum.cr/actions/workflows/test.yml/badge.svg)](https://github.com/kojix2/checksum.cr/actions/workflows/test.yml)

`checksum` makes the output of `md5sum -c` or `sha256sum -c` prettier.

## Installation

You can download pre-compiled binaries from [GitHub Release](https://github.com/kojix2/checksum.cr/releases).

To compile from source code, follow the steps below:

```sh
git clone https://github.com/kojix2/checksum.cr
cd checksum
shards build --release
cp bin/checksum /usr/local/bin/
```

Homebrew:

```
brew install kojix2/brew/checksum
```

## Usage

To verify checksums from a file, use the following command:

```sh
checksum -c md5sum.txt
```

```
Usage: checksum [options]
    -c, --check FILE                 Read checksums from the FILE (required)
    -a, --algorithm ALGORITHM        (md5|sha1|sha256|sha512) [auto]
    -A, --absolute                   Output absolute path [false]
    -v, --verbose                    Verbose mode for outputting checksums and errors.
    --no-clear                       Do not clear the line [false]
    --no-color                       Do not use color [false]
    --debug                          Debug mode [false]
    -h, --help                       Show this message
    --version                        Show version
```

To generate checksums and save them to a file, use:

```sh
checksum -a md5 * | tee md5.txt
```

Example output:

```
62525c1aa35e61fb4e60c053e1faa849  LICENSE
3be217b6d3ac7c38e1805b01b1be0178  README.md
cb9c37b1954a07579e044e33521c993d  shard.lock
c680044745baa4b423450c9ecb8baebb  shard.yml
```

Then, you can verify the checksums with:

```sh
checksum -c md5.txt
```

Example output:

```
4 files in md5.txt
4 files, 4 success, 0 mismatch, 0 errors  (0.0 seconds)
```

### Experimental multi-threading support (preview)

This feature is experimental. The limitation on the speed of checksum computation is often I/O. Therefore, achieving parallelism is not the main focus.

To use this feature, compile and run with the following commands:

```sh
git clone https://github.com/kojix2/checksum.cr
cd checksum
shards build --release -Dpreview_mt
cp bin/checksum /usr/local/bin/
CRYSTAL_WORKERS=2 checksum -c md5sum.txt
```

## Development

Pull requests are welcome.

## License

MIT
