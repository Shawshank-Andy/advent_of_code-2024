#!/usr/bin/env ruby

require 'set'

INPUT = "input"

# Returns the input as an array of lines
def parse_as_lines path
  lines = []
  File.open(path, 'rb').each { |line| lines << line.chomp }
  lines
end

# Returns the input as an array or arrays of whitespace tokenized lines
def parse_as_tokens path
  lines = []
  File.open(path, 'rb').each { |line| lines << line.chomp.split }
  lines
end

# Returns the input as an array with each line the results of lambda.call(line)
def parse_as_custom path, &func
  data = []
  File.open(path, 'rb').each { |line| data << func.call(line) }
  data
end

def can_make pattern, xs
  return true if pattern.empty?
  xs.each do |x|
    if pattern.start_with?(x)
      return true if can_make(pattern[(x.size)..-1], xs)
    end
  end
  false
end

$cache = {} # {pattern => count}
def can_make2 pattern, xs
  return 0 if pattern.empty?
  return $cache[pattern] if $cache.include?(pattern)
  $cache[pattern] ||= 0
  xs.each do |x|
    if pattern == x
      $cache[pattern] += 1
    elsif pattern.start_with?(x)
      $cache[pattern] += can_make2(pattern[(x.size)..-1], xs)
    end
  end
  $cache[pattern]
end

def part1
  # lines = parse_as_lines INPUT
  # tokens = parse_as_tokens INPUT
  towels = []
  patterns = []
  parse_as_custom(INPUT) { |line| 
    if towels.empty?
      towels = line.chomp.split(', ')
    else
      next if line =~ /^\s*$/
      patterns << line.chomp
    end
  }

  tot = 0
  patterns.each do |pattern|
    tot += 1 if can_make(pattern, towels)
  end
  puts tot
end


def part2
  # lines = parse_as_lines INPUT
  # tokens = parse_as_tokens INPUT
  towels = []
  patterns = []
  parse_as_custom(INPUT) { |line| 
    if towels.empty?
      towels = line.chomp.split(', ')
    else
      next if line =~ /^\s*$/
      patterns << line.chomp
    end
  }

  tot = 0
  patterns.each do |pattern|
    tot += can_make2(pattern, towels)
  end
  puts tot
end


part1
part2
