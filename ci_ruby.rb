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


if ARGV.first == ':bundle'

  ARGV.clear
  ARGV.concat(%w[ install --no-color --path ci_vendor ])

  load(`which bundle`.chop)

else

  $:.unshift('.') unless $:.include?('.')

  require 'rubygems'
  require 'bundler/setup'

  raw_path = ARGV.shift

  m = raw_path.match(/^([^\/]+)(\/.+)$/)

  gem = m[1]
  path = m[2]

  regex0 = /\/#{gem}-[0-9a-f\.]+#{path.gsub(/\//, '\/')}$/
  regex1 = /\/#{raw_path.gsub(/\//, '\/')}$/

  paths = Dir['ci_vendor/**/*.rb']

  target =
    paths.find { |pa| regex0.match(pa) } ||
    paths.find { |pa| regex1.match(pa) }

  raise ArgumentError.new(
    "found nothing to run for '#{raw_path}'"
  ) unless target

  load(target)
end

