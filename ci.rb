#--
# Copyright (c) 2010-2011, John Mettraux, jmettraux@gmail.com
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
require 'open4'


module Ci

  def self.all (&block)

    @all = block if block

    @all
  end

  def self.bundle (opt, &block)

    name = opt
    deps = []
    name, deps = opt.first if opt.is_a?(Hash)
    deps = Array(deps)

    (@bundles ||= {})[name] = [ deps, block ]
  end

  def self.bundles

    @bundles
  end

  def self.task (name, &block)

    Context.new(name, &block)
  end

  class Context

    CI_RUBY = File.expand_path(File.join(File.dirname(__FILE__)), 'ci_ruby.rb')

    def initialize (name, &block)

      @name = name.to_s

      @reporters = {}

      @opts = {}
      @message = []
      @exitstatus = 0 # success as of now

      FileUtils.mkdir('tmp') rescue nil

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

      emit_report
    end

    def options (opts={})

      if opts == :clear
        @opts.clear
      else
        @opts.merge!(opts)
      end
    end

    def reporter (name, opts={})

      @reporters[name] = opts
    end

    def rvm (opts)

      @opts[:rvm] = opts[:use]
    end

    def bundle (name, opts={})

      context = BundleContext.new

      do_bundle(context, name, opts)

      context.save(directory(opts))

      ruby(':bundle')
    end

    def ruby (*args)

      opts = args.last.is_a?(Hash) ? args.pop : {}

      opts[:timeout] ||= 30 * 60
        # kill ruby scripts after 30 minutes

      command = [ 'ruby', CI_RUBY ] + args

      if rvm = opts[:rvm] || @opts[:rvm]
        command = [ "#{ENV['HOME']}/.rvm/bin/rvm", "#{rvm}," ] + command
      end

      exitstatus = sh(command, opts)

      @exitstatus = exitstatus if exitstatus != 0
    end

    def sh (command, opts={})

      command = Array(command)

      oo = @opts.merge(opts)

      timeout = oo[:timeout]

      say(command.join(' '))

      status = nil
      @output = ''

      dir = directory(opts)

      FileUtils.mkdir_p(dir)

      Dir.chdir(dir) do

        block = lambda {
          Open4.popen4(*command) do |pid, stdin, stdout, stderr|
            [ stdout, stderr ].each do |std|
              loop do
                s = std.read(28)
                break unless s
                @output << s
              end
            end
          end
        }

        status = if timeout
          Timeout.timeout(timeout, &block)
        else
          block.call
        end
      end

      say(@output)

      status.exitstatus

    rescue Exception => e
      say("command")
      say("  #{command}")
      say("failed with")
      say("  #{e.class} : #{e}")
      #e.backtrace.each { |line| say("    #{line}") }
        # backtrace is the one in the main process, not the one in the child
    end

    protected

    def do_bundle (context, name, opts)

      deps, block = Ci.bundles[name]
      deps.each { |dep| do_bundle(context, dep, opts) }
      context.instance_eval(&block)
    end

    def arg (key)

      i = ARGV.index("--#{key}")

      i ? ARGV[i + 1] : nil
    end

    def directory (opts)

      "work/#{safe_name}/#{opts[:dir] || @opts[:dir] || '.'}/"
    end

    def say (s)

      @message << s
    end

    def safe_name

      @name.gsub(/[\s]/, '_')
    end

    def emit_report

      only = ARGV.collect { |a|
        m = a.match(/^--only-(.+)$/)
        m ? m[1] : nil
      }.compact.first

      only = only.to_sym if only

      raise ArgumentError.new(
        "no :#{only} reporter"
      ) if only and @reporters[only].nil?

      reporters = @reporters[only] ? [ only ] : @reporters.keys

      reporters.each do |name|
        next if ARGV.include?("--no-#{name}")
        opts = @reporters[name]
        self.send("report_#{name}", opts)
      end
    end

    def report_s3 (opts)

      require 'aws/s3'

      AWS::S3::Base.establish_connection!(
        :access_key_id => opts[:access_key_id],
        :secret_access_key => opts[:secret_access_key])

      time = Time.now.strftime('%Y%m%d_%a_%H%M')
      success = @exitstatus == 0 ? 'ok' : 'FAILED'

      fname = "#{time}__#{safe_name}__#{success}.txt"

      AWS::S3::S3Object.store(
        fname, @message.join("\n"), opts[:bucket], :access => :public_read)
    end

    def report_stdout (opts)

      puts
      puts '=' * 80
      puts @exitstatus == 0 ? '[ok]' : '[FAILED]'
      puts '-' * 80
      puts @message.join("\n")
    end

    def report_mail (opts)

      say("Task took #{Time.now - @start} seconds.")

      #say("\nremains :")
      #sh('ps aux | grep ruby', :dir => nil)

      t = Time.now
      st = t.strftime('%Y%m%d_%H%M')

      success = @exitstatus == 0 ? '[ok]' : '[FAILED]'

      h = {}
      h['From'] = opts[:from] || "ruote ci<ci@#{`hostname -f`.strip}>"
      h['Subject'] = "#{success} #{@name} #{st}"
      h = h.collect { |k, v| "-a \"#{k}: #{v}\"" }.join(' ')

      fname = "tmp/#{safe_name}_#{st}.txt"

      File.open(fname, 'w') { |f| f.puts(@message.join("\r\n")) }
      `cat #{fname} | mail #{h} "#{@mailto}"`
    end
  end

  class BundleContext

    def initialize

      @elements = []
    end

    def source (*args)

      @elements << [ 'source', args ]
    end

    def gem (*args)

      @elements << [ 'gem', args ]
    end

    def save (dir)

      #FileUtils.rm(File.join(dir, 'Gemfile.lock')) rescue nil
      #FileUtils.rm_rf(File.join(dir, 'ci_vendor')) rescue nil
        # nuking it all, to make sure the latest version is used :-(

      File.open(File.join(dir, 'Gemfile'), 'wb') do |f|
        f.puts("#")
        f.puts("# generated by ci on #{Time.now}")
        f.puts("#")
        @elements.each do |elt|
          f.puts("#{elt.first} #{elt.last.inspect[1..-2]}")
        end
      end
    end
  end
end

