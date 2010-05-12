
require 'ci'

Ci::task do

  mailto 'jmettraux@gmail.com'

  git 'http://github.com/jmettraux/ruote.git'
  git 'http://github.com/jmettraux/ruote-dm.git'

  sh 'psql --version'

  options :dir => 'ruote', :rvm => '1.9.1@ruote_yajl'

  ruby 'test/unit/storage.rb -- --dm'
  ruby 'test/functional/test.rb -- --dm'
end

