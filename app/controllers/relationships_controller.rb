# Chapt 12.2.4
class RelationshipsController < ApplicationController
  before_filter :authenticate
  
  def create
    # Remember that this is a good debug habit.  It will help
    # determine what params hash value might be useful
    # -- raise params.inspect
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)
    # Chapt 12.2.5 REFACTOR -- Added respond_to for Ajax support.
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
  
  def destroy
    # The following two lines work just fine, but if the goal
    # is to create this method with similar logic to the
    # create method above, an alternate solution is also provided.
    # -- relationship = Relationship.find(params[:id]).destroy
    # -- redirect_to relationship.followed
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    respond_to do |format|
      format.html{ redirect_to @user }
      format.js
    end
  end
end