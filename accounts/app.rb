class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  ACCOUNTS = [
    {
      id: 1,
      user_id: 1,
      value: 200_000_000
    },
    {
      id: 2,
      user_id: 2,
      value: 100_000_000
    }
  ]

  get '/' do
    ACCOUNTS.to_json
  end

  get %r{/(\d+)} do |id|
    ACCOUNTS.find { |u| u[:id] == id.to_i }.to_json
  end

  get %r{/user/(\d+)} do |user_id|
    ACCOUNTS.find { |u| u[:user_id] == user_id.to_i }.to_json
  end
end
