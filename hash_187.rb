
require 'ci'

Ci::task do

  mailto 'jmettraux@gmail.com'

  git 'http://github.com/jmettraux/ruote.git'

  ruby 'test/unit/test.rb', :dir => 'ruote', :rvm => '1.8.7@ruote_yajl'
  ruby 'test/unit/storage.rb', :dir => 'ruote', :rvm => '1.8.7@ruote_yajl'
  ruby 'test/functional/test.rb', :dir => 'ruote', :rvm => '1.8.7@ruote_yajl'
end

