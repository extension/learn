RAILS_ROOT = File.dirname(File.dirname(__FILE__))
DELAYED_JOB = "#{RAILS_ROOT}/script/delayed_job"

God::Contacts::Email.defaults do |d|
  d.from_email = 'monitor@extension.org'
  d.from_name = 'monitor'
  d.delivery_method = :sendmail
end

God.contact(:email) do |c|
  c.name = 'monitor'
  c.group = 'developers'
  c.to_email = 'monitor@extension.org'
end


1.times do |num|
  God.watch do |w|
    w.env = { 'RAILS_ENV' => "production" }
    w.name     = "delayed_job-#{num}"
    w.group    = 'delayed_jobs'
    w.dir = "#{RAILS_ROOT}"
    w.interval = 60.seconds
    w.start = "#{DELAYED_JOB} start"
    w.stop =  "#{DELAYED_JOB} stop"
    w.restart = "#{DELAYED_JOB} restart"
    w.log = "#{RAILS_ROOT}/log/delayed_job.log"
    w.start_grace = 45.seconds
    w.pid_file = "#{RAILS_ROOT}/tmp/pids/delayed_job.pid"
    w.behavior(:clean_pid_file)

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.notify = 'monitor'
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_exits) do |c|
        c.notify = 'monitor'
      end
    end

    # restart if memory or cpu is too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.interval = 20
        c.above = 256.megabytes
        c.times = [3, 5]
        c.notify = 'monitor'
      end

      on.condition(:cpu_usage) do |c|
        c.interval = 10
        c.above = 95.percent
        c.times = [3, 5]
        c.notify = 'monitor'
      end
    end

    # lifecycle
    w.lifecycle do |on|
      on.condition(:flapping) do |c|
        c.to_state = [:start, :restart]
        c.times = 5
        c.within = 5.minute
        c.transition = :unmonitored
        c.retry_in = 10.minutes
        c.retry_times = 5
        c.retry_within = 2.hours
      end
    end
  end
end
