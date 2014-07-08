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

Configure the backend service that plyushkin will use in your environments/&lt;environment&gt;.rb file.  
For example, to configure the stub service for running specs, the following code would go in your 
config/environments/test.rb file of a Rails application.

    config.before_initialize do |c|
      Plyushkin::Service.service = Plyushkin::Service::Stub.new
    end

To use plyushkin against a live web service,

    config.before_initialize do |c|
      Plyushkin::Service.service =
        Plyushkin::Service::Web.new(:url => 'http://yourservice.com')
    end

## Quick start
To add a property, use the `hoards` class macro on a class that inherits from ActiveRecord::Base.

    class Vehicle < ActiveRecord::Base
      hoards :mechanic
    end
    
This will add a mechanic attribute to the Vehicle class. To set the mechanic for the vehicle

    v = Vehicle.new
    v.mechanic.create(:value => 'Mike')

This will update the in-memory version of the vehicle, but has not yet persisted the change.  To
save the change to the plyushkin-service

    v.save

To get the value of the vehicle's mechanic

    v.mechanic.last.value  # => 'Mike'

To get the date that the mechanic was last set

    v.mechanic.last.date   # => Wed, 09 Jul 2014 11:52:12 -0500

Every Plyushkin value has a `date` attribute.

Once we change the mechanic on the vehicle, we will now have historical data and can view all the
mechanics that worked on the vehicle.

    v.mechanic.create(:value => 'Joe')
    v.mechanic.all.map(&:value) # => ['Mike', 'Joe']

#### Setting past values

To store a property using a DateTime other than the current time

    v.mechanic.create(:value => 'Sally', :date => 3.days.ago)
    v.mechanic.last.date # => Sun, 06 Jul 2014 11:52:12 -0500

#### Value types

In the example above, we needed to use `last` and `all` methods to see the mechanic.  This is
because the property getter returns a `Plyushkin::Property`.  A property consists of
instances of classes that derive from `Plyushkin::BaseValue`.

`Plyushkin::BaseValue` provides basic value functionality.  It provides a `date` attribute, that is
required for all Plyushkin values.  And, it provides four formatters, `to_i`, `to_f`,
`to_date` and `to_bool`.

When not specifying a value type when calling `hoards`, Plyushkin will use a 
`Plyushkin::StringValue` as the value type.  In addition to the base implementation, this basic
implementation includes one attribute, `value`, which uses no formatter.

In most applications, you will not want to use `Plyushkin::StringValue`, and instead would want
to create your own value type implementation that derives from `Plyushkin::BaseValue` and use custom
value types.

##### Creating a custom value type

In our vehicle example, if we wanted to capture oil change history, we would start by creating a
custom value type.

    class OilChangeValue < Plyushkin::BaseValue
      persisted_attr :mileage, :formatter => :to_i
      persisted_attr :oil_type
    end

The `OilChangeValue` will have a mileage attribute that uses the `to_i` formatter.  Formatters attempt to
convert the attribute assignment to a specified format.  If no formatter is provided, the attribute will be
stored as a string.

We can now add this to our vehicle

    class Vehicle < ActiveRecord::Base
      hoards :mechanic
      hoards :oil_change, :type => OilChangeValue
    end

To set the oil_change

    v.oil_change.create(:mileage => '1234', :oil_type => '10W30')

To get the latest oil change details

    v.oil_change.last.mileage  # => 1234
    v.oil_change.last.oil_type # => '10W30'

##### Specifiying a callback after a value is stored

When defining a hoards property, you can set a callback for after the value is persisted.  For example,
if the vehicle table contains a `next_oil_change_mileage` column, we might want to update it whenever
an oil_change is saved.  

    class Vehicle < ActiveRecord::Base
      hoards :oil_change, :type => OilChangeValue,
             :after_create => :calculate_next_oil_change_mileage

      def calculate_next_oil_change_mileage
        next_oil_change_mileage = oil_change.last.mileage + 3000
      end
    end

##### Ignoring unchanged values

There may be a case where we don't need to track history when a value is set, but is the same as the
previous value.  For example, if the mechanic for your last maintenance is Mike and Mike again
performs the maintenance, we don't need two data points recorded.

In the current configuration, calling create twice would create two values
    
    v.mechanic.create(:value => 'Joe')
    v.mechanic.create(:value => 'Mike')
    v.mechanic.create(:value => 'Mike')
    v.mechanic.all.map(&:value) # => [ 'Joe', 'Mike', 'Mike' ]

By setting the `:ignore_unchanged_values` option, we can change this behavior.

    class Vehicle < ActiveRecord::Base
      hoards :mechanic, :ignore_unchanged_values => true
    end

    v.mechanic.create(:value => 'Joe')
    v.mechanic.create(:value => 'Mike')
    v.mechanic.create(:value => 'Mike')
    v.mechanic.all.map(&:value) # => [ 'Joe', 'Mike' ]

In this example, the date of the last value will be the date that `mechanic` was first assigned 'Mike'.

###### Validation

Validation is done with `ActiveModel::Validations`.  This is included in `Plyushkin::BaseValue`.

    class OilChangeValue < Plyushkin::BaseValue
      persisted_attr :oil_type
      persisted_attr :mileage

      validates :oil_type, :inclusion    => { :in => ['10W30', '5W40'] }
      validates :mileage,  :numericality => { :only_integer             => true,
                                              :greater_than_or_equal_to => 0 }
    end

###### Adding behavior

`Plyushkin::BaseValue` and it's subclasses are classes and additional behavior can be added to 
encapsulate functionality.

    class OilChange < Plyushkin::BaseValue
      persisted_attr :mileage

      def mileage_as_km
        mileage / 0.6214
      end
    end

    v.oil_change.create(:mileage => 10000)
    v.oil_change.last.mileage       # => 10000
    v.oil_change.last.mileage_as_km # => 6214

##### Accessing a property that has not had any values assigned

`Plyushkin::NilValue` is a special case used when no value has been assigned to a property yet.

    v = Vehicle.new
    v.mechanic.last            # => Plyushkin::NilValue
    v.mechanic.last.value      # => nil
    v.oil_change.last          # => Plyushkin::NilValue
    v.oil_change.last.mileage  # => nil
    v.oil_change.last.oil_type # => nil

This is necessary so that consumers of the property do not need to check if a value is nil before trying
to access an attribute of the value.

In addition, `Plyushkin::Property` has a property `empty?` to indicate whether any values have been assigned

    v.mechanic.empty?   # => true
    v.oil_change.empty? # => true

## Testing

Plyushkin provides RSpec matchers for testing class macros.  To use these matchers, 
add `config.include Plyushkin::Test::Matchers` to your RSpec.configure in spec_helper.

#### Testing custom value types
To test Plyushkin configuration in your custom value type:

    describe OilChangeValue do
      it { should persist_attribute(:mileage) }
      it { should persist_attribute(:mileage).with_format(:to_i) }
      it { should_not persist_attribute(:air_filter) }
      it { should persist_attribute(:oil_type) }
      it { should_not persist_attribute(:oil_type).with_format(:to_f) }

      # RSpec Shoulda matchers also work to test validations here.
    end

To test Plyushkin configuration in your model:

    describe Vehicle do
      it { should hoard(:mechanic) }
      it { should hoard(:mechanic).and_ignore_unchanged_values }
      it { should hoard(:oil_change).of_type(OilChangeValue) }
      it { should hoard(:oil_change).of_type(OilChangeValue).
        and_after_create_call(:calculate_next_oil_change_mileage) }
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
