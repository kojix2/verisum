# checksum

[![test](https://github.com/kojix2/checksum.cr/actions/workflows/test.yml/badge.svg)](https://github.com/kojix2/checksum.cr/actions/workflows/test.yml)

`checksum` makes the output of `md5sum -c` or `sha256sum -c` prettier.

![screenshot](https://github.com/user-attachments/assets/453701b9-19ec-4409-99f2-4e0fb638df4c)

Confirmation of the MD5 checksums for 100,000 images from "[たっぷり素材PIXTA](https://www.sourcenext.com/product/pixta/)"

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
  Options;
    -c, --check                      Check the checksum
    -a, --algorithm ALGORITHM        (md5|sha1|sha256|sha512) [auto]
    -A, --absolute                   Output absolute path [false]
    -v, --verbose                    Output checksums and errors, etc [false]
    -C, --color WHEN                 when to use color (auto|always|never) [auto]
    -D, --debug                      Print a backtrace on error
    -h, --help                       Show this message
    -V, --version                    Show version
```

To verify the checksums with:

```sh
checksum -c md5.txt
```

Example output:

```
4 files in md5.txt
4 files, 4 success, 0 mismatch, 0 errors  (0.0 seconds)
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

This command is not meant for recursively scanning directories and creating files. Use tools like `find` or `fd`, sort with `sort` or `gsort`, and process with `xargs`.

## Development

Pull requests are welcome.

## License

MIT
