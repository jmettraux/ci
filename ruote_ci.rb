
require 'ci'

Ci::all do

  mailto 'jmettraux@gmail.com'

  git 'http://github.com/jmettraux/ruote.git'
end

Ci::task 'ruote 1.8.7' do

  options :dir => 'ruote', :rvm => '1.8.7@ruote_yajl'

  ruby 'test/unit/test.rb'
  ruby 'test/unit/storage.rb'
  ruby 'test/functional/test.rb'
end

exit

Ci::task 'ruote 1.9.1' do

  options :dir => 'ruote', :rvm => '1.9.1@ruote_yajl'

  ruby 'test/unit/test.rb'
  ruby 'test/unit/storage.rb'
  ruby 'test/functional/test.rb'
end

Ci::task 'ruote fs 1.8.7' do

  options :dir => 'ruote', :rvm => '1.8.7@ruote_yajl'

  ruby 'test/unit/storage.rb -- --fs'
  ruby 'test/functional/test.rb -- --fs'
end

Ci::task 'ruote fs 1.9.1' do

  options :dir => 'ruote', :rvm => '1.9.1@ruote_yajl'

  ruby 'test/unit/storage.rb --fs'
  ruby 'test/functional/test.rb --fs'
end

Ci::task 'ruote-dm 1.8.7' do

  git 'http://github.com/jmettraux/ruote-dm.git'

  sh 'cp dm_connection.rb ruote-dm/test/integration_connection.rb'

  sh 'psql --version'

  options :dir => 'ruote', :rvm => '1.8.7@ruote_yajl'

  ruby 'test/unit/storage.rb -- --dm'
  ruby 'test/functional/test.rb -- --dm'
end

Ci::task 'ruote-dm 1.9.1' do

  git 'http://github.com/jmettraux/ruote-dm.git'

  sh 'cp dm_connection.rb ruote-dm/test/integration_connection.rb'

  sh 'psql --version'

  options :dir => 'ruote', :rvm => '1.9.1@ruote_yajl'

  ruby 'test/unit/storage.rb -- --dm'
  ruby 'test/functional/test.rb -- --dm'
end

Ci::task 'ruote-redis 1.8.7' do

  git 'http://github.com/jmettraux/ruote-redis.git'

  sh 'dpkg -l redis-server | grep redis-server'

  options :dir => 'ruote', :rvm => '1.8.7@ruote_yajl'

  ruby 'test/unit/storage.rb -- --redis'
  ruby 'test/functional/test.rb -- --redis'
end

Ci::task 'ruote-redis 1.9.1' do

  git 'http://github.com/jmettraux/ruote-redis.git'

  sh 'dpkg -l redis-server | grep redis-server'

  options :dir => 'ruote', :rvm => '1.9.1@ruote_yajl'

  ruby 'test/unit/storage.rb -- --redis'
  ruby 'test/functional/test.rb -- --redis'
end

Ci::task 'ruote-couch 1.8.7' do

  git 'http://github.com/jmettraux/ruote-couch.git'

  sh 'curl -s http://127.0.0.1:5984'

  options :dir => 'ruote', :rvm => '1.8.7@ruote_yajl'

  ruby 'test/unit/storage.rb -- --couch'
  ruby 'test/functional/test.rb -- --couch', :timeout => 40 * 60
end

Ci::task 'ruote-couch 1.9.1' do

  git 'http://github.com/jmettraux/ruote-couch.git'

  sh 'curl -s http://127.0.0.1:5984'

  options :dir => 'ruote', :rvm => '1.9.1@ruote_yajl'

  ruby 'test/unit/storage.rb --couch'
  ruby 'test/functional/test.rb --couch', :timout => 40 * 60
end

