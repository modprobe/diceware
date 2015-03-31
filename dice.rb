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

def generate_diceware_id
  output = String.new
  5.times do
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
    md = /([1-6]{5})\s(.+)/.match line
    if !md.nil?
      wordpairs[md[1]] = md[2]
    end
  end
  $opts[:verbose] && msg("Parsed #{wordpairs.length} pairs.")
  wordpairs
end

def generate_passphrase wordlist, length
  words = []
  length.times do
    id = generate_diceware_id
    words << wordlist[id]
  end
  words.join " "
end

def output_result phrase
  width = phrase.length + 6
  print "/".green, '-'.green * (width-2), "\\".green, "\n"
  print "|  ".green, phrase.bold, "  |".green, "\n"
  print "\\".green, '-'.green * (width-2), "/".green, "\n"
end

def main
  $opts = parse_options
  $opts[:verbose] && msg("Parsing wordlist from #{$opts[:wordlist]}...")
  wordlist = parse_wordlist $opts[:wordlist]
  passphrase = generate_passphrase wordlist, $opts[:length]
  if !$opts[:plain]
    $opts[:verbose] && msg("Result:")
    output_result passphrase
  else
    print passphrase, "\n"
  end
end

main
