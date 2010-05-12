
require 'ci'

Ci::task do

  mailto 'jmettraux@gmail.com'

  git 'http://github.com/jmettraux/ruote.git'
  git 'http://github.com/jmettraux/ruote-couch.git'

  sh 'curl -s http://127.0.0.1:5984'

  options :dir => 'ruote', :rvm => '1.9.1@ruote_yajl'

  ruby 'test/unit/storage.rb --couch'
  ruby 'test/functional/test.rb --couch'
end

