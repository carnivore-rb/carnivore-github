require 'carnivore'
require 'timers'
require 'http'
require 'json'

module Carnivore
  class Source
    class Github < Source

      attr_accessor :username
      attr_accessor :args
      attr_accessor :etag
      attr_accessor :poll
      attr_accessor :base_url
      attr_accessor :timer
      attr_accessor :credentials

      def setup(args={})
        @username = args[:username]
        @base_url = args[:api_url] || 'https://api.github.com'
        @credentials = args[:credentials]
        @poll = 60
      end

      protected

      def url(path)
        File.join(base_url, path)
      end

      def update_settings(response)
        @etag = response.headers['Etag'] if response.headers['Etag']
        @poll = response.headers['X-Poll-Interval'] if response.headers['X-Poll-Interval']
        @poll = @poll.to_i
        # Never drop below minute polling
        if(@poll < 60)
          @poll = 60
        end
        debug "Current Etag value: #{etag}"
        debug "Current polling value: #{poll}"
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
