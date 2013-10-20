require 'thread'
require 'carnivore-github/github'

module Carnivore
  class Source
    class GithubUserEvents < Github

      attr_reader :last_id
      attr_reader :queue

      def setup(args={})
        @queue = Queue.new
        super
      end

      def terminate
        super
        if(timer)
          timer.cancel
        end
      end

      def connect
        init = fetch(url(events_path), false)
        update_settings(init)
        @last_id = init.parse_body.first['id']
        debug "Initial last id set: #{last_id}"
        @timer = after(poll.to_i) do
          result = fetch(url(events_path))
          if(result.status == 200)
            body = result.parse_body
            messages = body
            last_idx = messages.index{|m| m['id'] == last_id}
            if(last_idx)
              messages = messages.slice(0, last_idx)
              unless(messages.empty?)
                @last_id = messages.first['id']
                debug "Last id updated to: #{last_id}"
              end
              messages.each do |m|
                queue << m
              end
            end
            update_settings(result)
          end
        end
      end

      def events_path
        if(username)
          File.join("users/#{username}", 'events')
        else
          'events'
        end
      end

      def receive(*args)
        queue.pop
      end

    end
  end
end
