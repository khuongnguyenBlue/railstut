User.create! name: "Example User", email: "example@railstutorial.org",
  password: "foobar", password_confirmation: "foobar", age: 20, activated: true,
  activated_at: Time.zone.now

99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create! name: name, email: email, password: password,
    password_confirmation: password, age: n%50+1, gender: n%2, activated: true,
    activated_at: Time.zone.now
end
