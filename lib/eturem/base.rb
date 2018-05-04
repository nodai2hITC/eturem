module Eturem
  def self.set_eturem_class(klass)
    @eturem_class = klass
  end
  
  def self.output_error(exception, eturem_path)
    @eturem_class.new(exception, eturem_path).output_error
  end
  
  class Base
    def initialize(exception, eturem_path)
      @exception   = exception
      @exception_s = exception.to_s
      @eturem_path = eturem_path
      @locations   = @exception.backtrace_locations.select do |location|
        path = File.absolute_path(location.path)
        path !~ /\/rubygems\/core_ext\/kernel_require\.rb$/ &&
        path != @eturem_path &&
        File.basename(File.dirname(path)) != "eturem"
      end
      @locations = @locations[0, max_backtrace]
      if @exception_s.match(/\A(?<path>[^:]+)\:(?<lineno>\d+)/)
        @lineno_in_exception_s = true
        @path   = Regexp.last_match(:path)
        @lineno = Regexp.last_match(:lineno).to_i
      else
        @lineno_in_exception_s = false
        @path   = @locations.first.path
        @lineno = @locations.first.lineno
      end
      @script = ""
      if @path && File.exist?(@path)
        @script = File.binread(@path)
        encoding = @script.lines[0..2].join("\n").match(/coding:\s*(?<encoding>\S+)/) ?
          Regexp.last_match(:encoding) : "UTF-8"
        @script.force_encoding(encoding)
        @script.encode("UTF-8")
      end
      @script_lines = @script.lines
      @script_lines.unshift("")
      @range = default_range
      prepare
    end
    
    def prepare
      case @exception
      when SyntaxError
        return unless @exception_s.match(/unexpected (?<unexpected>\S+)\,\s*expecting (?<expected>\S+)/)
        @unexpected = Regexp.last_match(:unexpected)
        @expected   = Regexp.last_match(:expected)
      when NameError
        highlight!(@script_lines[@lineno], @exception.name.to_s, "\e[31m\e[4m")
        return unless @exception_s.match(/Did you mean\?/)
        @did_you_mean = Regexp.last_match.post_match.strip.split(/\s+/)
        new_range = []
        @did_you_mean.each do |did_you_mean|
          index = @script_lines.index{|line| line.match(did_you_mean)}
          next unless index
          highlight!(@script_lines[index], did_you_mean, "\e[33m")
          new_range.push(index)
        end
        before = new_range.select{|i| i < @range.min}
        after  = new_range.select{|i| i > @range.max}
        unless before.empty?
          @range.unshift(0) unless @range.include?(before.max + 1)
          @range.unshift(*before.sort)
        end
        unless after.empty?
          @range.push(0) unless @range.include?(after.min - 1)
          @range.push(*after.sort)
        end
      when ArgumentError
        @method = @locations.first.label
        shift_locations
        return unless @exception_s.match(/given (?<given>\d+)\, expected (?<expected>[^)]+)/)
        @given    = Regexp.last_match(:given).to_i
        @expected = Regexp.last_match(:expected)
      when TypeError
        @method = @locations.first.label
        shift_locations
      end
    end
    
    def shift_locations
      @locations.shift
      @path   = @locations.first.path
      @lineno = @locations.first.lineno
      @range  = default_range
    end
    
    def default_range
      from = [1, @lineno - before_line].max
      to   = [@script_lines.size - 1, @lineno + after_line].min
      (from..to).to_a
    end
    
    def output_error
      output_backtrace
      output_exception
      output_script
    end
    
    # backtrace
    def output_backtrace
      return if backtrace.empty?
      
      puts traceback_most_recent_call_last
      backtrace.each_with_index do |location, i|
        label =
          $0 == location.path && location.label == "<top (required)>" ?
          "<main>" : location.label
        puts sprintf("%9d: %s", backtrace.size - i, location_inspect(location, label))
      end
    end
    
    def backtrace
      get_backtrace unless @backtrace
      return @backtrace
    end
    
    def get_backtrace
      @backtrace = @locations.reverse.dup
      @backtrace.pop unless @lineno_in_exception_s
    end
    
    def max_backtrace
      16
    end
    
    def traceback_most_recent_call_last
      "Traceback (most recent call last):"
    end
    
    def location_inspect(location, label = nil)
      "from #{location.path}:#{location.lineno}:in `#{label || location.label}'"
    end
    
    # exception
    def output_exception
      puts exception_inspect
    end
    
    def exception_inspect
      original_exception_inspect
    end
    
    def original_exception_inspect
      if @lineno_in_exception_s
        return @exception_s
      else
        label  = @locations.first.label
        label = "<main>" if $0 == @path && label == "<top (required)>"
        location_str = "#{@path}:#{@lineno}:in `#{label}'"
        if @exception_s.match(/\A(.*?)\n/)
          matched = Regexp.last_match
          return "#{location_str}: #{matched[1]} (#{@exception.class})\n#{matched.post_match}"
        else
          return "#{location_str}: #{@exception} (#{@exception.class})"
        end
      end
    end
    
    # script
    def output_script
      max_lineno_length = @range.max.to_s.length
      @range.each do |i|
        if i == 0
          puts "    \e[34m#{" " * max_lineno_length}  :\e[0m"
        else
          if @lineno == i
            puts sprintf(" => \e[34m%#{max_lineno_length}d:\e[0m %s", i, @script_lines[i])
          else
            puts sprintf("    \e[34m%#{max_lineno_length}d:\e[0m %s", i, @script_lines[i])
          end
        end
      end
    end
    
    def before_line
      2
    end
    
    def after_line
      2
    end
    
    def highlight(str, keyword, color)
      str.gsub(keyword){ color + ($1 || $&) + "\e[0m" }
    end

    def highlight!(str, keyword, color)
      str.gsub!(keyword){ color + ($1 || $&) + "\e[0m" }
    end
  end
  
  set_eturem_class Base
end
