#!/usr/bin/env ruby

require 'set'

INPUT = "input"

PRUNE = 16777216

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

def step num, iters
  n = num
  iters.times do 
    n = (n ^ (n * 64)) % PRUNE
    n = (n ^ (n / 32)) % PRUNE
    n = (n ^ (n * 2048)) % PRUNE
  end
  n
end

def part1
  # lines = parse_as_lines INPUT
  # tokens = parse_as_tokens INPUT
  custom = parse_as_custom(INPUT) { |line| line.chomp.to_i }
  tot = 0
  custom.each do |secret|
    s = step(secret, 2000)
    tot += s
  end
  puts tot
end


def part2
  # lines = parse_as_lines INPUT
  # tokens = parse_as_tokens INPUT
  custom = parse_as_custom(INPUT) { |line| line.chomp.to_i }
  quads = {} # {secret => { quad => price }}
  all_quads = Set.new
  custom.each do |secret|
    quads[secret] = {}
    s = secret
    last = s
    quad = []
    2000.times do 
      s = step(s, 1)
      diff = (s % 10) - (last % 10)
      last = s
      quad << diff
      if quad.size == 4
        all_quads << quad.dup
        # Only take the first occurance
        unless quads[secret].include?(quad)
          quads[secret][quad.dup] = s % 10
        end
        quad.shift
      end
    end
  end
  best = 0
  qs = all_quads.to_a
  while not qs.empty?
    quad = qs.shift
    tot = 0
    quads.each do |s, q|
      tot += (q[quad] || 0)
    end
    best = [best, tot].max
  end
  puts best
end


part1
part2
