require "eturem/version"

module Eturem
  # load script and return eturem_exception if exception raised
  # @param [String] file script file
  # @return [Eturem::Base] if exception raised
  # @return [nil] if exception did not raise
  def self.load(file)
    begin
      Kernel.load(File.absolute_path(file))
    rescue Exception => exception
      return @eturem_class.new(exception, file) unless exception.is_a? SystemExit
    end
    return nil
  end
  
  def self.load_and_output(file, debug = false)
    begin
      Kernel.load(File.absolute_path(file))
    rescue Exception => exception
      begin
        puts @eturem_class.new(exception, file).inspect unless exception.is_a? SystemExit
      rescue Exception => e
        raise debug ? e : exception
      end
    end
  end
  
  def self.eval(expr, bind = nil, fname = "(eval)", lineno = 1)
    begin
      bind ? Kernel.eval(expr, bind, fname, lineno) : Kernel.eval(expr)
    rescue Exception => exception
      return @eturem_class.new(exception, fname) unless exception.is_a? SystemExit
    end
    return nil
  end
  
  def self.set_config(config)
    @eturem_class.set_config(config)
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
    
    def self.set_config(config)
      @@output_backtrace = config[:output_backtrace] if config.has_key?(:output_backtrace)
      @@output_original  = config[:output_original]  if config.has_key?(:output_original)
      @@output_script    = config[:output_script]    if config.has_key?(:output_script)
      @@use_coderay      = config[:use_coderay]      if config.has_key?(:use_coderay)
      @@max_backtrace    = config[:max_backtrace]    if config.has_key?(:max_backtrace)
      @@before_line_num  = config[:before_line_num]  if config.has_key?(:before_line_num)
      @@after_line_num   = config[:after_line_num]   if config.has_key?(:after_line_num)
    end
    
    def initialize(exception, load_file)
      @exception   = exception
      @exception_s = exception.to_s
      
      eturem_path = File.dirname(File.absolute_path(__FILE__))
      @backtrace_locations = (@exception.backtrace_locations || []).reject do |location|
        path = File.absolute_path(location.path)
        path.start_with?(eturem_path) || path.end_with?("/rubygems/core_ext/kernel_require.rb")
      end
      @backtrace_locations.each do |location|
        if File.absolute_path(load_file) == location.path
          if load_file == $0
            def location.path
              $0
            end
          end
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
    
    def inspect
      str = ""
      str = backtrace_inspect if @@output_backtrace
      error_message = exception_inspect
      if error_message.empty?
        str += original_exception_inspect
      else
        str += original_exception_inspect + "\n" if @@output_original
        str += error_message + "\n"
      end
      str += script_inspect if @@output_script
      return str
    end
    
    def backtrace_inspect
      return "" if @backtrace_locations.empty?
      
      str = traceback_most_recent_call_last + "\n"
      @backtrace_locations[0, @@max_backtrace].reverse.each_with_index do |location, i|
        str += sprintf("%9d: %s\n", @backtrace_locations.size - i, location_inspect(location))
      end
      return str
    end
    
    def exception_inspect
      inspect_methods = self.class.inspect_methods
      inspect_methods.keys.reverse_each do |key|
        if (key.is_a?(Class)  && @exception.is_a?(key)) || 
           (key.is_a?(String) && @exception.class.to_s == key)
          method = inspect_methods[key]
          return method ? public_send(method) : ""
        end
      end
      return ""
    end
    
    def original_exception_inspect
      if @exception.is_a? SyntaxError
        return @exception_s
      else
        location_str = "#{@path}:#{@lineno}:in `#{@label}'"
        @exception_s.match(/\A(?<first_line>.*)/)
        return "#{location_str}: #{Regexp.last_match(:first_line)} (\e[4m#{@exception.class}\e[0m)" +
               "#{Regexp.last_match.post_match.chomp}\n"
      end
    end
    
    def script_inspect
      return "" if @script.empty?
      
      str = ""
      max_lineno_length = @output_lines.max.to_s.length
      last_i = @output_lines.min - 1
      @output_lines.sort.each do |i|
        str += "\e[0m    #{' ' * max_lineno_length}  :\n" if last_i + 1 != i
        str += @lineno == i ? "\e[0m => \e[1;34m" : "\e[0m    \e[1;34m"
        str += sprintf("%#{max_lineno_length}d\e[0m: %s", i, @script_lines[i])
        last_i = i
      end
      return str
    end
    
    private
    
    def prepare
      case @exception
      when NameError     then prepare_name_error
      when ArgumentError then prepare_argument_error
      end
    end
    
    def prepare_name_error
      highlight!(@script_lines[@lineno], @exception.name.to_s, "\e[1;31m\e[4m")
      return unless @exception_s.match(/Did you mean\?/)
      @did_you_mean = Regexp.last_match.post_match.strip.scan(/\S+/)
      return if @script.empty?
      
      @did_you_mean.each do |name|
        index = @script_lines.index { |line| line.include?(name) }
        next unless index
        highlight!(@script_lines[index], name, "\e[1;33m")
        @output_lines.push(index)
      end
    end
    
    def prepare_argument_error
      @method = @label
      old_path = @path
      backtrace_locations_shift
      load_script unless old_path == @path
      @output_lines = default_output_lines
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
      if @@use_coderay
        require "coderay" 
        @script = CodeRay.scan(@script, :ruby).terminal
      end
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
  end
  
  @eturem_class = Base
end
