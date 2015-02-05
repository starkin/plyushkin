# Add sqlite
I18n.enforce_available_locales = false
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.timestamps
    end
    create_table :widget_ones do |t|
      t.timestamps
    end
    create_table :widget_twos do |t|
      t.timestamps
    end
    create_table :ignores_unchanged_widgets do |t|
      t.timestamps
    end
    create_table :callback_widgets do |t|
      t.timestamps
    end
    create_table :filtered_models do |t|
      t.timestamps
    end
  end
end
CreateMembers.up
