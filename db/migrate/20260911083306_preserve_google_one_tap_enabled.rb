# frozen_string_literal: true

class PreserveGoogleOneTapEnabled < ActiveRecord::Migration[8.0]
  BOOLEAN_TYPE = 5

  def up
    return unless Migration::Helpers.existing_site?

    execute <<~SQL
      INSERT INTO site_settings (name, data_type, value, created_at, updated_at)
      VALUES ('google_one_tap_enabled', #{BOOLEAN_TYPE}, 't', NOW(), NOW())
      ON CONFLICT (name) DO NOTHING
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
