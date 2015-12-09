# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, "#{path}/log/cron.log"
set :environment, 'development'

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

every :reboot do
  job_type :application, "cd /usr/local/Ruby/syd_qbo_dev && :task :output"
  application "bundle exec unicorn -l 8080 -E development"
  application "bundle exec sidekiq"
end
#
## Clear out public/uploads/tmp directory
#every 1.day, :at => '4:30 am' do
#  runner "CarrierWave.clean_cached_files!"
#end
#
## Check SYD licensing via Jpegger service call
#every 1.day, :at => '4:30 am' do
#  runner "License.dog_license_check"
#end

# Clear out public/uploads/tmp directory
every 1.day, :at => '4:30 am' do
  runner "CarrierWave.clean_cached_files!"
  runner "ImageFile.delete_files"
  runner "ShipmentFile.delete_files"
  runner "CustPicFile.delete_files"
end

every 1.day, :at => '4:30 am' do
  runner "QboAccessCredential.remove_expired_token_credentials"
end