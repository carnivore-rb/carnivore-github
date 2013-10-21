module Carnivore
  module Github
    module Util
      class Fetcher

        include Celluloid
        include Carnivore::Utils::Params
        include Carnivore::Utils::Logging

        attr_accessor :etag
        attr_accessor :poll
        attr_accessor :base_url
        attr_accessor :fetch_path
        attr_accessor :timer
        attr_accessor :credentials
        attr_accessor :notify
        attr_accessor :current_messages
        attr_accessor :last_id

        # args:: argument hash
        #  - :api_url:: Github API location
        #  - :credentials:: Login credentials
        #  - :fetch_path:: Path to fetch (required)
        #  - :notify:: Actor to notify on newly aquired messages (required)
        def initialize(args={})
          @base_url = args[:api_url] || 'https://api.github.com'
          @credentials = args[:credentials]
          @fetch_path = args[:fetch_path]
          @notify = args[:notify]
          @poll = 60
          @current_messages = []
          raise ArgumentError.new('`:fetch_path` argument must be provided') unless fetch_path
          raise ArgumentError.new('`:notify` argument must be provided') unless notify
        end

        # Returns current array of messages and clears
        def return_messages
          m = current_messages.dup
          current_messages.clear
          m
        end

        # Builds URL
        def url(path)
          File.join(base_url, path)
        end

        # response:: HTTP::Response
        # Updates internal settings like poll time and etag based on response
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

        # url:: URL endpoint
        # Fetches the provided URL. If credentials have been provided,
        # will make request with basic auth.
        def fetch(url)
          headers = {:accept => 'application/json'}
          headers.merge!('If-None-Match' => etag) if etag
          if(credentials)
            require 'base64'
            auth_string = "#{credentials[:username]}:#{credentials[:password]}"
            headers.merge!('Authorization' => "Basic #{Base64.encode64(auth_string)}")
          end
          HTTP.with_headers(headers).get(url).response
        end

        # Starts the fetcher process
        def start_fetcher
          init = fetch(url(fetch_path))
          update_settings(init)
          @last_id = init.parse_body.first['id']
          debug "Initial last id set: #{last_id}"
          loop do
            sleep(poll.to_i)
            result = fetch(url(fetch_path))
            if(result.status == 200)
              body = result.parse_body
              last_idx = body.index{|m| m['id'] == last_id}
              if(last_idx)
                body = body.slice(0, last_idx)
                unless(body.empty?)
                  @last_id = body.first['id']
                  debug "Last id updated to: #{last_id}"
                end
                self.current_messages += body.map do |m|
                  symbolize_hash(m)
                end
                notify.signal(:youve_got_mail)
              end
              update_settings(result)
            end
            debug 'Github fetcher loop iteration has completed'
          end
        end
      end
    end
  end
end
