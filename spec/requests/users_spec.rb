require 'spec_helper'

describe "Users" do
  
  describe "signup" do
    
    describe "failure" do
      
      it "should not make a new user" do
        lambda do
          visit signup_path
          fill_in "Name",         :with => ""
          fill_in "Email",        :with => ""
          fill_in "Password",     :with => ""
          fill_in "Confirmation", :with => ""
          click_button
          response.should render_template('users/new')
          response.should have_selector('div#error_explanation')
        end.should_not change(User, :count)
      end
    end
    
    describe "success" do
      
      it "should make a new user" do
        lambda do
          visit signup_path
          fill_in "Name",         :with => "Little Bo-Peep"
          fill_in "Email",        :with => "lbp@grimes.com"
          fill_in "Password",     :with => "foobar"
          fill_in "Confirmation", :with => "foobar"
          click_button
          response.should have_selector('div.flash.success')
          response.should render_template('users/show')
        end.should change(User, :count).by(1)
      end
    end
    
    describe "sign in/out" do
      
      describe "failure" do
        
        it "should not sign a user in" do
          visit signin_path
        end
      end
    end
  end
end
