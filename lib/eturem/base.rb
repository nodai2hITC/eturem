require "eturem/version"

module Eturem
  # load script and return eturem_exception if exception raised
  # @param [String] file script file
  # @return [Eturem::Base] if exception raised
  # @return [nil] if exception did not raise
  def self.load(file)
    eturem = @eturem_class.new(file)
    begin
      Kernel.load(file)
    rescue Exception => exception
      raise exception if exception.is_a? SystemExit
      eturem.exception = exception
    end
    eturem.exception ? eturem : nil
  end
  
  def self.load_and_output(file, repl = nil, debug = false)
    eturem = @eturem_class.new(file, true)
    last_binding = nil
    tp = TracePoint.trace(:raise) do |t|
      last_binding = t.binding unless File.expand_path(t.path) == File.expand_path(__FILE__)
    end
    script = read_script(file)
    begin
      TOPLEVEL_BINDING.eval(script, file, 1)
      tp.disable
      eturem.comeback_stderr
    rescue Exception => exception
      tp.disable
      eturem.comeback_stderr
      raise exception if exception.is_a? SystemExit
      repl ||= $eturem_repl
      use_repl = repl && last_binding && exception.is_a?(StandardError)
      begin
        eturem.exception = exception
        $stderr.write eturem.inspect
      rescue Exception => e
        raise debug ? e : eturem.exception
      end
      return unless use_repl
      require repl
      last_binding.public_send(repl)
    end
  end
  
  def self.eval(expr, bind = nil, fname = "(eval)", lineno = 1)
    eturem = @eturem_class.new(fname)
    begin
      bind ? Kernel.eval(expr, bind, fname, lineno) : Kernel.eval(expr)
    rescue Exception => exception
      raise exception if exception.is_a? SystemExit
      eturem.exception = exception
    end
    return eturem.exception ? eturem : nil
  end
  
  def self.set_config(config)
    @eturem_class.set_config(config)
  end
  
  def self.read_script(file)
    script = nil
    if File.exist?(file)
      script = File.binread(file)
      encoding = "utf-8"
      if script.match(/\A(?:#!.*\R)?#.*coding *[:=] *(?<encoding>[^\s:]+)/)
        encoding = Regexp.last_match(:encoding)
      end
      script.force_encoding(encoding)
    end
    return script
  end
  
  class Base
    attr_reader :exception, :backtrace_locations, :path, :lineno, :label
    
    @@output_backtrace = true
    @@output_original  = true
    @@output_script    = true
    @@use_coderay      = false
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
      @@before_line_num  = config[:before_line_num]  if config.has_key?(:before_line_num)
      @@after_line_num   = config[:after_line_num]   if config.has_key?(:after_line_num)
    end
    
    def initialize(load_file, replace_stderr = false)
      @load_file = load_file.encode("utf-8")
      @scripts = {}
      @decoration = {}
      if replace_stderr
        @stderr = $stderr
        $stderr = self
      end
    end
    
    def exception=(exception)
      @exception   = exception
      @exception_s = exception.to_s
      
      eturem_path = File.dirname(File.expand_path(__FILE__))
      @backtrace_locations = (@exception.backtrace_locations || []).reject do |location|
        path = File.expand_path(location.path)
        path.start_with?(eturem_path) || path.end_with?("/rubygems/core_ext/kernel_require.rb")
      end
      
      if @exception.is_a?(SyntaxError) && @exception_s.match(/\A(?<path>.+?)\:(?<lineno>\d+)/)
        @path   = Regexp.last_match(:path)
        @lineno = Regexp.last_match(:lineno).to_i
      else
        backtrace_locations_shift
      end
      
      @script_lines = read_script(@path) || []
      @output_linenos = default_output_linenos
      prepare
    end
    
    def inspect
      str = @@output_backtrace ? backtrace_inspect : ""
      error_message = exception_inspect
      if error_message.empty?
        str << original_exception_inspect
      else
        str = "#{original_exception_inspect}\n#{str}" if @@output_original
        str << "#{error_message}\n"
      end
      str << script_inspect if @@output_script
      return str
    end
    
    def backtrace_inspect
      return "" if @backtrace_locations.empty?
      
      str = "#{traceback_most_recent_call_last}\n"
      backtraces = []
      size = @backtrace_locations.size
      format = "%#{8 + size.to_s.length}d: %s\n"
      @backtrace_locations.reverse.each_with_index do |location, i|
        backtraces.push(sprintf(format, size - i, location_inspect(location)))
      end
      
      if @exception_s == "stack level too deep"
        str << backtraces[0..7].join
        str << "         ... #{backtraces.size - 12} levels...\n"
        str << backtraces[-4..-1].join
      else
        str << backtraces.join
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
        return "#{@exception_s.chomp}\n"
      else
        location_str = "#{@path}:#{@lineno}:in `#{@label}'"
        @exception_s.match(/\A(?<first_line>.*)/)
        return "#{location_str}: #{Regexp.last_match(:first_line)} (\e[4m#{@exception.class}\e[0m)" +
               "#{Regexp.last_match.post_match.chomp}\n"
      end
    end
    
    def script_inspect(path = @path, linenos = @output_linenos, lineno = @lineno, decoration = @decoration)
      script_lines = read_script(path)
      return "" unless script_lines
      
      str = ""
      max_lineno_length = linenos.max.to_s.length
      last_i = linenos.min - 1
      linenos.uniq.sort.each do |i|
        line = script_lines[i]
        line = highlight(line, decoration[i][0], decoration[i][1]) if decoration[i]
        str << "\e[0m    #{' ' * max_lineno_length}  :\n" if last_i + 1 != i
        str << (lineno == i ? "\e[0m => \e[1;34m" : "\e[0m    \e[1;34m")
        str << sprintf("%#{max_lineno_length}d\e[0m: %s\n", i, line)
        last_i = i
      end
      return str
    end
    
    def write(*str)
      message = nil
      if str.join.force_encoding("utf-8").match(/^(.+?):(\d+):\s*warning:\s*/)
        path, lineno, warning = $1, $2.to_i, $'.strip
        message = warning_message(path, lineno, warning)
      end
      if message
        @stderr.write(message)
      else
        @stderr.write(*str)
      end
    end
    
    def comeback_stderr
      $stderr = @stderr || STDERR
    end
    
    def to_s
      @exception_s
    end
    
    private
    
    def prepare
      case @exception
      when NameError     then prepare_name_error
      when ArgumentError then prepare_argument_error
      end
    end
    
    def prepare_name_error
      return unless @exception_s.match(/Did you mean\?/)
      @did_you_mean = Regexp.last_match.post_match.strip.scan(/\S+/)
      @decoration[@lineno] = [@exception.name.to_s, "\e[1;31m\e[4m"]
      
      @did_you_mean.each do |name|
        index = @script_lines.index { |line| line.include?(name) }
        next unless index
        @decoration[index] = [name, "\e[1;33m"]
        @output_linenos.push(index)
      end
    end
    
    def prepare_argument_error
      @method = @label
      backtrace_locations_shift
      @script_lines = read_script(@path)
      @output_linenos = default_output_linenos
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
    
    def default_output_linenos
      from = [1, @lineno - @@before_line_num].max
      to   = [@script_lines.size - 1, @lineno + @@after_line_num].min
      (from..to).to_a
    end
    
    def highlight(str, keyword, color)
      str.to_s.gsub(keyword){ "#{color}#{$&}\e[0m" }
    end
    
    def warning_message(file, line, warning)
      case warning
      when "found `= literal' in conditional, should be =="
        "#{file}:#{line}: warning: #{warning}\n" +
        script_inspect(file, [line], line, { line => [/(?<![><!=])=(?!=)/, "\e[1;31m\e[4m"] })
      else
        nil
      end
    end
    
    def read_script(file)
      unless @scripts[file]
        script = Eturem.read_script(file)
        return nil unless script
        script.encode!("utf-8")
        if @@use_coderay
          require "coderay" 
          script = CodeRay.scan(script, :ruby).terminal
        end
        @scripts[file] = [""] + script.lines(chomp: true)
      end
      return @scripts[file]
    end
  end
  
  @eturem_class = Base
end
