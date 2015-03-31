# dice.rb

This is a simple generator for diceware passphrases written in Ruby.
It uses SecureRandom for random number generation, which in turn uses openssl, /dev/urandom or the Windows API (in that order).

## wordlists

The wordlist parser is not very picky. The only requirement is that each word definition must have its own line in the form of `<id> <whitespace character> <word>`. Every line not matching that format will be ignored.

You can select which wordlist to use by specifying the `-w` flag. The parameter can be a local path or a URL. By default it will use the [standard English wordlist](http://world.std.com/~reinhold/diceware.wordlist.asc). Please note that the PGP signature is completely ignored at the moment.

## passphrase length

The default length is 6 words, you can change that by specifying the `-l` flag.

## everything else

`$ ./dice.rb --help`
