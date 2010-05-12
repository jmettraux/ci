
require 'ci'

Ci::task do

  mailto 'jmettraux@gmail.com'

  git 'http://github.com/jmettraux/ruote.git'

  #sh 'curl -s http://127.0.0.1:5984'

  ruby 'test/unit/test.rb', :dir => 'ruote', :rvm => '1.9.1@ruote_yajl'
  ruby 'test/functional/test.rb', :dir => 'ruote', :rvm => '1.9.1@ruote_yajl'
end

