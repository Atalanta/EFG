# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# We need Rake to use our own environment
job_type :rake, "cd :path && /usr/local/bin/govuk_setenv efg bundle exec rake :task --silent :output"

job_type :runner_with_file, "cd :path && script/rails runner -e :environment :task :output"

# Since this is a back-office system, we have quite a big window to do maintenance tasks.

every 1.day, at: "08:00pm" do
  rake "db:data:migrate"
end

every 1.day, at: '10:00pm' do
  rake "loans:update_expired"
end

every 1.day, at: '10:30pm' do
  rake "data:extract"
end
