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

class Wire
  attr_accessor :state, :val, :name
  def initialize(name, state = nil)
    @name = name
    @val = nil
    if ['x', 'y', 'z'].include?(name[0])
      @val = name[1..-1].to_i
    end
    @state = state
  end
  def dup
    Wire.new(@name, @state)
  end
end

class Gate
  attr_accessor :input, :output
  def initialize(op, wire1, wire2, out)
    @op = op
    @input = [wire1, wire2]
    @output = out
  end
  def eval
    w1, w2 = @input
    return nil if [w1.state, w2.state].include?(nil)
    res = nil
    case @op
    when :xor
      res = w1.state != w2.state
    when :and
      res = [w1.state, w2.state].all?(true)
    when :or 
      res = [w1.state, w2.state].include?(true)
    else
      raise "Invalid op: #{op}"
    end
    @output.state = res
  end
  def swap other
    @output, other.output = other.output, @output
  end
  def dup
    Gate.new(@op, @input[0].dup, @input[1].dup, @output.dup)
  end
end

def part1
  # lines = parse_as_lines INPUT
  # tokens = parse_as_tokens INPUT
  wires = {}   
  gates = []
  parse_as_custom(INPUT) { |line|
    if line =~ /:/
      a,b = line.chomp.split(': ')
      wires[a] = Wire.new(a, b.to_i == 1)
    elsif line =~ /->/
      eq, out = line.chomp.split(' -> ')
      w1, op, w2 = eq.split
      wires[w1] = Wire.new(w1) unless wires.include?(w1)
      wires[w2] = Wire.new(w2) unless wires.include?(w2)
      wires[out] = Wire.new(out) unless wires.include?(out)
      gop = nil
      case op
      when 'XOR'
        gop = :xor
      when 'AND'
        gop = :and
      when 'OR'
        gop = :or
      else
        raise "Unsupported op: #{op}"
      end
      g = Gate.new(gop, wires[w1], wires[w2], wires[out])
      g.eval
      gates << g
    end
  }
  pending = 1
  while pending > 0
    pending = 0
    gates.each do |g|
      o = g.eval
      pending += 1 if o.nil?
    end
  end
  vals = []
  wires.each do |name, wire|
    next unless name =~ /^z/
    vals << [wire.val, wire.state]
  end
  bits = '0b'
  vals.sort.reverse.each do |val, state|
    bits << (state ? '1' : '0')
  end
  puts bits.to_i(2)
end

# FIXME: The real solution probably needs to work backwards from the 
# bits that are wrong to identify candidates for swapping
def run_gates orig_wires, orig_gates
end

def part2
  # lines = parse_as_lines INPUT
  # tokens = parse_as_tokens INPUT
  wires = {}   
  gates = []
  parse_as_custom(INPUT) { |line|
    if line =~ /:/
      a,b = line.chomp.split(': ')
      wires[a] = Wire.new(a, b.to_i == 1)
    elsif line =~ /->/
      eq, out = line.chomp.split(' -> ')
      w1, op, w2 = eq.split
      wires[w1] = Wire.new(w1) unless wires.include?(w1)
      wires[w2] = Wire.new(w2) unless wires.include?(w2)
      wires[out] = Wire.new(out) unless wires.include?(out)
      gop = nil
      case op
      when 'XOR'
        gop = :xor
      when 'AND'
        gop = :and
      when 'OR'
        gop = :or
      else
        raise "Unsupported op: #{op}"
      end
      g = Gate.new(gop, wires[w1], wires[w2], wires[out])
      g.eval
      gates << g
    end
  }
  run_gates(wires, gates)
end


part1
part2
