### How to describe your methods

Be clear about what method you are describing. For instance, use the Ruby documentation convention of . (or ::) when referring to a class method's name and # when referring to an instance method's name.

```ruby
# bad
describe 'the authenticate method for User' do
describe 'if the user is an admin' do
```

```ruby
# good
describe '.authenticate' do
describe '#admin?' do
```

### Use contexts

Contexts are a powerful method to make your tests clear and well organized. In the long term this practice will keep tests easy to read.

```ruby
# bad
it 'has 200 status code if logged in' do
  expect(response).to respond_with 200
end
it 'has 401 status code if not logged in' do
  expect(response).to respond_with 401
end
```

```ruby
# good
context 'when logged in' do
  it { is_expected.to respond_with 200 }
end
context 'when logged out' do
  it { is_expected.to respond_with 401 }
end
```

When describing a context, start its description with "when" or "with".

### Keep your description short

A spec description should never be longer than 40 characters. If this happens you should split it using a context.

```ruby
# bad
it 'has 422 status code if an unexpected params will be added' do
```

```ruby
# good
context 'when not valid' do
  it { is_expected.to respond_with 422 }
end
```

In the example we removed the description related to the status code, which has been replaced by the expectation it { is_expected.to respond_with 422 }. If you run this test typing rspec filename you will obtain a readable output.

```ruby
# Formatted Output
when not valid
  it should respond with 422
```

### Single expectation test

The 'one expectation' tip is more broadly expressed as 'each test should make only one assertion'. This helps you on finding possible errors, going directly to the failing test, and to make your code readable.

In isolated unit specs, you want each example to specify one (and only one) behavior. Multiple expectations in the same example are a signal that you may be specifying multiple behaviors.

Anyway, in tests that are not isolated (e.g. ones that integrate with a DB, an external webservice, or end-to-end-tests), you take a massive performance hit to do the same setup over and over again, just to set a different expectation in each test. In these sorts of slower tests, I think it's fine to specify more than one isolated behavior.

```ruby
# good (isolated)
it { is_expected.to respond_with_content_type(:json) }
it { is_expected.to assign_to(:resource) }
```



```ruby
# Good (not isolated)
it 'creates a resource' do
  expect(response).to respond_with_content_type(:json)
  expect(response).to assign_to(:resource)
end
```



### Test all possible cases

Testing is a good practice, but if you do not test the edge cases, it will not be useful. Test valid, edge and invalid case. For example, consider the following action.

```ruby
# Destroy action
before_filter :find_owned_resources
before_filter :find_resource

def destroy
  render 'show'
  @consumption.destroy
end
```

The error I usually see lies in testing only whether the resource has been removed. But there are at least two edge cases: when the resource is not found and when it's not owned. As a rule of thumb think of all the possible inputs and test them.

```ruby
# bad
it 'shows the resource'
```

```ruby
# good
describe '#destroy' do

  context 'when resource is found' do
    it 'responds with 200'
    it 'shows the resource'
  end

  context 'when resource is not found' do
    it 'responds with 404'
  end

  context 'when resource is not owned' do
    it 'responds with 404'
  end
end
```

### Expect vs Should syntax

On new projects always use the expect syntax.

```ruby
# bad
it 'creates a resource' do
  response.should respond_with_content_type(:json)
end
```

```ruby
# good
it 'creates a resource' do
  expect(response).to respond_with_content_type(:json)
end
```

Configure the Rspec to only accept the new syntax on new projects, to avoid having the 2 syntax all over the place.

```ruby
# good
# spec_helper.rb
RSpec.configure do |config|
  # ...
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
```

On one line expectations or with implicit subject we should use is_expected.to.

```ruby
# bad
context 'when not valid' do
  it { should respond_with 422 }
end
```

```ruby
# good
context 'when not valid' do
  it { is_expected.to respond_with 422 }
end
```

On old projects you can use the transpec to convert them to the new syntax.

More about the new Rspec expectation syntax can be found here and here.

### Use subject

If you have several tests related to the same subject use subject{} to DRY them up.

```ruby
# bad
it { expect(assigns('message')).to match /it was born in Belville/ }
```

