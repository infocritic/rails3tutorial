# == Schema Information
# Schema version: 20110417073613
#
# Table name: microposts
#
#  id         :integer         not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

# Chapt 11.1.1
class Micropost < ActiveRecord::Base
  attr_accessible :content 
  
  belongs_to      :user      # Chapt 11.1.2
  
  # Chapt 11.1.4
  validates       :content, :presence => true, :length => { :maximum => 140 }
  validates       :user_id, :presence => true
  
  default_scope   :order => 'microposts.created_at DESC'     # Chapt 11.1.3
end
