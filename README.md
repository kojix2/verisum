# checksum

[![test](https://github.com/kojix2/checksum.cr/actions/workflows/test.yml/badge.svg)](https://github.com/kojix2/checksum.cr/actions/workflows/test.yml)

`checksum` makes the output of `md5sum -c` or `sha256sum -c` prettier.

![screenshot](https://github.com/user-attachments/assets/453701b9-19ec-4409-99f2-4e0fb638df4c)

Verifying MD5 of 100,000 images from "[たっぷり素材PIXTA](https://www.sourcenext.com/product/pixta/)"

## Installation

You can download pre-compiled binaries from [GitHub Release](https://github.com/kojix2/checksum.cr/releases).

To compile from source code, follow the steps below:

```sh
git clone https://github.com/kojix2/checksum.cr
cd checksum.cr
shards build --release
sudo cp bin/checksum /usr/local/bin/
```

Homebrew:

```
brew install kojix2/brew/checksum
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
checksum md5.txt
```

Example output:

```
4 files in md5.txt
4 files, 4 success, 0 mismatch, 0 errors  (0.0 seconds)
```

### Calculation

To generate checksums and save them to a file, use:

```sh
checksum -c -a md5 * | tee md5.txt
```

Example output:

```
62525c1aa35e61fb4e60c053e1faa849  LICENSE
3be217b6d3ac7c38e1805b01b1be0178  README.md
cb9c37b1954a07579e044e33521c993d  shard.lock
c680044745baa4b423450c9ecb8baebb  shard.yml
```

- The main purpose of this tool is “validation”.
- Note that the effect of the -c option is the opposite of `md5sum`.
- The “calculation” function is intended for use in situations where Unix commands such as md5sum cannot be used for some reason. 

- This command is not meant for recursively scanning directories and creating files. Use tools like `find` or `fd`, sort with `sort` or `gsort`, and process with `xargs`.

```sh
find . -type f | sort | xargs md5sum
find . -type f | sort | xargs checksum -c -a md5
```

```sh
fd -t f | sort | xargs md5sum
fd -t f | sort | xargs checksum -c -a md5
```

## Development

Pull requests are welcome.

## License

MIT
