require 'thread'

class MemoryUsageMonitor
  attr_reader :peak_memory

  def initialize(frequency: 0.25)
    @frequency = frequency
    @peak_memory = 0
  end

  def start
    @thread = Thread.new do
      while true do
        memory = `ps -o rss -p #{Process::pid}`.chomp.split("\n").last.strip.to_i
        @peak_memory = [memory, @peak_memory].max
        sleep @frequency
      end
    end
  end

  def stop
    Thread.kill(@thread)
  end
end
