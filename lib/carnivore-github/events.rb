require 'carnivore-github/github'

class Carnivore
  class Source
    class GithubUserEvents < Github

      def connect
        init = fetch(url('events?per_page=1'), false)
        update_settings(init)
      end

      def receive(*args)
        messages = []
        timer.after(poll) do
          result = fetch(url('events'))
          if(res.status == 200)
            body = result.parse_body
            messages = body.map do |m|
              format(m)
            end
          end
        end
        timer.wait
        messages
      end

    end
  end
end
