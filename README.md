# Carnivore Github

Provides Github `Carnivore::Source`

# Usage

## Github

```ruby
require 'carnivore'
require 'carnivore-github'

Carnivore.configure do
  source = Carnivore::Source.build(
    :type => :github_events,
    :args => {
      :username => 'user'
    }
  )
end
```

# Info
* Carnivore: https://github.com/carnivore-rb/carnivore
* Repository: https://github.com/carnivore-rb/carnivore-github
* IRC: Freenode @ #carnivore
