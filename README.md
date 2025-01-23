# verisum

[![test](https://github.com/kojix2/verisum/actions/workflows/test.yml/badge.svg)](https://github.com/kojix2/verisum/actions/workflows/test.yml)

`verisum` makes the output of `md5sum -c` or `sha256sum -c` prettier.

![screenshot](https://github.com/user-attachments/assets/453701b9-19ec-4409-99f2-4e0fb638df4c)

Verifying MD5 of 100,000 images from "[たっぷり素材PIXTA](https://www.sourcenext.com/product/pixta/)"

## Installation

You can download pre-compiled binaries from [GitHub Release](https://github.com/kojix2/verisum.cr/releases).

To compile from source code, follow the steps below:

```sh
git clone https://github.com/kojix2/verisum
cd verisum
shards build --release
sudo cp bin/verisum /usr/local/bin/
```

Homebrew:

```
brew install kojix2/brew/verisum
```

## Usage


```
  Options;
    -c, --calc                       Compute checksums
    -a, --algorithm ALGORITHM        (md5|sha1|sha256|sha512)
    -A, --absolute                   Output absolute path [false]
    -v, --verbose                    Output checksums and errors, etc [false]
    -C, --color WHEN                 when to use color (auto|always|never) [auto]
    -D, --debug                      Print a backtrace on error
    -h, --help                       Show this message
    -V, --version                    Show version
```

### Verification

To verify the checksums with:

```sh
verisum md5.txt
```

Example output:

```
4 files in md5.txt
4 files, 4 success, 0 mismatch, 0 errors  (0.0 seconds)
```

### Calculation

We recommend using standard Unix commands for calculations, 
but if standard Unix commands are not available, 
you can also use this tool for calculations.

**Note that the effect of the `-c` option is the opposite of `md5sum`.**

```sh
verisum -c -a md5 * | tee md5.txt
```

Sort the file list before calculating the checksums:

```sh
find . -type f | sort | xargs verisum -c -a md5 | tee md5.txt
```

Example output:

```
62525c1aa35e61fb4e60c053e1faa849  LICENSE
3be217b6d3ac7c38e1805b01b1be0178  README.md
cb9c37b1954a07579e044e33521c993d  shard.lock
c680044745baa4b423450c9ecb8baebb  shard.yml
```

## Development

Pull requests are welcome.

## License

MIT
