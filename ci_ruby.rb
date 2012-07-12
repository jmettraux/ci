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


$stderr = $stdout
  # yes, 2>&1


# Given a path like "ruote/test/test.rb" or "ruote-kit/spec/" returns
# the absolute "bundled" path...
#
def locate(raw_path)

  $:.unshift('.') unless $:.include?('.')

  m = raw_path.match(/^([^\/]+)(\/.+)$/)

  return File.expand_path('../' + raw_path, __FILE__) unless m

  require 'rubygems'
  require 'bundler/setup'

  gem = m[1]
  path = m[2]

  #regex0 = /\/#{gem}-[0-9a-f\.]+#{path.gsub(/\//, '\/')}$/
  #regex1 = /\/#{raw_path.gsub(/\//, '\/')}$/
  #paths = Dir['ci_vendor/**/*.rb']
  #target =
  #  paths.find { |pa| regex0.match(pa) } ||
  #  paths.find { |pa| regex1.match(pa) }
    #
    # now leveraging `bundle show ...`

  gempath = `bundle show #{gem}`.strip
  target = File.join(gempath, path)

  raise ArgumentError.new(
    "found nothing to run for '#{raw_path}'"
  ) unless target

  target
end


if ARGV.first == 'bundle'

  ARGV.clear

  if File.exist?('Gemfile.lock')
    ARGV.concat(%w[ update ])
  else
    ARGV.concat(%w[ install --no-color --path ci_vendor ])
    #ARGV.concat(%w[ install --binstubs --no-color --path ci_vendor ])
  end

  load(`which bundle`.chop)

elsif ARGV.first == 'rspec'

  ARGV.unshift('exec')
  spec_dir = locate(ARGV.pop)
  ARGV << "-I#{spec_dir}" # grrr
  ARGV << spec_dir

  load(`which bundle`.chop)

else

  load(locate(ARGV.shift))
end

