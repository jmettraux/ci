
#
# testing ruote-dm
#
# Thu Feb  4 13:44:13 JST 2010
#
# edited for ci
# Wed May 12 18:16:24 JST 2010
#

require 'yajl' rescue require 'json'
require 'rufus-json'
Rufus::Json.detect_backend

require 'ruote-dm'

if ARGV.include?('-l') || ARGV.include?('--l')
  FileUtils.rm('debug.log') rescue nil
  DataMapper::Logger.new('debug.log', :debug)
elsif ARGV.include?('-ls') || ARGV.include?('--ls')
  DataMapper::Logger.new(STDOUT, :debug)
end

DataMapper.setup(:default, 'mysql://root:@localhost/ruote')
#DataMapper.setup(:default, 'sqlite3::memory:')
#DataMapper.setup(:default, 'sqlite3:ruote_test.db')

#DataMapper.repository(:default) do
#  Ruote::Dm::Document.all.destroy! rescue nil
#  Ruote::Dm::Document.auto_upgrade!
#end

def new_storage (opts)

  Ruote::Dm::DmStorage.new(:default, opts)
end

