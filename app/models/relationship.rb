# == Schema Information
# Schema version: 20110419034255
#
# Table name: relationships
#
#  id          :integer         not null, primary key
#  follower_id :integer
#  followed_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

# Chapt 12.1.1
class Relationship < ActiveRecord::Base
  attr_accessible :followed_id
  
  # Chapt 12.1.2
  # belongs_to :follower, :foreign_key => "follower_id",  :class_name => "User"
  # belongs_to :followed, :foreign_key => "followed_id",  :class_name => "User"
  belongs_to :follower, :class_name => "User"
  belongs_to :followed, :class_name => "User"
  
  # Chapt 12.1.3
  validates :follower_id, :presence => true
  validates :followed_id, :presence => true

end
