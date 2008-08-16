class HyperactiveToVersion50 < ActiveRecord::Migration
  def self.up
    Rails.plugins["hyperactive"].migrate(50)
  end

  def self.down
    Rails.plugins["hyperactive"].migrate(49)
  end
end
