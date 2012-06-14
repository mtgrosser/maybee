require 'irb'

module IRB
  def self.start_debug_session(debug_binding)
    unless @__initialized
      args = ARGV
      ARGV.replace(ARGV.dup)
      Kernel.silence_warnings { IRB.setup(nil) }
      ARGV.replace(args)
      @__initialized = true
    end

    file = debug_binding.eval('__FILE__')
    line = debug_binding.eval('__LINE__')
    if File.exist?(file)
      start = [0, line - 5].max
      lines = File.readlines(file)[start..(line + 5)]
      width = Math.log10((start + 10)).to_i
      format = "%0#{width}u"
      puts "\nIn file #{file}:"
      lines.each_with_index do |code, idx|
        arrow = line == start + idx + 1 ? '-> ' : '   '
        puts "#{arrow}#{format % (idx + start)}: #{code.rstrip}"
      end
      puts ''
    end
    workspace = WorkSpace.new(debug_binding)

    irb = Irb.new(workspace)

    @CONF[:IRB_RC].call(irb.context) if @CONF[:IRB_RC]
    @CONF[:MAIN_CONTEXT] = irb.context

    trap('INT') { irb.signal_handle }
    catch(:IRB_EXIT) { irb.eval_input }
    trap('INT', 'DEFAULT')
  end
end

module Kernel
  def irb_debugger(&block)
    raise 'No block given! USAGE: irb_debugger {}' unless block_given?
    IRB.start_debug_session(block.binding)
  end
end

