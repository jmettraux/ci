
require 'ci'

Ci::task do

  mailto 'jmettraux@gmail.com'

  git 'http://github.com/jmettraux/ruote.git'

  options :dir => 'ruote', :rvm => '1.9.1@ruote_yajl'

  ruby 'test/unit/test.rb'
  ruby 'test/unit/storage.rb'
  ruby 'test/functional/test.rb'
end

