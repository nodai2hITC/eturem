enable = true
debug  = false
lang   = "en"
output_backtrace = true
output_original  = true
output_script    = true
use_coderay      = false
before_line_num  = 2
after_line_num   = 2
repl             = nil

if File.exist?($PROGRAM_NAME)
  config_file = File.join(Dir.home, ".eturem")
  if File.exist?(config_file)
    config = File.read(config_file)
    enable = false                    if config.match(/^enable\s*\:\s*(?:false|off|0)/i)
    debug  = true                     if config.match(/^debug\s*\:\s*(?:true|on|1)/i)
    lang   = Regexp.last_match(:lang) if config.match(/^lang\s*\:\s*(?<lang>\S+)/i)
    output_backtrace = false if config.match(/^output_backtrace\s*\:\s*(?:false|off|0)/i)
    output_original  = false if config.match( /^output_original\s*\:\s*(?:false|off|0)/i)
    output_script    = false if config.match(   /^output_script\s*\:\s*(?:false|off|0)/i)
    use_coderay      = true  if config.match(     /^use_coderay\s*\:\s*(?:true|on|1)/i)
    before_line_num = Regexp.last_match(:num).to_i if config.match(/^before_line_num\s*\:\s*(?<num>\d+)/i)
    after_line_num  = Regexp.last_match(:num).to_i if config.match( /^after_line_num\s*\:\s*(?<num>\d+)/i)
    repl = Regexp.last_match(:repl).downcase if config.match(/^repl\s*\:\s*(?<repl>irb|pry)/i)
  end
  
  if enable
    require "eturem/#{lang}" unless defined?(Eturem)
    Eturem.set_config(
      output_backtrace: output_backtrace,
      output_original:  output_original,
      output_script:    output_script,
      use_coderay:      use_coderay,
      before_line_num:  before_line_num,
      after_line_num:   after_line_num
    )
    
    Eturem.load_and_output($PROGRAM_NAME, repl, debug)
    exit
  end
end
