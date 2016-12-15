#!/usr/bin/env ruby

require 'slop'
require 'securerandom'
require 'open-uri'
require 'colorize'

def parse_options
  opts = Slop::Options.new
  opts.banner = "usage: dice.rb [options]\n\nSee http://world.std.com/~reinhold/diceware.html for more info."
  opts.separator ""
  opts.separator "Generator options:"
  opts.integer '-l', '--length', "The number of words of which the final passphrase will consist.", default: 6
  opts.string '-w', '--wordlist', "The path (local or remote) to the wordlist used when generating the passphrase.", default: "http://world.std.com/~reinhold/diceware.wordlist.asc"
  opts.integer '-C', '--capitalcnt', "The number of capital letters of which the final passphrase will consist.", default: 0
  opts.string '-s', '--speciallist', "The path (local or remote) to the speciallist used when generating the passphrase.", default: "special.txt"
  opts.integer '-c', '--specialcnt', "The number of special/number characters of which the final passphrase will consist.", default: 0
  opts.separator ""
  opts.separator "Output options:"
  opts.bool '-p', '--plain', 'disable output formatting'
  opts.separator ""
  opts.separator "General options:"
  opts.bool '-v', '--verbose', 'enable verbose output'
  opts.on '-h', '--help', '--usage', 'show this help text' do
    puts opts
    exit
  end

  parser = Slop::Parser.new opts
  result = parser.parse ARGV
  result
end

def msg text
  print '=> '.blue, text, "\n"
end

def err text
  print '=> '.red.bold, "\n"
end

def generate_diceware_id n_times=5
  output = String.new
  n_times.times do
    random_number = SecureRandom.random_number(6) + 1
    output << random_number.to_s
  end
  output
end

def parse_wordlist path
  begin
    file = open(path).read.split("\n")
  rescue
    err "FATAL: Could not open wordlist."
    exit
  end
  wordpairs = {}
  file.each do |line|
    md = /^([1-6]+)\s+(.+)/.match line
    if !md.nil?
      wordpairs[md[1]] = md[2]
    end
  end
  msg("Parsed #{wordpairs.length} pairs.") if $opts[:verbose]
  wordpairs
end

def generate_passphrase wordlist, speciallist, length, capitalcnt, specialcnt
  words = []
  length.times do
    id = generate_diceware_id
    words << wordlist[id]
    msg words.join ' ' if $opts[:verbose]
  end
  capitals_left = capitalcnt
  while capitals_left > 0
    word_idx = SecureRandom.random_number(length)
    word = words[word_idx]
    char_idx = SecureRandom.random_number(word.length)
    char = word[char_idx]
    # skip chars that don't change when capitalized, such as special or numbers
    next if char == char.capitalize
    words[word_idx] = "#{word[0,char_idx]}#{char.capitalize}#{word[(char_idx+1)..-1] || ''}"
    msg words.join ' ' if $opts[:verbose]
    capitals_left -= 1
  end
  specialcnt.times do
    word_idx = SecureRandom.random_number(length)
    specialid = generate_diceware_id 2
    special_char = speciallist[specialid]
    word = words[word_idx]
    char_idx = SecureRandom.random_number(word.length)
    words[word_idx] = "#{word[0,char_idx]}#{special_char}#{word[char_idx..-1] || ''}"
    msg words.join ' ' if $opts[:verbose]
  end
  words.join ' '
end

def output_result phrase
  width = phrase.length + 6
  print "/".green, '-'.green * (width-2), "\\".green, "\n"
  print "|  ".green, phrase.bold, "  |".green, "\n"
  print "\\".green, '-'.green * (width-2), "/".green, "\n"
end

def main
  $opts = parse_options
  msg("Parsing wordlist from #{$opts[:wordlist]}...") if $opts[:verbose]
  wordlist = parse_wordlist $opts[:wordlist]
  msg("Parsing speciallist from #{$opts[:speciallist]}...") if $opts[:verbose]
  speciallist = parse_wordlist $opts[:speciallist]
  passphrase = generate_passphrase wordlist, speciallist, $opts[:length], $opts[:capitalcnt], $opts[:specialcnt]
  if !$opts[:plain]
    msg("Result:") if $opts[:verbose]
    output_result passphrase
  else
    print passphrase, "\n"
  end
end

main
