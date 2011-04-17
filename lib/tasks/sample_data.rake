# Chapt 10.3.2
require 'faker'

namespace :db do
  desc "Fill database with sample date"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    admin = User.create!(:name => "Example User",
                         :email => "example@railstutorial.org",
                         :password => "foobar",
                         :password_confirmation => "foobar")
    admin.toggle!(:admin)
    99.times do |n|
      name = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password = "password"
      User.create!(:name => name,
                   :email => email,
                   :password => password,
                   :password_confirmation => password)
    end
    
    # Chapt 11.2.2
    # Note, an alternative would be User.all[1..6] *BUT*
    # that method calls User.all from the db and then
    # discards all but 1..6.  Where using :limit => 6
    # only returns 6 rows from the db no matter how many
    # live in the table(s)
    User.all(:limit => 6).each do |user|
      50.times do
        user.microposts.create!(:content => Faker::Lorem.sentence(5))
      end
    end
  end
end