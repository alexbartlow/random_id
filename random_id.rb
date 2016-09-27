require 'thread'
require 'securerandom'
require "concurrent/atomics"

class IdGenerator
  def initialize(machine_id)
    @machine_bits = 7
    @counter_bits = 14
    @machine_id = (machine_id << @counter_bits)
    @last_timestamp = 0
    @counter = 0
    @max_counter = (1 << @counter_bits) - 1
    @m = Mutex.new
  end

  def suffix
    0
  end

  def generate
    time = (Time.now.to_f.round(3) * 1000).to_i
    (time << (@machine_bits + @counter_bits)) | suffix
  end
end

class ThreadIdGenerator < IdGenerator
  def initialize *args
    super
    @queue = Queue.new
    @counter = Concurrent::AtomicFixnum.new(0)
  end

  def suffix
    v = @counter.increment & @max_counter
    (@machine_id) | (v & @max_counter)
  end
end

class CounterIdGenerator < IdGenerator
  def suffix
    v = (@counter = (1 + @counter) & ((1 << @counter_bits) - 1))
    (@machine_id) | (v & @max_counter)
  end
end

class MutexIdGenerator < IdGenerator
  def suffix
    v = 0
    @m.synchronize { v = (@counter = (1 + @counter) & ((1 << @counter_bits) - 1)) }
    (@machine_id) | (v & @max_counter)
  end
end

class RandomIdGenerator < IdGenerator
  def suffix
    SecureRandom.random_number(1 << (@machine_bits + @counter_bits))
  end
end
