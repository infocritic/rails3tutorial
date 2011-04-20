require 'spec_helper'

describe User do
  
  before(:each) do
    @attr = {
      :name => 'Example User',
      :email => 'user222@example.com',
      :password => "foobar",
      :password_confirmation => "foobar" 
    }
  end
  
  it 'should create a new instance given a valid atribute' do
    User.create!(@attr)
  end
  
  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ''))
    no_name_user.should_not be_valid
  end
  
  it "should require a name" do
    no_email_user = User.new(@attr.merge(:email => ''))
    no_email_user.should_not be_valid
  end
  
  it "should reject names that are too long" do
    long_name = 'a' * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end
  
  it "should accept valid email adresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end
  
  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com THE_USER_at_foo.bar.org first.last@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject duplicate email addresses" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:name => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  describe "passwords" do
    
    before(:each) do
      @user = User.new(@attr)
    end
    
    it "should have a password attribute" do
      @user.should respond_to(:password)
    end
    
    it "should have a password confirmation attribute" do
      @user.should respond_to(:password_confirmation)      
    end
  end
  
  describe "password validations" do
    
    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end
    
    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
      should_not be_valid
    end
    
    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short )
      User.new(hash).should_not be_valid
    end
    
    it "should reject long passwords" do
      long = "a" * 41
      hash = @attr.merge(:password => long, :password_confirmation => long )
      User.new(hash).should_not be_valid
    end
  end
  
  describe "password encryption" do
    
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password attribute" do
      @user.encrypted_password.should_not be_blank
    end
    
    it "should have a salt" do
      @user.should respond_to(:salt)
    end

    describe "has_password? method" do
      
      it "should exist" do
        @user.should respond_to(:has_password?)
      end
      
      it "should return true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end
      
      it "should return false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end
    end
    
    describe "authenticate method" do
      
      it "should exist" do
        User.should respond_to(:authenticate)
      end
      
      it "should return nil on email/password mismatch" do
        User.authenticate(@attr[:email], "invalid").should be_nil
      end
      
      it "should return nil for an email address with no user" do
        User.authenticate("bar@foo.com", @attr[:password]).should be_nil
      end
      
      it "should return the user on email/password match" do
        User.authenticate(@attr[:email], @attr[:password]).should == @user
      end
    end
  end
  
  # Chapt 10.4
  describe "admin attribute" do
    
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should respond to admin" do
      @user.should respond_to(:admin)
    end
    
    it "should not be an admin by default" do
      # @user.admin?.should_not be_true
      # ----------- OR ------------
      @user.should_not be_admin   # be_admin works since db.admin is boolean
    end
    
    it "should be convertible to an admin" do
      # @user.admin = true
      # ----------- OR ------------
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end
  
  # Chapt 11.1.2
  describe "micropost associations" do
    
    before(:each) do
      @user = User.create(@attr)
      # Chapt 11.1.3
      # Since the created_at fields are 'Magic' fields, they are not
      # normally modifiable, however remember that this is not 'real'
      # data, but is data provided by Factory_Girl, which does allow
      # this type of bulk write/ modifiable facility.
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end
    
    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end
    
    it "should have the right microposts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end
    
    # Chapt 11.1.3
    it "should destroy associated microposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        lambda do
          Micropost.find(micropost)
        end.should raise_error(ActiveRecord::RecordNotFound)
        # There are two ways to complete this test. The method
        # used above includes a Lamba block that tests to see
        # if an error has been raised. The second way is to 
        # user find_by_id, which should be nil.  To use the
        # second method, replace the entire lambda block with
        # the following single line of code.
        # -- Micropost.find_by_id(micropost.id).should be_nil
      end
    end
      
    # Chapt 11.3.3
    describe "status feed" do
      
      it "should have a feed" do
        @user.should respond_to(:feed)
      end
      
      it "should include user's microposts" do
        @user.feed.should include(@mp1)
        @user.feed.should include(@mp2)
      end
      
      it "should not include a different user's microposts" do
        mp3 = Factory(:micropost, 
                      :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.should_not include(mp3)
      end
    end
  end
  
  # Chapt 12.1.4
  describe "relationships" do
    before(:each) do
      @user = User.create!(@attr)
      @followed = Factory(:user)
    end
    
    it "should have a relationships method" do
      @user.should respond_to(:relationships)
    end
    
    it "should have a following method" do
      @user.should respond_to(:following)
    end
    
    it "should follow another user" do
      @user.follow!(@followed)
      @user.should be_following(@followed)
    end
    
    it "should include the followed user in the following array" do
      @user.follow!(@followed)
      @user.following.should include(@followed)
    end
    
    it "should have an unfollow! method" do
      @user.should respond_to(:unfollow!)
    end
    
    # Chapt 12.1.4
    it "should unfollow a user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end
    
    # Chapt 12.1.4
    it "should have a reverse relationships method" do
      @user.should respond_to(:reverse_relationships)
    end
    
    # Chapt 12.1.4
    it "should have a followers method" do
      @user.should respond_to(:followers)
    end
    
    # Chapt 12.1.4
    it "should include the follower in the followers array" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
    end
  end
end
