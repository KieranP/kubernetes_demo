class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    json Account.all
  end

  get %r{/(\d+)} do |id|
    json Account.find(id)
  end

  get %r{/user/(\d+)} do |user_id|
    json Account.find_by_user_id(user_id)
  end
end
