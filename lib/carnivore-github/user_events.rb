require 'thread'
require 'carnivore-github/github'

module Carnivore
  class Source
    class GithubUserEvents < Github

      attr_accessor :username

      def setup(args={})
        @username = args[:username]
        super
      end

      def fetch_path
        if(username)
          File.join("users/#{username}", 'events')
        else
          'events'
        end
      end

    end
  end
end
