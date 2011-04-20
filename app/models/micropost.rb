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
  
  # Chapt 11.1.4
  # Just a quick note... At this point (chapt 12.3.3) we have
  # defined the from_users_followed_by scope, it is worth noting
  # that this default_scope is appended to the scope. So we
  # a result set that is limited to from_users_followed_by
  # and ORDER BY created_at DESC!!  Wow.
  default_scope   :order => 'microposts.created_at DESC'     # Chapt 11.1.3
  
  # Chapt 12.3.3
  # We are going to replace the from_users_followed_by class method
  # created in chapt 12.3.2 with a from_users_followed_by scope, 
  # and then we will push the heavy lifting into a private method.
  # See the User model for a quick explanation of scope.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }
  
  # Chapt 12.3.2
  # def self.from_users_followed_by(user)
  #   # There is a problem with the first implementation. If there are
  #   # a large number of users being followed, the followed_ids will
  #   # pull all of them into memory. So we want to push the sub-select
  #   # into the databse by including the followed_ids right into the
  #   # where clause. We will accomplish this by replacing this method
  #   # with a scope.
  #   # The following lines where the first, 'naive' version.
  #   followed_ids = user.following.map(&:id).join (", ")
  #   where("user_id IN (#{ followed_ids }) OR user_id = ?", user)
  # 
  # end
  
  private
  
    # Chapt 12.3.3
    def self.followed_by(user)
      followed_ids = %(SELECT followed_id FROM relationships 
                       WHERE follower_id = :user_id)
      where("user_id IN (#{ followed_ids }) OR user_id = :user_id",
            :user_id => user)
    end
end