```ruby
# good
subject { assigns('message') }
it { is_expected.to match /it was born in Billville/ }
```

RSpec has also the ability to use a named subject.

```ruby
# Good
subject(:hero) { Hero.first }
it "carries a sword" do
  expect(hero.equipment).to include "sword"
end
```

### Use let and let!

When you have to assign a variable instead of using a before block to create an instance variable, use let. Using let the variable lazy loads only when it is used the first time in the test and get cached until that specific test is finished. A really good and deep description of what let does can be found in this stackoverflow answer.

```ruby
# bad
describe '#type_id' do
  before { @resource = FactoryGirl.create :device }
  before { @type     = Type.find @resource.type_id }

  it 'sets the type_id field' do
    expect(@resource.type_id).to equal(@type.id)
  end
end
```

```ruby
# good
describe '#type_id' do
  let(:resource) { FactoryGirl.create :device }
  let(:type)     { Type.find resource.type_id }

  it 'sets the type_id field' do
    expect(resource.type_id).to equal(type.id)
  end
end
```

Use let to initialize actions that are lazy loaded to test your specs.

```ruby
# good
context 'when updates a not existing property value' do
  let(:properties) { { id: Settings.resource_id, value: 'on'} }

  def update
    resource.properties = properties
  end

  it 'raises a not found error' do
    expect { update }.to raise_error Mongoid::Errors::DocumentNotFound
  end
end
```

Use let! if you want to define the variable when the block is defined. This can be useful to populate your database to test queries or scopes.

Here an example of what let actually is.

```ruby
# good
# this:
let(:foo) { Foo.new }

# is very nearly equivalent to this:
def foo
  @foo ||= Foo.new
end
```

### Mock or not to mock

There's a debate going on. Do not (over)use mocks and test real behavior when possible. Testing real cases are useful when updating your application flow.

```ruby
# good
# simulate a not found resource
context "when not found" do
  before { allow(Resource).to receive(:where).with(created_from: params[:id]).and_return(false) }
  it { is_expected.to respond_with 404 }
end
```

Mocking makes your specs faster but they are difficult to use. You need to understand them well to use them well. Read more about.

### Create only the data you need

If you have ever worked in a medium size project (but also in small ones), test suites can be heavy to run. To solve this problem, it's important not to load more data than needed. Also, if you think you need dozens of records, you are probably wrong.

```ruby
# good
describe "User" do
  describe ".top" do
    before { FactoryGirl.create_list(:user, 3) }
    it { expect(User.top(2)).to have(2).item }
  end
end
```

### Use factories and not fixtures

This is an old topic, but it's still good to remember it. Do not use fixtures because they are difficult to control, use factories instead. Use them to reduce the verbosity on creating new data.

```ruby
# bad
user = User.create(
  name: 'Genoveffa',
  surname: 'Piccolina',
  city: 'Billyville',
  birth: '17 Agoust 1982',
  active: true
)
```

```ruby
# good
user = FactoryGirl.create :user
```

One important note. When talking about unit tests the best practice would be to use neither fixtures or factories. Put as much of your domain logic in libraries that can be tested without needing complex, time consuming setup with either factories or fixtures. Read more in this article

### Easy to read matcher

Use readable matchers and double check the available rspec matchers.

```ruby
# bad
lambda { model.save! }.to raise_error Mongoid::Errors::DocumentNotFound
```

```ruby
# good
expect { model.save! }.to raise_error Mongoid::Errors::DocumentNotFound
```

### Shared Examples

Making tests is great and you get more confident day after day. But in the end you will start to see code duplication coming up everywhere. Use shared examples to DRY your test suite up.

```ruby
# bad
describe 'GET /devices' do
  let!(:resource) { FactoryGirl.create :device, created_from: user.id }
  let(:uri) { '/devices' }

  context 'when shows all resources' do
    let!(:not_owned) { FactoryGirl.create factory }

    it 'shows all owned resources' do
      page.driver.get uri
      expect(page.status_code).to be(200)
      contains_owned_resource resource
      does_not_contain_resource not_owned
    end
  end

  describe '?start=:uri' do
    it 'shows the next page' do
      page.driver.get uri, start: resource.uri
      expect(page.status_code).to be(200)
      contains_resource resources.first
      expect(page).to_not have_content resource.id.to_s
    end
  end
end
```

