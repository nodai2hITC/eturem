enable = true
lang   = "en"
output_backtrace = true
output_original  = true
output_script    = true
max_backtrace    = 16
before_line_num  = 2
after_line_num   = 2

config_file = File.join(Dir.home, ".eturem")
if File.exist?(config_file)
  config = File.read(config_file)
  enable = false                    if config.match(/^enable\s*\:\s*false/i)
  lang   = Regexp.last_match(:lang) if config.match(/^lang\s*\:\s*(?<lang>\S+)/i)
  output_backtrace = false          if config.match(/^output_backtrace\s*\:\s*false/i)
  output_original  = false          if config.match( /^output_original\s*\:\s*false/i)
  output_script    = false          if config.match(   /^output_script\s*\:\s*false/i)
  max_backtrace   = Regexp.last_match(:num).to_i if config.match(  /^max_backtrace\s*\:\s*(?<num>\d+)/i)
  before_line_num = Regexp.last_match(:num).to_i if config.match(/^before_line_num\s*\:\s*(?<num>\d+)/i)
  after_line_num  = Regexp.last_match(:num).to_i if config.match( /^after_line_num\s*\:\s*(?<num>\d+)/i)
end
require "eturem/#{lang}" if enable && !defined?(Eturem)

if defined? Eturem
  Eturem.eturem_class.output_backtrace = output_backtrace
  Eturem.eturem_class.output_original  = output_original
  Eturem.eturem_class.output_script    = output_script
  Eturem.eturem_class.max_backtrace    = max_backtrace
  Eturem.eturem_class.before_line_num  = before_line_num
  Eturem.eturem_class.after_line_num   = after_line_num
  
  exception = Eturem.load($0)
  exception.output_error if exception
  exit
end
