
require 'open3'
require 'timeout'
require 'fileutils'
#require 'pathname'


module Ci

  def self.task (&block)

    Context.new(&block)
  end

  class Context

    def initialize (&block)

      @opts = {}
      @message = []

      FileUtils.mkdir('logs') rescue nil

      @start = Time.now

      instance_eval(&block)

      send_mail
    end

    def options (opts={})

      if opts == :clear
        @opts.clear
      else
        @opts.merge!(opts)
      end
    end

    def mailto (target)

      @mailto = target
    end

    def git (repo, opts={})

      m = repo.match(/\/([^\/]+)\.git/)

      dir = m[1]

      sh("rm -fR #{dir}", opts)
      sh("git clone --quiet #{repo}", opts)
    end

    def ruby (path, opts={})

      oo = @opts.merge(opts)

      command = "ruby #{path}"

      if rvm = oo[:rvm]
        command = "~/.rvm/bin/rvm #{rvm} #{command}"
      end

      sh(command, opts)
    end

    def sh (command, opts={})

      oo = @opts.merge(opts)

      if dir = oo[:dir]
        command = "cd #{dir} && #{command}"
      end

      to = oo[:timeout] || 20 * 60
        # 20 minutes default timeout (1200s)

      # TODO : use popen instead of backticks

      say("#{command}")

      Timeout::timeout(to) do

        #say(`#{command} 2>&1`) unless opts[:blank]
        unless opts[:blank]
          execute(command)
          say(@output)
        end
      end

    rescue Timeout::Error => te
      say(@output)
      say("...expired after #{to} seconds.")
    end

    protected

    def execute (command)

      command = "#{command} 2>&1"

      @output = ''

      Open3.popen3(command) do |stdin, stdout, stderr|
        loop do
          s = stdout.read(25)
          break unless s
          @output << s
        end
      end
    end

    def ci_script

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
      h['From'] = "ruote ci<ci@#{`hostname -f`.strip}>"
      h['Subject'] = "#{script} #{st}"
      h = h.collect { |k, v| "-a \"#{k}: #{v}\"" }.join(' ')

      fname = "logs/#{script}_#{st}.txt"

      File.open(fname, 'w') { |f| f.puts(@message.join("\r\n")) }
      `cat #{fname} | mail #{h} #{@mailto}`
    end
  end
end