```ruby
# good
describe 'GET /devices' do

  let!(:resource) { FactoryGirl.create :device, created_from: user.id }
  let(:uri)       { '/devices' }

  it_behaves_like 'a listable resource'
  it_behaves_like 'a paginable resource'
  it_behaves_like 'a searchable resource'
  it_behaves_like 'a filterable list'
end
```

In our experience, shared examples are used mainly for controllers. Since models are pretty different from each other, they (usually) do not share much logic.

### Test what you see

Deeply test your models and your application behaviour (integration tests). Do not add useless complexity testing controllers.

When I first started testing my apps I was testing controllers, now I don't. Now I only create integration tests using RSpec and Capybara. Why? Because I truly believe that you should test what you see and because testing controllers is an extra step you don't need. You'll find out that most of your tests go into the models and that integration tests can be easily grouped into shared examples, building a clear and readable test suite.

This is an open debate in the Ruby community and both sides have good arguments supporting their idea. People supporting the need of testing controllers will tell you that your integration tests don't cover all use cases and that they are slow.

Both are wrong. You can easily cover all use cases (why shouldn't you?) and you can run single file specs using automated tools like Guard. In this way you will run only the specs you need to test blazing fast without stopping your flow.

### Don't use should

Do not use should when describing your tests. Use the third person in the present tense. Even better start using the new expectation syntax.

```ruby
# bad
it 'should not change timings' do
  consumption.occur_at.should == valid.occur_at
end
```

```ruby
# good
it 'does not change timings' do
  expect(consumption.occur_at).to equal(valid.occur_at)
end
```

See the should_not gem for a way to enforce this in RSpec and the should_clean gem for a way to clean up existing RSpec examples that begin with "should."

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

Guard is a fine tool but as usual it doesn't fit all of your needs. Sometimes your TDD workflow works best with a keybinding that makes it easy to run just the examples you want when you want to. Then, you can use a rake task to run the entire suite before pushing code. Here the vim keybinding.

### Faster tests (preloading Rails)

When running a test on Rails the whole Rails app is loaded. This can take time and it can break your development flow. To solve this problem use solutions like Zeus, Spin or Spork. Those solutions will preload all libraries you (usually) do not change and reload controllers, models, view, factories and all the files you change most often.

Here you can find a spec helper and a Guardfile configuration based on Spork. With this configuration you will reload the whole app if a preloaded file (like initializers) change and you will run the single tests really, really fast.

The drawback of using Spork is that it aggressively monkey-patches your code and you could lose some hours trying to understand why a file is not reloaded. If you have some code examples using Spin or any other solution let us know.

Here you can find a Guardfile configuration for using Zeus. The spec_helper does not need to be modified, however, you will have to run `zeus start` in a console to start the zeus server before running your tests.

Although Zeus takes a less aggressive approach than Spork, one major drawback is the fairly strict usage requirements; Ruby 1.9.3+ (recommended using backported GC from Ruby 2.0) as well as an operating system that supports FSEvents or inotify is required.

Many criticisms are moved to those solutions. Those libraries are a band aid on a problem that is better solved through better design, and being intentional about only loading the dependencies that you need. Learn more reading the related discussion.

### Stubbing HTTP requests

Sometimes you need to access external services. In these cases you can't rely on the real service but you should stub it with solutions like webmock.

```ruby
# good
context "with unauthorized access" do
  let(:uri) { 'http://api.lelylan.com/types' }
  before    { stub_request(:get, uri).to_return(status: 401, body: fixture('401.json')) }
  it "gets a not authorized notification" do
    page.driver.get uri
    expect(page).to have_content 'Access denied'
  end
end
```

### Useful formatter

Use a formatter that can give you useful information about the test suite. I personally find fuubar really nice. To make it work add the gem and set fuubar as default formatter in your Guardfile.

```ruby
# good
# Gemfile
group :development, :test do
  gem 'fuubar'
```

```ruby
# good
# .rspec
--drb
--format Fuubar
--color
```

