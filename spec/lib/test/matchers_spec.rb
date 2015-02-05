require 'spec_helper'

describe Plyushkin::Test::DateValue do
  it { should     persist_attribute(:value) }
  it { should_not persist_attribute(:value2) }
  it { should     persist_attribute(:value).with_format(:to_date) }
  it { should_not persist_attribute(:value).with_format(:to_datetime) }
  it { should     persist_attribute(:is_deleted).with_format(:to_bool) }
end

describe Plyushkin::Test::WidgetOne do
  it { should     hoard(:apples) }
  it { should     hoard(:apples).of_type(Plyushkin::StringValue) }
  it { should_not hoard(:beans) }
  it { should_not hoard(:apples).of_type(Plyushkin::Test::DateValue) }
end

describe Plyushkin::Test::IgnoresUnchangedWidget do
  it { should  hoard(:apples).and_ignore_unchanged_values }
  it { 
    should     hoard(:beans)
    should_not hoard(:beans).and_ignore_unchanged_values 
  }
end

describe Plyushkin::Test::CallbackWidget do
  it { should     hoard(:apples).of_type(Plyushkin::StringValue).and_after_create_call(:core) }
  it { should     hoard(:apples) 
       should_not hoard(:apples).and_after_create_call(:core2) }
  it { should     hoard(:beans) 
       should_not hoard(:beans).and_after_create_call(:core) }
end

describe Plyushkin::Test::FilteredModel do
  it { should     hoard(:is_deleted).of_type(Plyushkin::Test::DateValue).and_filter_by(:test_filter) }
  it { should_not hoard(:is_deleted).and_filter_by(:another_filter) }
end
