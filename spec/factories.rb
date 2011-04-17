Factory.define :user do |user|
  user.name                  "John Meyer"
  user.email                 "infocritic@gmail.com"
  user.password              "foobar"
  user.password_confirmation "foobar"
end

# Chapt 10.3.3
Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

# Chapt 11.1.3
Factory.define :micropost do |micropost|
  micropost.content         "Foo bar tastes good!"
  micropost.association     :user
end