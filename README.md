# Plyushkin

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'plyushkin'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install plyushkin

## Usage

Configure the backend service that plyushkin will use in your environments/<environment>.rb file.  
For example, to configure the stub service for running specs, the following code would go in your 
config/environments/test.rb file of a Rails application.

    config.before_initialize do |c|
      Plyushkin::Service.service = Plyushkin::Service::Stub.new
    end

To use plyushkin against a live web service,
assign an instance of ``Plyushkin::Service::Web.new(:url => 'http://yourservice.com')``

## Testing

Plyushkin provides RSpec matchers for testing class macros.  To use these matchers, 
add ``config.include Plyushkin::Test::Matchers`` to your RSpec.configure in spec_helper.

To test Plyushkin configuration in your model:

    describe YourModel do
      it { should persist_attribute(:your_attribute) }
      it { should_not persist_attribute(:your_non_plyushkin_attribute) }
      it { should persist_attribute(:your_attribute).with_format(:to_date) }
      it { should_not persist_attribute(:your_attribute).with_format(:not_a_formatter) }
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
