# dice.rb

This is a simple generator for diceware passphrases written in Ruby.
It uses SecureRandom for random number generation, which in turn uses openssl, /dev/urandom or the Windows API (in that order).

## Word lists

The wordlist parser is not very picky. The only requirement is that each word definition must have its own line in the form of `<id> <whitespace character> <word>`. Every line not matching that format will be ignored.  Note that each digit of `<id>` MUST be 1 through 6, otherwise the line will never be chosen; remember, we're simulating six-sided dice.

You can select which wordlist to use by specifying the `-w` flag. The parameter can be a local path or a URL. By default it will use the [standard English wordlist](http://world.std.com/~reinhold/diceware.wordlist.asc). Please note that the PGP signature is completely ignored at the moment.

## Passphrase Length

The default length is 6 words, you can change that by specifying the `-l` flag.  Per the diceware specification, each word adds ~13 bits of entropy.

## Extra Security

### Capital letters

By default, no capitalization happens in a diceware password.  Because of the size of the wordlist, it's simply easier to remember an extra word than a randomly-capitalized letter.  Therefore, the diceware specification does not include capital letters.

Unfortunately, some password policies require capital letters, so we've deviated from the specification to add capitalization:

- a random word is chosen
- a random character within that word is chosen.  If that character is not capitalizable (such as numbers, specials, or already-capitalized), a different word and character are chosen
- the chosen character is replaced with its capitalization.

It is unknown how much entropy is added for each capitalization, but it's clearly more than zero.  My best guess is ~5 bits (log2(26)) #FIXME: is this correct?

### Special characters and numbers

By default, no special characters or numbers (apart from those appearing in the wordlist) are used.  However, [The Diceware Homepage](http://world.std.com/~reinhold/diceware.html) specifies an algorithm for inserting special characters.  This can be used with the included wordlist `special.txt`, or specified with the `-s` flag.  The `-c <count>` flag specifies the number of special/numeric characters to use.

After the wordlist is created, for each special/numeric character, per the Diceware instructions:

- a random word is chosen\*
- a random position within the word is chosen\*
- a random special/numeric character is chose from the special chars wordlist and inserted at the chosen position.  Note this is an insert, not a replace.

Per the specification, each special character/number adds 10 bits of entropy to the password strength.

\*Note: The original specification uses six-sided dice.  This limits to only adding a special character to the first six words, and will tend to add special characters to the end of the word (since most are fewer than 6 characters).  We deviate from this specification by weighting all words equally, and all positions within a word equally.


## Full Help

```
$ ./dice.rb -h
usage: dice.rb [options]

See http://world.std.com/~reinhold/diceware.html for more info.

Generator options:
    -l, --length         The number of words of which the final passphrase will consist.
    -w, --wordlist       The path (local or remote) to the wordlist used when generating the passphrase.
    -C, --capitalcnt     The number of capital letters of which the final passphrase will consist.
    -s, --speciallist    The path (local or remote) to the speciallist used when generating the passphrase.
    -c, --specialcnt     The number of special/number characters of which the final passphrase will consist.

Output options:
    -p, --plain          disable output formatting

General options:
    -v, --verbose        enable verbose output
    -h, --help, --usage  show this help text
```
