# checksum

[![test](https://github.com/kojix2/checksum.cr/actions/workflows/test.yml/badge.svg)](https://github.com/kojix2/checksum.cr/actions/workflows/test.yml)

My personal tool to show `md5sum -c` or `sha256sum -c` a little more prettily

## Installation

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
    -v, --verbose                    Verbose mode [false]
    --no-clear                       Do not clear the line [false]
    --no-color                       Do not use color [false]
    --debug                          Debug mode [false]
    --help                           Show this message
    --version                        Show version
```

## Development

Pull requests are welcome.

## License

MIT
