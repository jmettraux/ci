
require 'ci'

Ci::task do

  mailto 'jmettraux@gmail.com'

  git 'http://github.com/jmettraux/ruote.git'

  ruby 'test/unit/storage.rb --fs', :dir => 'ruote', :rvm => '1.9.1@ruote_yajl'
  ruby 'test/functional/test.rb --fs', :dir => 'ruote', :rvm => '1.9.1@ruote_yajl'
end

