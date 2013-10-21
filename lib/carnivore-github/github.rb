require 'carnivore'
require 'timers'
require 'http'
require 'json'

require 'carnivore-github/util/fetcher'

module Carnivore
  class Source
    class Github < Source

      attr_reader :fetcher_name

      def setup(args={})
        @fetcher_name = "github_fetcher_#{name}".to_sym
        callback_supervisor.supervise_as(fetcher_name, Carnivore::Github::Util::Fetcher,
          args.merge(:fetch_path => fetch_path, :notify => current_actor)
        )
      end

      def connect
        fetcher.async.start_fetcher
      end

      def receive(*args)
        debug 'waiting for messages'
        wait(:youve_got_mail)
        debug 'yay, i got some mail!'
        fetcher.return_messages
      end

      protected

      def fetcher
        Celluloid::Actor[fetcher_name]
      end

      def fetch_path
        raise NoMethodError.new('`fetch_path` method must be defined within child class')
      end
    end
  end
end
