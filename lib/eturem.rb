enable = true
debug  = false
lang   = "en"
output_backtrace = true
output_original  = true
output_script    = true
override_warning = true
use_coderay      = false
before_line_num  = 2
after_line_num   = 2
repl             = nil

config_file = File.exist?("./.eturem") ? "./.eturem" : File.join(Dir.home, ".eturem")
if File.exist?(config_file)
  config = File.read(config_file).gsub(/#.*/, "")
  enable = false                    if config.match(/^enable\s*\:\s*(?:false|off|0)/i)
  debug  = true                     if config.match(/^debug\s*\:\s*(?:true|on|1)/i)
  lang   = Regexp.last_match(:lang) if config.match(/^lang\s*\:\s*(?<lang>\S+)/i)
  output_backtrace = false if config.match(/^output_backtrace\s*\:\s*(?:false|off|0)/i)
  output_original  = false if config.match( /^output_original\s*\:\s*(?:false|off|0)/i)
  output_script    = false if config.match(   /^output_script\s*\:\s*(?:false|off|0)/i)
  override_warning = false if config.match(/^override_warning\s*\:\s*(?:false|off|0)/i)
  use_coderay      = true  if config.match(     /^use_coderay\s*\:\s*(?:true|on|1)/i)
  before_line_num = Regexp.last_match(:num).to_i if config.match(/^before_line_num\s*\:\s*(?<num>\d+)/i)
  after_line_num  = Regexp.last_match(:num).to_i if config.match( /^after_line_num\s*\:\s*(?<num>\d+)/i)
  repl = Regexp.last_match(:repl).downcase if config.match(/^repl\s*\:\s*(?<repl>irb|pry)/i)
end

if enable
  require "eturem/#{lang}/main" unless defined?(Eturem)
  require "eturem/warning" if override_warning
  Eturem::Base.output_backtrace = output_backtrace
  Eturem::Base.output_original  = output_original
  Eturem::Base.output_script    = output_script
  Eturem::Base.use_coderay      = use_coderay
  Eturem::Base.before_line_num  = before_line_num
  Eturem::Base.after_line_num   = after_line_num

  eturem_path = File.expand_path("..", __FILE__)
  last_binding = nil
  tracepoint = TracePoint.trace(:raise) do |tp|
    last_binding = tp.binding unless File.expand_path(tp.path).start_with?(eturem_path)
  end
  exception = Eturem.load(File.expand_path(Eturem.program_name))
  tracepoint.disable

  if exception.is_a?(Exception)
    begin
      Eturem.extend_exception(exception)
      $stderr.write exception.eturem_full_message
    rescue Exception => e
      raise debug ? e : exception
    end

    repl ||= $eturem_repl if defined?($eturem_repl)
    if repl && last_binding && exception.is_a?(StandardError)
      require repl
      last_binding.public_send(repl)
    end
  end
  exit
end
