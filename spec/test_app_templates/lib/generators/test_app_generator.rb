require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  def run_blacklight_generator
    say_status("warning", "GENERATING BL", :yellow)
    gem 'blacklight'
    Bundler.with_clean_env do
      run "bundle install"
    end
    generate 'blacklight:install'
  end

  def run_test_support_generator
    say_status("warning", "GENERATING test_support", :yellow)
    generate 'blacklight:test_support'
  end

end
