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

def build_path map, start, finish
  path = {} # [row, col] => len
  m = []
  map.each do |row|
    m << row.dup
  end
  used = Set.new
  row, col = start
  while m[row][col] != 'E'
    if m[row - 1][col] != '#' and not used.include?([row-1, col])
      path[[row, col]] = path.size
      row -= 1
    elsif m[row + 1][col] != '#' and not used.include?([row+1, col])
      path[[row, col]] = path.size
      row += 1
    elsif m[row][col - 1] != '#' and not used.include?([row, col-1])
      path[[row, col]] = path.size
      col -= 1
    elsif m[row][col + 1] != '#' and not used.include?([row, col+1])
      path[[row, col]] = path.size
      col += 1
    end
    used << [row, col]
  end
  path[[row,col]] = path.size
  path
end

def get_cheats map, path, total
  cheats = [] # [[row, col, saved],...]
  path.each do |pos,len|
    row, col = pos
    [[row-2, col], [row+2, col], [row, col-2], [row, col+2]].each do |cheat|
      r, c = cheat
      if r >= 0 and r < map.size and c >= 0 and c < map[0].size
        next if map[r][c] == '#'
        next unless len < path[cheat]
        rest = total - path[cheat]
        cheat_path = len + rest + 2
        saved = total - cheat_path
        cheats << [row, col, r, c, saved]
      end
    end
  end
  cheats
end

def collect_exits map, row, col, dist
  exits = Set.new
  (dist + 1).times do |d|
    ((row - d)..(row + d)).each do |tr|
      ((col - d)..(col + d)).each do |tc|
        totd = (row - tr).abs + (col - tc).abs
        next unless totd <= dist
        next if [tr, tc] == [row, col]
        if tr >= 0 and tr < map.size and tc >= 0 and tc < map[0].size
          if ['E', '.'].include?(map[tr][tc])
            exits << [tr, tc]
          end
        end
      end
    end
  end
  exits
end

def get_cheats2 map, path, total, dist
  cheats = [] # [[row, col, saved],...]
  path.each do |pos,len|
    row, col = pos
    checks = collect_exits map, row, col, dist
    checks.each do |cheat|
      r, c = cheat
      next if map[r][c] == '#'
      next unless len < path[cheat]
      rest = total - path[cheat]
      d = (row - r).abs + (col - c).abs
      cheat_path = len + rest + d
      saved = total - cheat_path
      next unless saved > 0
      cheats << [row, col, r, c, saved]
    end
  end
  cheats
end

def part1
  # lines = parse_as_lines INPUT
  # tokens = parse_as_tokens INPUT
  map = []
  start = nil
  finish = nil
  parse_as_custom(INPUT) { |line|
    if start.nil?
      p = line.index('S')
      start = [map.size, p] unless p.nil?
    end
    if start.nil?
      p = line.index('E')
      finish = [map.size, p] unless p.nil?
    end
    map << line.chomp.split(//)
  }
  path = build_path map, start, finish
  cheats = get_cheats map, path, path.size - 1
  tot = 0
  cheats.each do |row, col, r, c, save|
    tot += 1 if save >= 100
  end
  puts tot
end


def part2
  # lines = parse_as_lines INPUT
  # tokens = parse_as_tokens INPUT
  map = []
  start = nil
  finish = nil
  parse_as_custom(INPUT) { |line|
    if start.nil?
      p = line.index('S')
      start = [map.size, p] unless p.nil?
    end
    if start.nil?
      p = line.index('E')
      finish = [map.size, p] unless p.nil?
    end
    map << line.chomp.split(//)
  }
  path = build_path map, start, finish
  cheats = get_cheats2 map, path, path.size - 1, 20
  saved = {}
  tot = 0
  cheats.each do |row, col, r, c, save|
    tot += 1 if save >= 100
  end
  puts tot
end

part1
part2
