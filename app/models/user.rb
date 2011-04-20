# == Schema Information
# Schema version: 20110415143809
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean
#

class User < ActiveRecord::Base
  # Chapt 6.1.2
  attr_accessor   :password
  
  attr_accessible :name, :email, :password, :password_confirmation
  
  # Chapt 11.1.2 & Chapt 11.1.3
  has_many :microposts,    :dependent => :destroy
  
  # Chapt 12.1.2
  has_many :relationships, :foreign_key => "follower_id",
                           :dependent => :destroy
  
  # Chapt 12.1.4
  has_many :reverse_relationships, :dependent   => :destroy,
                                   :foreign_key => "followed_id",
                                   :class_name  => "Relationship" 
  has_many :following, :through => :relationships,  :source => :followed 
  has_many :followers, :through => :reverse_relationships,
                       :source => :follower
  
  # Chapt 6.2.3
  email_regex = /\A[\w+.\-]+@[a-z.\-\d]+\.[a-z]{2,}\z/i
  
  validates :name,     :presence => true,
                       :length   => { :maximum => 50 }
                       
  validates :email,    :presence   => true,
                       :format     => { :with => email_regex},
                       :uniqueness => {:case_sensitive => false}
                       
  validates :password, :presence     => true,
                       :confirmation => true,
                       :length       => { :within => 6..40 }
                       
  before_save :encrypt_password
  
  # Chapt 7.2.1
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end
  
  # Chapt 11.3.3
  def feed
    # The .where rails methode escapes everything after the '?'
    # to prevent SQL scripting attacks.
    Micropost.where("user_id = ?", id)
  end
  
  # Chapt 12.1.4
  # If no record is found by find_by_followed_id, it will return nil
  # which, in the Ruby context, is false. 
  def following?(followed)
    self.relationships.find_by_followed_id(followed)
  end
  
  # Chapt 12.1.4
  def follow!(followed)
    self.relationships.create!(:followed_id => followed.id)
  end

  # Chapt 12.1.4
  def unfollow!(followed)
    self.relationships.find_by_followed_id(followed).destroy
  end
  
  # Everything within this block becomes a Class Method as 
  # opposed to and instance method. See the following link
  # for details: 
  # http://railstips.org/blog/archives/2009/05/11/class-and-instance-methods-in-ruby/
  class << self
  
    # If not created within 'class << self' block, declare as
    # def self.authenticate...
    # Chapt 7.1.1
    def authenticate(email, submitted_password)
      user = find_by_email(email)
      # return nil if user.nil?
      # return user if user.has_password?(submitted_password)
      # Above two lines are functionally identical to the next line
      (user && user.has_password?(submitted_password)) ? user : nil
    end
    
    # Chapt 9.3.3
    def authenticate_with_salt(id, cookie_salt)
      user = User.find_by_id(id)
      (user && user.salt == cookie_salt) ? user : nil
    end
  end
  
  private 
  
    # Chapt 7.1.3
    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)      
    end
    
    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end
    
    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end
    
    # Chapt 7.2.2
    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end
