require 'rspec/core'
require 'rspec/core/rake_task'
DUMMY_APP = 'spec/internal'
APP_ROOT = '.'
require 'jettywrapper'
JETTY_ZIP_BASENAME = 'v7.0.0'
Jettywrapper.url = "https://github.com/projecthydra/hydra-jetty/archive/#{JETTY_ZIP_BASENAME}.zip"

def system_with_command_output(command, options = {})
  pretty_command = "\n$\t#{command}"
  $stdout.puts(pretty_command)
  if !system(command)
    banner = "\n\n" + "*" * 80 + "\n\n"
    $stderr.puts banner
    $stderr.puts "Unable to run the following command:"
    $stderr.puts "#{pretty_command}"
    $stderr.puts banner
    exit!(-1) unless options.fetch(:rescue) { false }
  end
end

def within_test_app
  FileUtils.cd(DUMMY_APP)
  yield
  FileUtils.cd('../..')
end

desc "Clean out the test rails app"
task :clean do
  system_with_command_output("rm -rf #{DUMMY_APP}")
end

desc 'Rebuild the rails test app'
task :regenerate => [:clean, :generate]

desc "Create the test rails app"
task :generate do
  unless File.exists?(DUMMY_APP + '/Rakefile')
    system_with_command_output('rails new ' + DUMMY_APP)
    puts "Updating gemfile"

    gemfile_content = <<-EOV
    gem 'curate', :path=>'../../../#{File.expand_path('../../', __FILE__).split('/').last}'
    gem 'kaminari', github: 'harai/kaminari', branch: 'route_prefix_prototype'
    gem 'browse-everything'
    gem 'clamav'
    gem 'resque'
    gem 'resque-scheduler'
    gem 'change_manager', '1.0.0'
    gem 'rake', '11.2.2'

    group :test do
      gem 'capybara'
      gem 'selenium-webdriver'
      gem 'coveralls', require: false
      gem 'database_cleaner', '< 1.1.0'
      gem 'factory_girl_rails', '~> 4.2.0'
      gem 'rspec', '~> 2.14.0'
      gem 'launchy'
      gem 'poltergeist'
      gem 'rspec-html-matchers', '~> 0.4.0'
      gem 'simplecov', require: false
      gem 'test_after_commit'
      gem 'timecop'
      gem 'vcr'
      gem 'webmock'
    end
    EOV

    gemfile_content << "gem 'byebug'" unless ENV['TRAVIS']

    `echo "#{gemfile_content}" >> #{DUMMY_APP}/Gemfile`
    
    ## replace turbolink line to pin to 2.5.3
    system_with_command_output("sed -i -e \"s/gem 'turbolinks'/gem 'turbolinks', '2.5.3'/\" #{DUMMY_APP}/Gemfile")

    puts "Copying generator"
    system_with_command_output("cp -r spec/skeleton/* #{DUMMY_APP}")
    system_with_command_output("cp config/college_and_department.yml #{DUMMY_APP}/config")
    Bundler.with_clean_env do
      within_test_app do
        system_with_command_output("bundle update rake")
        system_with_command_output("bundle update turbolinks")
        system_with_command_output("bundle install")
        system_with_command_output("rails generate test_app")
 
        # These factories are autogenerated and conflict with our factories
        system_with_command_output('rm test/factories/users.rb', rescue: true)
        system_with_command_output("bundle exec rake db:migrate db:test:prepare")
      end
    end
  end
  puts "Done generating test app"
end

task :spec do
  Bundler.with_clean_env do
    within_test_app do
      Rake::Task['rspec'].invoke
    end
  end
end

desc "Run specs"
RSpec::Core::RakeTask.new(:rspec) do |t|
  if ENV['TRAVIS']
    case ENV['SPEC_GROUP'].to_s
    when '1'
      t.pattern = '../../spec/features/**/*_spec.rb'
    when '2'
      t.pattern = '../../spec/controllers/**/*_spec.rb'
    else
      pattern = FileList['../../spec/*/'].exclude(/\/(features|controllers)\//).map { |f| f << '**/*_spec.rb' }
      t.pattern = pattern
    end
  else
    t.pattern = '../**/*_spec.rb'
  end
  t.rspec_opts = ["--colour -I ../", '--tag ~js:true', '--backtrace', '--profile 20']
end


desc 'Run specs on travis'
task :ci => [:regenerate] do
  ENV['RAILS_ENV'] = 'test'
  ENV['TRAVIS'] = '1'
  Jettywrapper.unzip
  jetty_params = Jettywrapper.load_config
  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task['spec'].invoke
  end
  raise "test failures: #{error}" if error
end
