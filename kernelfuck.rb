TAPEMAX = 30000

class NestingValue
  def self.explore(func_name, args, &block)
    regexp = Regexp.new('([0-9]+)$')
    match = regexp.match(self.name)
    num = match[0].to_i

    steps_of_hole = []
    begin
      self.class_eval %Q{
        Val#{num + 1}.#{func_name}(args)
      }
    rescue NameError => e
      block.call(num, args)
    end
  end

  def self.depth(args)
    self.explore :depth, args do |num, args|
      num + 1
    end
  end

  def self.dig(args)
    explore :dig, args do |num, args|
      self.class_eval %Q{
        class Val#{num + 1} < NestingValue
        end
      }
      num + 1
    end
  end

  def self.fill(args)
    explore :fill, args do |num, args|
      if num == 0
        grand = "#{args}"
      else
        grand = (0..num - 1).collect { |i| "Val#{i}" }.unshift(args).join("::")
      end
      self.class_eval %Q{
        #{grand}.class_eval do
          remove_const :Val#{num}
        end
      } 
    end
  end
end

TAPEMAX = 30000

class NestingValue
  def self.explore(func_name, args, &block)
    regexp = Regexp.new('([0-9]+)$')
    match = regexp.match(self.name)
    num = match[0].to_i

    steps_of_hole = []
    begin
      self.class_eval %Q{
        Val#{num + 1}.#{func_name}(args)
      }
    rescue NameError => e
      block.call(num, args)
    end
  end

  def self.depth(args)
    self.explore :depth, args do |num, args|
      num + 1
    end
  end

  def self.dig(args)
    explore :dig, args do |num, args|
      self.class_eval %Q{
        class Val#{num + 1} < NestingValue
        end
      }
      num + 1
    end
  end

  def self.fill(args)
    explore :fill, args do |num, args|
      if num == 0
        grand = "#{args}"
      else
        grand = (0..num - 1).collect { |i| "Val#{i}" }.unshift(args).join("::")
      end
      self.class_eval %Q{
        #{grand}.class_eval do
          remove_const :Val#{num}
        end
      } 
    end
  end
end

TAPEMAX = 30000

class NestingValue
  def self.explore(func_name, args, &block)
    regexp = Regexp.new('([0-9]+)$')
    match = regexp.match(self.name)
    num = match[0].to_i

    steps_of_hole = []
    begin
      self.class_eval %Q{
        Val#{num + 1}.#{func_name}(args)
      }
    rescue NameError => e
      block.call(num, args)
    end
  end

  def self.depth(args)
    self.explore :depth, args do |num, args|
      num + 1
    end
  end

  def self.dig(args)
    explore :dig, args do |num, args|
      self.class_eval %Q{
        class Val#{num + 1} < NestingValue
        end
      }
      num + 1
    end
  end

  def self.fill(args)
    explore :fill, args do |num, args|
      if num == 0
        grand = "#{args}"
      else
        grand = (0..num - 1).collect { |i| "Val#{i}" }.unshift(args).join("::")
      end
      self.class_eval %Q{
        #{grand}.class_eval do
          remove_const :Val#{num}
        end
      } 
    end
  end
end

TAPEMAX = 30000

class NestingValue
  def self.explore(func_name, args, &block)
    regexp = Regexp.new('([0-9]+)$')
    match = regexp.match(self.name)
    num = match[0].to_i

    steps_of_hole = []
    begin
      self.class_eval %Q{
        Val#{num + 1}.#{func_name}(args)
      }
    rescue NameError => e
      block.call(num, args)
    end
  end

  def self.depth(args)
    self.explore :depth, args do |num, args|
      num + 1
    end
  end

  def self.dig(args)
    explore :dig, args do |num, args|
      self.class_eval %Q{
        class Val#{num + 1} < NestingValue
        end
      }
      num + 1
    end
  end

  def self.fill(args)
    explore :fill, args do |num, args|
      if num == 0
        grand = "#{args}"
      else
        grand = (0..num - 1).collect { |i| "Val#{i}" }.unshift(args).join("::")
      end
      self.class_eval %Q{
        #{grand}.class_eval do
          remove_const :Val#{num}
        end
      } 
    end
  end
end

class MemoryBucket
  def self.pointer 
    "Val0"
  end

  def self.val 
    if not self.const_defined? pointer
      0
    else
      self.class_eval %Q{
        #{pointer}.depth([]) 
      }
    end
  end

  def self.inc
    result = if not self.const_defined? pointer
      self.class_eval %Q{
        class #{pointer} < NestingValue
        end
      }
      1
    else
      self.class_eval %Q{
        #{pointer}.dig([])
      }
    end

    if result == 255
      self.class_eval do
        remove_const :Val0
      end
    end
  end

  def self.dec
    if not self.const_defined? pointer
      self.class_eval (0..254).inject("") { |define, num| define = "class Val#{254 - num} < NestingValue; #{define} end;" }
    else
      self.class_eval %Q{
        #{pointer}.fill("#{self.name}")
      }
    end
  end
end

(0..TAPEMAX - 1).each do |address|
  Kernel.module_eval %Q{
    class Memory#{address} < MemoryBucket
    end
  }
end

class HeadPosition
  @@uu = ""
  def self.inc
    eval %Q{
      def $:.sheep#{self.val}
      end
    }
  end

  def self.dec
    class << $:
      eval %Q{
        undef_method "sheep#{HeadPosition.val - 1}"
      }
    end
  end

  def self.val
    $:.singleton_methods.size
  end
end

count = 0
ops = "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>.".split('')
pos = 0
begin
  Kernel.__send__ :define_method, :method_missing,
    case ops[pos]
    when '<'
      lambda do |*args|
        HeadPosition.dec
      end
    when ">"
      lambda do |*args|
        HeadPosition.inc
      end
    when '+'
      lambda do |*a|
        eval "Memory#{HeadPosition.val}.inc"
      end
    when "-"
      lambda do |*a|
        eval "Memory#{HeadPosition.val}.dec"
      end
    when "."
      lambda do |*a|
        eval "print Memory#{HeadPosition.val}.val.chr"
      end
    when "["
      lambda do |*a|
        eval %Q{
          if Memory#{HeadPosition.val}.val == 0
            cnt = 1
            pos += 1
            while cnt > 0
              case ops[pos]
              when '['
                cnt += 1
              when ']'
                cnt -= 1
              end
              pos += 1
            end
          end
        }
      end
    when "]"
      lambda do |*a|
        eval %Q{
          if Memory#{HeadPosition.val}.val != 0
            cnt = 1
            pos -= 1
            while cnt > 0
              case ops[pos]
              when ']'
                cnt += 1
              when '['
                cnt -= 1
              end
              pos -= 1
            end
          end
        }
      end
    when nil
      lambda do |*a|
        Kernel.freeze
      end
    else
      lambda do |*a|
      end
    end
  run
  pos += 1
  raise LocalJumpError.new()
rescue LocalJumpError => e
  retry
rescue RuntimeError
end