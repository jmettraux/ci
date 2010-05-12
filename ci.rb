
require 'timeout'
require 'fileutils'
#require 'pathname'


module Ci

  def self.task (&block)

    Context.new(&block)
  end

  class Context

    def initialize (&block)

      @message = []

      FileUtils.mkdir('logs') rescue nil

      @start = Time.now

      instance_eval(&block)

      send_mail
    end

    def mailto (target)

      @mailto = target
    end

    def git (repo)

      m = repo.match(/\/([^\/]+)\.git/)

      dir = m[1]

      sh("rm -fR #{dir}")
      sh("git clone --quiet #{repo}")
    end

    def ruby (path, opts={})

      #puts `rvm 1.9.1@ch ruby -v` <-- that's the key

      dir = opts[:dir]
      rvm = opts[:rvm]

      command = "ruby #{path}"
      command = "~/.rvm/bin/rvm #{rvm} #{command}" if rvm
      command = "cd #{dir} && #{command}" if dir

      sh(command, opts)
    end

    def sh (command, opts={})

      to = opts[:timeout] || 20 * 60
        # 20 minutes default timeout

      Timeout::timeout(to) do
        say("#{command}")
        say(`#{command} 2>&1`) unless opts[:blank]
      end
    rescue Timeout::Error => te
      say("...expired after #{to} seconds.")
    end

    protected

    def ci_script

      #caller.find { |l| l.match(/^[^\.]/) }.match(/^(.+):/)[1]
      $0.match(/([^\/]+\.rb)$/)[1]
    end

    def say (s)

      @message << s
    end

    def send_mail

      say("Task took #{Time.now - @start} seconds.")

      script = ci_script
      t = Time.now
      st = t.strftime('%Y%m%d_%H%M')

      h = {}
      #h['To'] = @mailto
      h['From'] = "ruote ci<ci@#{`hostname -f`.strip}>"
      h['Subject'] = "#{script} #{st}"
      h = h.collect { |k, v| "-a \"#{k}: #{v}\"" }.join(' ')

      fname = "logs/#{script}_#{st}.txt"

      File.open(fname, 'w') { |f| f.puts(@message.join("\r\n")) }
      `cat #{fname} | mail #{h} #{@mailto}`
    end
  end
end

