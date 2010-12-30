
require 'ci'


Ci::all do

  sh 'rvm -v'

  reporter :stdout

  reporter :mail, :to => 'jmettraux@gmail.com'

  reporter(
    :s3,
    :bucket => 'ruote-ci',
    #:access_key_id => arg('aki'), # --aki xxx
    #:secret_access_key => arg('sak')) # --sak yyy
    :access_key_id => ENV['AMAZON_KEY_ID'],
    :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY'])
end

Ci::bundle 'ruote' do

  source 'http://rubygems.org'
  gem 'builder'
  gem 'mailtrap'
  gem 'yajl-ruby', :require => 'yajl'
  gem 'json_pure', '1.4.6'
  gem 'ruote', :git => 'http://github.com/jmettraux/ruote.git', :branch => 'ruote2.1'
end

Ci::task 'ruote on 1.8.7-p249' do

  rvm :use => '1.8.7-p249'

  bundle 'ruote'

  ruby 'ruote/test/unit/test.rb'
  #ruby 'ruote/test/unit/storage.rb'
  #ruby 'ruote/test/functional/test.rb'

  #ruby 'ruote/test/unit/test.rb', '--', '--fs'
  #ruby 'ruote/test/unit/storage.rb', '--', '--fs'
  #ruby 'ruote/test/functional/test.rb', '--', '--fs'
end

Ci::task 'ruote on 1.9.2-p136' do

  rvm :use => '1.9.2-p136'

  bundle 'ruote'

  ruby 'ruote/test/unit/test.rb'
  #ruby 'ruote/test/unit/storage.rb'
  #ruby 'ruote/test/functional/test.rb'

  #ruby 'ruote/test/unit/test.rb', '--', '--fs'
  #ruby 'ruote/test/unit/storage.rb', '--', '--fs'
  #ruby 'ruote/test/functional/test.rb', '--', '--fs'
end

