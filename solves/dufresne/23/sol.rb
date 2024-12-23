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


def part1
  # lines = parse_as_lines INPUT
  # tokens = parse_as_tokens INPUT
  pairs = {} # {src -> [dst]}
  parse_as_custom(INPUT) { |line|
    src, dst = line.chomp.split('-')
    pairs[src] ||= Set.new
    pairs[dst] ||= Set.new
    pairs[src] << dst
    pairs[dst] << src
  }
  trios = Set.new
  pairs.each do |src,dsts|
    dsts.each do |dst1|
      (dsts - [dst1]).each do |dst2|
        next unless pairs[dst1].include?(src)
        next unless pairs[dst1].include?(dst2)
        next unless pairs[dst2].include?(src)
        next unless pairs[dst2].include?(dst1)
        trio = [src,dst1,dst2]
        trio.each do |node|
          if node.start_with?('t')
            trios << [src,dst1,dst2].sort
          end
        end
      end
    end
  end
  puts trios.size
end


def part2
  # lines = parse_as_lines INPUT
  # tokens = parse_as_tokens INPUT
  links = Set.new # { [src,dst] }
  peers = {} # {src -> [dst]}
  parse_as_custom(INPUT) { |line|
    src, dst = line.chomp.split('-')
    links << [src,dst]
    links << [dst,src]
    peers[src] ||= Set.new
    peers[dst] ||= Set.new
    peers[src] << dst
    peers[dst] << src
  }
  best = Set.new
  peers.each do |src,dsts|
    nodes = Set.new
    dsts.each do |dst|
      nodes += peers[dst]
    end
    # Have superset of all nodes. Iterate to remove ones without a complete match
    # Continue until set does not change
    last_size = 0
    while nodes.size != last_size
      last_size = nodes.size
      to_remove = nil
      nodes.each do |s|
        nodes.each do |d|
          next if s == d
          unless links.include?([s,d])
            if peers[s].size > peers[d].size
              to_remove = s
            else
              to_remove = d
            end
            break
          end
        end
        break unless to_remove.nil?
      end
      unless to_remove.nil?
        nodes -= [to_remove]
      end
    end
    if nodes.size > best.size
      best = nodes.dup
    end
  end
  puts best.sort.join(',')
end


part1
part2
