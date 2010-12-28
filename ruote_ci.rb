
require 'ci'

Ci::all do

  mailto 'jmettraux@gmail.com'

  sh 'rvm -v'
end

Ci::bundle 'ruote' do

  source 'http://rubygems.org'
  gem 'builder'
  gem 'mailtrap'
  gem 'yajl-ruby', :require => 'yajl'
  gem 'json_pure'
  gem 'ruote', :git => 'http://github.com/jmettraux/ruote.git', :branch => 'ruote2.1'
end

Ci::task 'ruote on 1.8.7-p249' do

  #options :rvm => '1.8.7-p249'
  rvm :use => '1.8.7-p249'

  bundle 'ruote'

  ruby 'ruote/test/unit/test.rb'
  ruby 'ruote/test/unit/storage.rb'
  ruby 'ruote/test/functional/test.rb'

  ruby 'ruote/test/unit/test.rb', '--', '--fs'
  ruby 'ruote/test/unit/storage.rb', '--', '--fs'
  ruby 'ruote/test/functional/test.rb', '--', '--fs'
end

Ci::task 'ruote on 1.9.2-p136' do

  rvm :use => '1.9.2-p136'

  bundle 'ruote'

  ruby 'ruote/test/unit/test.rb'
  ruby 'ruote/test/unit/storage.rb'
  ruby 'ruote/test/functional/test.rb'

  ruby 'ruote/test/unit/test.rb', '--', '--fs'
  ruby 'ruote/test/unit/storage.rb', '--', '--fs'
  ruby 'ruote/test/functional/test.rb', '--', '--fs'
end

