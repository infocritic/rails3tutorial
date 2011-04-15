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