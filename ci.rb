#--
# Copyright (c) 2010, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


require 'timeout'
require 'fileutils'

require 'rubygems'
require 'open4' # gem install open4


module Ci

  def self.all (&block)

    @all = block if block

    @all
  end

  def self.task (name, &block)

    Context.new(name, &block)
  end

  class Context

    def initialize (name, &block)

      @name = name.to_s

      @opts = {}
      @message = []
      @exitstatus = 0 # success as of now

      FileUtils.mkdir('logs') rescue nil

      @start = Time.now

      begin

        instance_eval(&Ci.all) if Ci.all

        instance_eval(&block)

      rescue Exception => e

        p e
        e.backtrace.each { |l| puts l }

        say("!!! exception in task #{@name}\n")
        say("=" * 80)
        say(e)
        say(e.backtrace)
        say("=" * 80)

        @exitstatus = 1
      end

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

      exitstatus = sh(command, opts)

      @exitstatus = exitstatus if exitstatus != 0
    end

    def sh (command, opts={})

      oo = @opts.merge(opts)

      if dir = oo[:dir]
        command = "cd #{dir} && #{command}"
      end

      to = oo[:timeout] || 20 * 60
        # 20 minutes default timeout (1200s)

      say("#{command}")

      status = nil

      Timeout::timeout(to) do

        #say(`#{command} 2>&1`) unless opts[:blank]
        unless opts[:blank]
          status = execute(command)
          say(@output)
        end
      end

      status.exitstatus

    rescue Timeout::Error => te

      say(@output)
      say("...expired after #{to} seconds.")

      Process.kill('HUP', status.pid) rescue nil

      1 # exitstatus (failed)
    end

    protected

    def execute (command)

      command = "#{command} 2>&1"

      @output = ''

      status = Open4.popen4(command) do |pid, stdin, stdout, stderr|

        say(" `--> in process #{pid}")

        loop do
          s = stdout.read(25)
          break unless s
          @output << s
        end
      end

      status
    end

    def say (s)

      @message << s
    end

    def send_mail

      say("Task took #{Time.now - @start} seconds.")

      say("\nremains :")
      sh('ps aux | grep ruby', :dir => nil)

      t = Time.now
      st = t.strftime('%Y%m%d_%H%M')

      success = @exitstatus == 0 ? '[ok]' : '[FAILED]'

      h = {}
      h['From'] = "ruote ci<ci@#{`hostname -f`.strip}>"
      h['Subject'] = "#{success} #{@name} #{st}"
      h = h.collect { |k, v| "-a \"#{k}: #{v}\"" }.join(' ')

      fname = "logs/#{@name}_#{st}.txt".gsub(/ /, '_')

      File.open(fname, 'w') { |f| f.puts(@message.join("\r\n")) }
      `cat #{fname} | mail #{h} #{@mailto}`
    end
  end
end

