require "eturem/version"

module Eturem
  # load script and return eturem_exception if exception raised
  # @param [String] file script file
  # @return [Eturem::Base] if exception raised
  # @return [nil] if exception did not raise
  def self.load(file)
    begin
      Kernel.load(File.expand_path(file))
    rescue Exception => exception
      return @eturem_class.new(exception) unless exception.is_a? SystemExit
    end
    return nil
  end
  
  def self.eval(expr, bind = nil, fname = "(eval)", lineno = 1)
    begin
      bind ? Kernel.eval(expr, bind, fname, lineno) : Kernel.eval(expr)
    rescue Exception => exception
      return @eturem_class.new(exception) unless exception.is_a? SystemExit
    end
    return nil
  end
  
  def self.eturem_class
    @eturem_class
  end
  
  def self.eturem_class=(klass)
    @eturem_class = klass
  end
  
  class Base
    attr_reader :exception
    
    @@output_backtrace = true
    @@output_original  = true
    @@output_script    = true
    @@use_coderay      = false
    @@max_backtrace    = 16
    @@before_line_num  = 2
    @@after_line_num   = 2
    
    @inspect_methods = {}
    
    def self.inspect_methods
      return @inspect_methods
    end
    
    def self.output_backtrace=(value)
      @@output_backtrace = value
    end
    
    def self.output_original=(value)
      @@output_original = value
    end
    
    def self.output_script=(value)
      @@output_script = value
    end
    
    def self.use_coderay=(value)
      @@use_coderay = value
    end
    
    def self.max_backtrace=(value)
      @@max_backtrace = value
    end
    
    def self.before_line_num=(value)
      @@before_line_num = value
    end
    
    def self.after_line_num=(value)
      @@after_line_num = value
    end
    
    def initialize(exception)
      @exception   = exception
      @exception_s = exception.to_s
      
      eturem_path = File.dirname(File.absolute_path(__FILE__))
      @backtrace_locations = (@exception.backtrace_locations || []).reject do |location|
        path = File.absolute_path(location.path)
        path.start_with?(eturem_path) || path.end_with?("/rubygems/core_ext/kernel_require.rb")
      end
      @backtrace_locations.each do |location|
        if $0 == location.path
          def location.label
            super.sub("<top (required)>", "<main>")
          end
        end
      end
      
      if @exception.is_a?(SyntaxError) && @exception_s.match(/\A(?<path>.+?)\:(?<lineno>\d+)/)
        @path   = Regexp.last_match(:path)
        @lineno = Regexp.last_match(:lineno).to_i
      else
        backtrace_locations_shift
      end
      
      load_script
      prepare
    end
    
    # output backtrace + error message + script
    def output
      output_backtrace if @@output_backtrace
      error_message = exception_inspect
      if error_message.to_s.empty?
        puts original_exception_inspect
      else
        puts original_exception_inspect if @@output_original
        puts error_message
      end
      output_script if @@output_script
    end
    
    def output_backtrace
      return if @backtrace_locations.empty?
      
      puts traceback_most_recent_call_last
      @backtrace_locations[0, @@max_backtrace].reverse.each_with_index do |location, i|
        puts sprintf("%9d: %s", @backtrace_locations.size - i, location_inspect(location))
      end
    end
    
    def exception_inspect
      inspect_methods = self.class.inspect_methods
      inspect_methods.keys.reverse_each do |key|
        if (key.is_a?(Class)  && @exception.is_a?(key)) || 
           (key.is_a?(String) && @exception.class.to_s == key)
          method = inspect_methods[key]
          return method ? public_send(method) : nil
        end
      end
      return nil
    end
    
    def original_exception_inspect
      if @exception.is_a? SyntaxError
        return @exception_s
      else
        location_str = "#{@path}:#{@lineno}:in `#{@label}'"
        if @exception_s.match(/\A(?<first_line>.*?)\n/)
          return "#{location_str}: #{Regexp.last_match(:first_line)} (#{@exception.class})\n" +
            "#{Regexp.last_match.post_match}"
        else
          return "#{location_str}: #{@exception_s} (#{@exception.class})"
        end
      end
    end
    
    def output_script
      return if @script.empty?
      
      max_lineno_length = @output_lines.compact.max.to_s.length
      @output_lines.each do |i|
        if @lineno == i
          puts sprintf("\e[0m => \e[1;34m%#{max_lineno_length}d\e[0m: %s", i, @script_lines[i])
        elsif i
          puts sprintf("\e[0m    \e[1;34m%#{max_lineno_length}d\e[0m: %s", i, @script_lines[i])
        else
          puts         "\e[0m    #{" " * max_lineno_length}  :"
        end
      end
    end
    
    private
    
    def prepare
      case @exception
      when SyntaxError   then prepare_syntax_error
      when NameError     then prepare_name_error
      when ArgumentError then prepare_argument_error
      when TypeError     then prepare_type_error
      end
    end
    
    def prepare_syntax_error
      @unexpected = @exception_s.match(/unexpected (?<unexpected>(?:','|[^,])+)/) ?
        Regexp.last_match(:unexpected) : nil
      @expected   = @exception_s.match(/[,\s]expecting (?<expected>\S+)/) ?
        Regexp.last_match(:expected)   : nil
      if !@expected && @exception_s.match(/(?<invalid>(?:break|next|retry|redo|yield))/)
        @invalid = Regexp.last_match(:invalid)
      end
    end
    
    def prepare_name_error
      highlight!(@script_lines[@lineno], @exception.name.to_s, "\e[1;31m\e[4m")
      return unless @exception_s.match(/Did you mean\?/)
      @did_you_mean = Regexp.last_match.post_match.strip.scan(/\S+/)
      return if @script.empty?
      
      new_range = []
      @did_you_mean.each do |name|
        index = @script_lines.index { |line| line.include?(name) }
        next unless index
        highlight!(@script_lines[index], name, "\e[1;33m")
        new_range.push(index)
      end
      new_range.sort!
      before = new_range.select { |i| i < @output_lines.first }
      after  = new_range.select { |i| i > @output_lines.last  }
      unless before.empty?
        @output_lines.unshift(nil) if before.last + 1 != @output_lines.first
        @output_lines.unshift(*before)
      end
      unless after.empty?
        @output_lines.push(nil) if @output_lines.last + 1 != after.first
        @output_lines.push(*after)
      end
    end
    
    def prepare_argument_error
      @method = @label
      old_path = @path
      backtrace_locations_shift
      load_script unless old_path == @path
      @output_lines = default_output_lines
      if @exception_s.match(/given (?<given>\d+)\, expected (?<expected>[^)]+)/)
        @given    = Regexp.last_match(:given).to_i
        @expected = Regexp.last_match(:expected)
      end
    end
    
    def prepare_type_error
      @method = @label
    end
    
    def backtrace_locations_shift
      @label  = @backtrace_locations.first.label
      @path   = @backtrace_locations.first.path
      @lineno = @backtrace_locations.first.lineno
      @backtrace_locations.shift
    end
    
    def traceback_most_recent_call_last
      "Traceback (most recent call last):"
    end
    
    def location_inspect(location)
      "from #{location.path}:#{location.lineno}:in `#{location.label}'"
    end
    
    def load_script
      @script ||= ""
      if @path && File.exist?(@path)
        @script = File.binread(@path)
        encoding = "utf-8"
        if @script.match(/\A(?:#!.*\R)?#.*coding *[:=] *(?<encoding>[^\s:]+)/)
          encoding = Regexp.last_match(:encoding)
        end
        @script.force_encoding(encoding)
      end
      @script = CodeRay.scan(@script, :ruby).terminal if @@use_coderay
      @script_lines = @script.lines
      @script_lines.unshift("")
      @output_lines = default_output_lines
    end
    
    def highlight(str, keyword, color)
      str.to_s.gsub(keyword){ color + ($1 || $&) + "\e[0m" }
    end
    
    def highlight!(str, keyword, color)
      str.gsub!(keyword){ color + ($1 || $&) + "\e[0m" } if str
    end
    
    def default_output_lines
      from = [1, @lineno - @@before_line_num].max
      to   = [@script_lines.size - 1, @lineno + @@after_line_num].min
      (from..to).to_a
    end
    
    Eturem.eturem_class = self
  end
end
