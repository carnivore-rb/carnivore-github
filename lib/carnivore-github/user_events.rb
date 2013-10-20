require 'carnivore-github/github'

module Carnivore
  class Source
    class GithubUserEvents < Github

      attr_reader :last_id

      def connect
        init = fetch(url(events_path), false)
        update_settings(init)
        @last_id = init.parse_body.first['id']
        debug "Initial last id set: #{last_id}"
      end

      def events_path
        if(username)
          File.join("users/#{username}", 'events')
        else
          'events'
        end
      end

      def receive(*args)
        messages = []
        timer.after(poll.to_i) do
          result = fetch(url(events_path))
          if(result.status == 200)
            body = result.parse_body
            messages = body
            last_idx = messages.index{|m| m['id'] == last_id}
            if(last_idx)
              messages = messages.slice(0, last_idx)
            end
            unless(messages.empty?)
              @last_id = messages.first['id']
              debug "*" * 20
              debug "Last id updated to: #{last_id}"
              debug "*" * 20
            end
            update_settings(result)
          end
        end
        timer.wait
        messages
      end

    end
  end
end
