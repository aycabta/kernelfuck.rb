TAPEMAX = 30000

class NestingValue
  def self.explore(a, &b)
    /([0-9]+)$/ =~ self.name
    n = $&.to_i

    begin
      self.class_eval "V#{n + 1}.explore(a, &b)"
    rescue NameError
      b.call(n, a)
    end
  end

  def self.depth
    self.explore [] do |n, a|
      n + 1
    end
  end

  def self.dig
    explore [] do |n, a|
      self.class_eval "class V#{n + 1} < NestingValue; end"
      n + 2
    end
  end

  def self.fill(a)
    explore a do |n, a|
      self.class_eval (n == 0 ? "#{a}" : (0..n - 1).map { |i| "V#{i}" }.unshift(a) * "::") + ".class_eval 'remove_const :V#{n}'"
    end
  end
end

class MemoryBucket
  def self.ptr
    "V0"
  end

  def self.val
    self.const_defined?(ptr) ? self.class_eval("#{ptr}.depth") : 0
  end

  def self.inc
    256 == (self.class_eval self.const_defined?(ptr) ? "#{ptr}.dig" : "class #{ptr} < NestingValue; end") && remove_const(ptr)
  end

  def self.dec
    self.class_eval self.const_defined?(ptr) ? "#{ptr}.fill('#{self.name}')" : (1..255).inject("") { |s, n| s = "class V#{255 - n} < NestingValue; #{s} end;" }
  end
end

(0..TAPEMAX - 1).each do |addr|
  Kernel.module_eval "class Mem#{addr} < MemoryBucket; end"
end

class Head
  def self.forward
    eval "def $:.pos#{self.pos}; end"
  end

  def self.backward
    class << $:
      eval "undef_method 'pos#{Head.pos - 1}'"
    end
  end

  def self.pos
    $:.singleton_methods.size
  end
end

def run
  Proc.new { break out }
end

ops = []
pos = 0

alias :tv :trace_var
alias :uv :untrace_var

def loop_code(b)
  %Q{
    if Mem#{Head.pos}.val #{b == '[' ? '=' : '!'}= 0
      uv(:$:)
      tv(:$:, proc {})
      $:.clear
      while uv(:$:).each { |h| tv(:$:, h) }.size > 0
        $: << nil
        case ops[pos + #{b == ']' ? '-' : ''}$:.size]
        when '#{b}'
          tv(:$:, proc {})
        when '#{b == '[' ? ']' : '['}'
          uv(:$:)[1..-1].each { |h| tv(:$:, h) }
        end
      end
      #{b == ']' ? '-' : ''}$:.size + 1
    end
  }
end

begin
  Kernel.__send__ :define_method, :method_missing,
    case pos == ops.size ? (ops << STDIN.getc)[-1] : ops[pos]
    when '<'
      proc { |a| Head.backward }
    when ">"
      proc { |a| Head.forward }
    when '+'
      proc { |a| eval "Mem#{Head.pos}.inc" }
    when "-"
      proc { |a| eval "Mem#{Head.pos}.dec" }
    when "."
      proc { |a| eval "print Mem#{Head.pos}.val.chr" }
    when "["
      proc { |a| eval loop_code('[') }
    when "]"
      proc { |a| eval loop_code(']') }
    when nil
      proc { |a| Kernel.freeze }
    else
      proc {|a|}
    end
  run.call
rescue LocalJumpError => e
  pos += (t = e.exit_value).kind_of?(Fixnum) ? t : 1
  retry
rescue RuntimeError
end

