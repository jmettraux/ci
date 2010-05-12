
require 'ci'

Ci::task do

  mailto 'jmettraux@gmail.com'

  git 'http://github.com/jmettraux/ruote.git'

  #sh 'curl -s http://127.0.0.1:5984'

  ruby 'test/functional/test.rb --fs', :dir => 'ruote', :rvm => '1.8.7@ruote_yajl'
end

