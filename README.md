# checksum

[![test](https://github.com/kojix2/checksum.cr/actions/workflows/test.yml/badge.svg)](https://github.com/kojix2/checksum.cr/actions/workflows/test.yml)

Make `md5sum -c` or `sha256sum -c` prettier.

## Installation

You can download pre-compiled binaries from [GitHub Release](https://github.com/kojix2/checksum.cr/releases).

To compile from source code, type the following command

```sh
git clone https://github.com/kojix2/checksum.cr
cd checksum
shards build --release
cp bin/checksum /usr/local/bin/
```

## Usage

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

```
checksum -a md5 * | tee md5.txt
```

```
62525c1aa35e61fb4e60c053e1faa849  LICENSE
3be217b6d3ac7c38e1805b01b1be0178  README.md
cb9c37b1954a07579e044e33521c993d  shard.lock
c680044745baa4b423450c9ecb8baebb  shard.yml
```

```
checksum -c md5.txt
```

```
4 files in md5.txt
4 files, 4 success, 0 mismatch, 0 errors  (0.0 seconds)
```

### Experimental multi-threading support (preview)

This feature may not work properly. The limitation on the speed of checksum computation is often IO. Therefore, achieving parallelism is not my priority.

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
