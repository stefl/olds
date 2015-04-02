# lib/tasks/daily.rake

task :daily => :environment do
  today = Date.today
  Story.fetch_for_day today.day, today.month
  tomorrow = Date.tomorrow
  Story.fetch_for_day tomorrow.day, tomorrow.month
end