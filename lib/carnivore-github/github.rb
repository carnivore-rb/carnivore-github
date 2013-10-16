require 'carnivore'
require 'timers'
require 'http'
require 'json'

class Carnivore
  class Source
    class Github < Source

      attr_accessor :username
      attr_accessor :args
      attr_accessor :etag
      attr_accessor :poll
      attr_accessor :base_url
      attr_accessor :timer
      attr_accessor :credentials

      def initialize(args={})
        @username = args[:username]
        super
      end

      def setup
        if(Carnivore::Config.get(:github, :username))
          @username = Carnivore::Config.get(:github, :username)
        end
        @base_url = Carnivore::Config.get(:github, :api_url)
        @credentials = Carnivore::Config.get(:github, :credentials)
        @poll = 60
        @timer = Timers.new
      end

      protected

      def url(path)
        File.join(base_url, path)
      end

      def update_settings(response)
        @etag = init.headers['Etag'] if init.headers['Etag']
        @poll = init.headers['X-Poll-Interval'] if init.headers['X-Poll-Interval']
      end

      def fetch(url, restrict=true)
        headers = {:accept => 'application/json'}
        if(restrict && etag)
          headers.merge!('If-None-Match' => etag)
        end
        if(credentials)
          require 'base64'
          auth_string = "#{credentials[:username]}:#{credentials[:password]}"
          headers.merge!('Authorization' => "Basic #{Base64.encode64(auth_string)}")
        end
        HTTP.with_headers(headers).get(url).response
      end
    end
  end
end
