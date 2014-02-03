require 'spec_helper'

describe Plyushkin::Test::DateValue do
  it { should persist_attribute(:value) }
  it { should_not persist_attribute(:value2) }
  it { should persist_attribute(:value).with_format(:to_date) }
  it { should_not persist_attribute(:value).with_format(:to_datetime) }
end

describe Plyushkin::Test::WidgetOne do
  it { should hoard(:apples) }
  it { should_not hoard(:beans) }
end
