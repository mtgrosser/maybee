# Project-specific configuration for CruiseControl.rb

Project.configure do |project|
  #project.use_bundler = false
  #project.build_command = '/usr/local/bin/rbfu @1.9.3 ruby cruise_script.rb'
  project.scheduler.polling_interval = 15.minutes
  # Set any args for bundler here
  # Defaults to '--path=#{project.gem_install_path} --gemfile=#{project.gemfile} --no-color'
  #project.bundler_args = "--path=#{project.gem_install_path} --gemfile=#{project.gemfile} --no-color --local"
end
