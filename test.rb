require './random_id'
require 'benchmark'

thread_count = 8
ids = 1_000_000

generators = [
  ["Random", RandomIdGenerator.new(12)],
  ["Counter", CounterIdGenerator.new(12)],
  ["Thread", ThreadIdGenerator.new(12)],
  ["Mutex", MutexIdGenerator.new(12)]
]

generators.each do |(label, generator)|
  items = []
  Benchmark.bm(10) do |bm|
    bm.report(label) do
      threads = thread_count.times.map do |i|
        Thread.new(i) do |i|
          items.concat(ids.times.map { generator.generate })
        end
      end
      threads.map(&:join)
    end
    uniq = items.uniq.length
    puts "#{label} Performance: #{uniq} / #{items.length} (#{uniq.to_f / items.length})"
  end
end

