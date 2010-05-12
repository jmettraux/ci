
require 'ci'

Ci::task do

  mailto 'jmettraux@gmail.com'

  git 'http://github.com/jmettraux/ruote.git'
  git 'http://github.com/jmettraux/ruote-redis.git'

  sh 'dpkg -l redis-server | grep redis-server'

  options :dir => 'ruote', :rvm => '1.8.7@ruote_yajl'

  ruby 'test/unit/storage.rb -- --redis'
  ruby 'test/functional/test.rb -- --redis'
end

