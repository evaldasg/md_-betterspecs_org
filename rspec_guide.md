### How to describe your methods

### Use contexts

### Keep your description short

### Single expectation test

### Test all possible cases

### Expect vs Should syntax

### Use subject

### Use let and let!

### Mock or not to mock

### Create only the data you need

### Use factories and not fixtures

### Easy to read matcher

### Shared Examples

### Test what you see

### Don't use should

### Automatic tests with guard

Running all the test suite every time you change your app can be cumbersome. It takes a lot of time and it can break your flow. With Guard you can automate your test suite running only the tests related to the updated spec, model, controller or file you are working at.

```ruby
# good
bundle exec guard
```

```ruby
# good
guard 'rspec', cli: '--drb --format Fuubar --color', version: 2 do
  # run every updated spec file
  watch(%r{^spec/.+_spec\.rb$})
  # run the lib specs when a file in lib/ changes
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  # run the model specs related to the changed model
  watch(%r{^app/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  # run the view specs related to the changed view
  watch(%r{^app/(.*)(\.erb|\.haml)$}) { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  # run the integration specs related to the changed controller
  watch(%r{^app/controllers/(.+)\.rb}) { |m| "spec/requests/#{m[1]}_spec.rb" }
  # run all integration tests when application controller change
  watch('app/controllers/application_controller.rb') { "spec/requests" }
end
```

Guard is a fine tool but as usual it doesn't fit all of your needs. Sometimes your TDD workflow works best with a keybinding that makes it easy to run just the examples you want when you want to. Then, you can use a rake task to run the entire suite before pushing code. [Here](https://github.com/myronmarston/vim_files/blob/5bd4faad7c020ebcbf62dcbc59985262b4eacb53/vimrc.after#L61-103) the vim keybinding.

### Faster tests (preloading Rails)

### Stubbing HTTP requests

### Useful formatter

