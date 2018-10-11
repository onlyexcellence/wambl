require 'wambl'

Wambl::Threader.new do |t|

  t.rpm = 1000
  t.total = 4000
  t.total.times do |i|

    t.make_thread(i) do |_i|

      sleep rand(0.3..2.0)
      t.successful += 1

    end

  end

end
