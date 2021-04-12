require "eturem/version"

module Eturem
  @program_name = $PROGRAM_NAME.encode("utf-8")

  def self.rescue
    yield
  rescue Exception => exception
    raise exception if exception.is_a? SystemExit
    exception
  end

  # load script and return exception if exception raised
  # @param [String] filename script file
  # @return [Exception] if exception raised
  # @return [true] if exception did not raise
  def self.load(filename, wrap = false)
    self.rescue do
      Kernel.load(filename, wrap)
    end
  end

  def self.eval(expr, bind = nil, fname = "(eval)", lineno = 1)
    self.rescue do
      bind ? Kernel.eval(expr, bind, fname, lineno) : Kernel.eval(expr)
    end
  end

  def self.extend_exception(exception)
    ext = _extend_exception(exception) ||
          case exception
          when SyntaxError   then SyntaxErrorExt
          when NameError     then NameErrorExt
          when ArgumentError then ArgumentErrorExt
          else ExceptionExt
          end
    exception.extend ext
    exception.eturem_prepare
  end

  def self.program_name
    @program_name
  end


  module Base
    @@eturem_output_backtrace = true
    @@eturem_output_original  = true
    @@eturem_output_script    = true
    @@eturem_use_coderay      = false
    @@eturem_before_line_num  = 2
    @@eturem_after_line_num   = 2

    def self.output_backtrace=(value)
      @@eturem_output_backtrace = value
    end

    def self.output_original=(value)
      @@eturem_output_original = value
    end

    def self.output_script=(value)
      @@eturem_output_script = value
    end

    def self.use_coderay=(value)
      @@eturem_use_coderay = value
    end

    def self.before_line_num=(value)
      @@eturem_before_line_num = value
    end

    def self.after_line_num=(value)
      @@eturem_after_line_num = value
    end

    def self.highlight(str, pattern, highlight)
      str.sub!(pattern) { "#{highlight}#{$1 || $&}\e[0m#{$2}" } if str
    end

    def self.unhighlight(str)
      str.gsub(/\e\[[0-9;]*m/, "")
    end

    def self.read_script(filename)
      return [] unless File.exist?(filename)
      script = File.binread(filename)
      encoding = "utf-8"
      if script.match(/\A(?:#!.*\R)?#.*coding *[:=] *(?<encoding>[^\s:]+)/)
        encoding = Regexp.last_match(:encoding)
      end
      script.force_encoding(encoding).encode!("utf-8")
      if @@eturem_use_coderay
        require "coderay"
        script = CodeRay.scan(script, :ruby).terminal
      end
      [""] + script.lines(chomp: true)
    end

    def self.script(lines, linenos, lineno)
      str = ""
      max_lineno_length = linenos.max.to_s.length
      last_i = linenos.min.to_i - 1
      linenos.uniq.sort.each do |i|
        line = lines[i]
        next unless line
        str += "    #{' ' * max_lineno_length}  :\n" if last_i + 1 != i
        str += (lineno == i ? " => " : "    ")
        str += sprintf("\e[1;34m%#{max_lineno_length}d\e[0m: %s\e[0m\n", i, line)
        last_i = i
      end
      str
    end


    def eturem_prepare
      this_dirpath = File.dirname(File.expand_path(__FILE__))
      @eturem_backtrace_locations = (self.backtrace_locations || []).reject do |location|
        File.expand_path(location.path).start_with?(this_dirpath) ||
        location.path.end_with?(
          "/rubygems/core_ext/kernel_require.rb",
          "/rubygems/core_ext/kernel_require.rb>"
        )
      end

      program_filepath = File.expand_path(Eturem.program_name)
      @eturem_backtrace_locations.each do |location|
        if File.expand_path(location.path) == program_filepath
          def location.path; Eturem.program_name; end
          if location.label == "<top (required)>"
            def location.label; "<main>"; end
          end
        end
      end

      @eturem_message = self.message
      unless @eturem_message.encoding == Encoding::UTF_8
        @eturem_message.force_encoding("utf-8")
        unless @eturem_message.valid_encoding?
          @eturem_message.force_encoding(Encoding.locale_charmap).encode!("utf-8")
        end
      end

      if self.is_a?(SyntaxError) && @eturem_message.match(/\A(?<path>.+?)\:(?<lineno>\d+):\s*/)
        @eturem_path    = Regexp.last_match(:path)
        @eturem_lineno  = Regexp.last_match(:lineno).to_i
        @eturem_message = Regexp.last_match.post_match
        @eturem_path = Eturem.program_name if @eturem_path == program_filepath
      else
        eturem_backtrace_locations_shift
      end

      @eturem_script_lines = Eturem::Base.read_script(@eturem_path)
      @eturem_output_linenos = eturem_default_output_linenos
    end

    def eturem_original_error_message()
      @eturem_message.match(/\A(?<first_line>.*)/)
      "#{@eturem_path}:#{@eturem_lineno}:in `#{@eturem_label}': " +
      "\e[1m#{Regexp.last_match(:first_line)} (\e[4m#{self.class}\e[0;1m)" +
      "#{Regexp.last_match.post_match.chomp}\e[0m\n"
    end

    def eturem_backtrace_str(order = :top)
      str = @eturem_backtrace_locations.empty? ? "" : eturem_traceback(order)
      str + (order == :top ? eturem_backtrace_str_top : eturem_backtrace_str_bottom)
    end

    def eturem_backtrace
      eturem_backtrace_locations.map do |location|
        eturem_location_to_s(location)
      end
    end

    def eturem_location_to_s(location)
      "#{location.path}:#{location.lineno}:in `#{location.label}'"
    end

    def eturem_backtrace_locations
      @eturem_backtrace_locations
    end

    def eturem_message
      ""
    end

    def eturem_script
      Eturem::Base.script(@eturem_script_lines, @eturem_output_linenos, @eturem_lineno)
    end

    def eturem_full_message(highlight: true, order: :top)
      highlight = false unless $stderr == STDERR && $stderr.tty?

      str = @@eturem_output_backtrace ? eturem_backtrace_str(order) : ""
      ext_message = eturem_message
      if ext_message.empty?
        str += eturem_original_error_message
      else
        str = "#{eturem_original_error_message}\n#{str}" if @@eturem_output_original
        str += "#{ext_message}\n"
      end
      str += eturem_script if @@eturem_output_script

      highlight ? str : Eturem::Base.unhighlight(str)
    end

    private

    def eturem_backtrace_locations_shift
      location = @eturem_backtrace_locations.shift
      @eturem_label  = location.label
      @eturem_path   = location.path
      @eturem_lineno = location.lineno
    end

    def eturem_default_output_linenos
      from = [1, @eturem_lineno - @@eturem_before_line_num].max
      to   = [@eturem_script_lines.size - 1, @eturem_lineno + @@eturem_after_line_num].min
      (from..to).to_a
    end

    def eturem_traceback(order = :bottom)
      order == :top ? "" : "\e[1mTraceback\e[0m (most recent call last):\n"
    end

    def eturem_backtrace_str_bottom
      lines = []
      backtrace = eturem_backtrace
      size = backtrace.size
      format = "%#{8 + size.to_s.length}d: %s\n"
      backtrace.reverse.each_with_index do |bt, i|
        lines.push(sprintf(format, size - i, bt))
      end

      if @eturem_message == "stack level too deep"
        lines = lines[-4..-1] +
                ["         ... #{lines.size - 12} levels...\n"] +
                lines[0..7]
      end
      lines.join
    end

    def eturem_backtrace_str_top
      lines = eturem_backtrace.map do |bt|
        "        from #{bt}\n"
      end
      if @eturem_message == "stack level too deep"
        lines = lines[0..7] +
                ["         ... #{lines.size - 12} levels...\n"] +
                lines[-4..-1]
      end
      lines.join
    end
  end


  module ExceptionExt
    include Base
  end


  module NameErrorExt
    include ExceptionExt

    def eturem_prepare()
      @eturem_corrections = self.respond_to?(:corrections) ? self.corrections : []
      @eturem_corrections += Object.constants.map(&:to_s).select do |const|
        const.casecmp?(self.name)
      end
      @eturem_corrections.uniq!
      def self.corrections; @eturem_corrections; end
      super
      uname = self.name.to_s.encode("utf-8")
      if @eturem_script_lines[@eturem_lineno]
        Eturem::Base.highlight(@eturem_script_lines[@eturem_lineno], uname, "\e[1;4;31m")
      end
      @eturem_corrections.each do |name|
        index = @eturem_script_lines.index { |line| line.include?(name.to_s.encode("utf-8")) }
        next unless index
        Eturem::Base.highlight(@eturem_script_lines[index], name.to_s.encode("utf-8"), "\e[1;33m")
        @eturem_output_linenos.push(index)
      end
    end
  end


  module ArgumentErrorExt
    include ExceptionExt

    def eturem_prepare()
      super
      @eturem_method = @eturem_label
      eturem_backtrace_locations_shift
      @eturem_script_lines = Eturem::Base.read_script(@eturem_path)
      @eturem_output_linenos = eturem_default_output_linenos
    end
  end


  module SyntaxErrorExt
    include ExceptionExt
  
    def eturem_original_error_message()
      ret = "#{@eturem_path}:#{@eturem_lineno}: #{@eturem_message}"
      unless @eturem_path == Eturem.program_name
        ret = "\e[1m#{ret} (\e[4m#{self.class}\e[0;1m)\e[0m"
      end
      ret + "\n"
    end
  end
end
