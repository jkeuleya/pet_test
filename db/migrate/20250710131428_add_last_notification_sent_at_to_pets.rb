class AddLastNotificationSentAtToPets < ActiveRecord::Migration[7.2]
  def change
    add_column :pets, :last_notification_sent_at, :datetime
  end
end
