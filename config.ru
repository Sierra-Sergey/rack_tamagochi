require './app'

use Rack::Reloader, 0
use Rack::Static, urls: ['/css', '/images'], root: 'public'
use Rack::Auth::Basic do |_username, password|
  password == 'admin'
end

run Pet
