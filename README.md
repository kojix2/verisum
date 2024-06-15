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

## Development

Pull requests are welcome.

## License

MIT
