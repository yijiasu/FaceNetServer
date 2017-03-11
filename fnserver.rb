require 'sinatra'
require 'redis'
require 'digest/md5'
require 'json'

class FNServer < Sinatra::Base

  redis = Redis.new(:host => "127.0.0.1")
  max_retry_times = 300
  get '/index' do
    return params
  end

  post '/upload' do

    @filename = params[:file][:filename]
    file = params[:file][:tempfile]
    new_filename = SecureRandom.hex() + "." + @filename.split(".")[-1]
    path = "/tmp/#{new_filename}"
    File.open(path, 'wb') do |f|
      f.write(file.read)
    end
    redis.publish "facenet_image", path

    token = Digest::MD5.hexdigest(path)
    return JSON.dump(:status => "ok", :token => token)

  end

  post '/check_result' do

    is_got_result = false
    tried_times = 0
    unless (params[:token] && params[:token].length != 0)
      return JSON.dump(:status => "error", :message => "token is required")
    else
      token = params[:token]
    end

    while (!is_got_result)
      tried_times = tried_times + 1
      if tried_times >= max_retry_times
        break
      else

        sleep 0.1
        if result = redis.get("facenet:#{token}")
          is_got_result = true
        end
      end
    end

    if is_got_result
      return JSON.dump(:status => "ok", :message => result)
    else
      return JSON.dump(:status => "error", :message => "timeout")
    end

  end

end
