rbfu = "rbfu @1.9.3"
bundle_exec = "#{rbfu} bundle exec"
rake = "#{bundle_exec} rake"

# Manually ensure bundle is complete and missing gems are installed locally
unless system("#{rbfu} bundle check")
  unless system("#{rbfu} bundle install --path=vendor/bundle")
    exit(-1)
  end
end

commands = ["#{rake} test"]
result = commands.all? { |cmd| system(cmd) }
exit(result ? 0 : -1)
