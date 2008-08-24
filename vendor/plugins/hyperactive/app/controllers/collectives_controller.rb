class CollectivesController < ApplicationController

  layout "two_column"
  
  # security
  #
  before_filter :can_edit?, :only => [:edit, :update, :edit_memberships, :add_membership]
  before_filter :can_destroy_membership?, :only => [:destroy_membership]
  before_filter :can_destroy?, :only => [:destroy]  
  
  uses_tiny_mce(:options => {:theme => 'advanced',
                           :browsers => %w{msie gecko safari opera},
                           :theme_advanced_toolbar_location => "top",
                           :theme_advanced_toolbar_align => "left",
                           :theme_advanced_statusbar_location => "bottom",
                           :theme_advanced_resizing => true,
                           :theme_advanced_resize_horizontal => false,
                           :theme_advanced_resizing_use_cookie => true,
                           :paste_auto_cleanup_on_paste => true,
                           :theme_advanced_buttons1 => %w{undo redo separator bold italic underline strikethrough separator bullist numlist separator link unlink separator cleanup code},
                           :theme_advanced_buttons2 => [],
                           :theme_advanced_buttons3 => [],
                           :plugins => %w{paste cleanup}},
              :only => [:new, :edit, :create, :update])   
  
  # GET /collectives
  # GET /collectives.xml
  def index
    @new_collectives = Collective.find(:all)
    #@recently_active_collectives
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @collectives.to_xml }
    end
  end

  # GET /collectives/1
  # GET /collectives/1.xml
  def show
    @collective = Collective.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @collective.to_xml }
    end
  end

  # GET /collectives/new
  def new
    @collective = Collective.new
  end

  # GET /collectives/1;edit
  def edit
    @collective = Collective.find(params[:id])
  end

  # POST /collectives
  # POST /collectives.xml
  def create
    @collective = Collective.new(params[:collective])

    respond_to do |format|
      if @collective.save
        flash[:notice] = 'Group was successfully created.'
        format.html { redirect_to collective_url(@collective) }
        format.xml  { head :created, :location => collective_url(@collective) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @collective.errors.to_xml }
      end
    end
  end

  # PUT /collectives/1
  # PUT /collectives/1.xml
  def update
    @collective = Collective.find(params[:id])

    respond_to do |format|
      if @collective.update_attributes(params[:collective])
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to account_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @collective.errors.to_xml }
      end
    end
  end

  # DELETE /collectives/1
  # DELETE /collectives/1.xml
  def destroy
    @collective = Collective.find(params[:id])
    @collective.destroy

    respond_to do |format|
      format.html { redirect_to collectives_url }
      format.xml  { head :ok }
    end
  end
  
  def edit_memberships
    @collective = Collective.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @collective.to_xml }
    end
  end
  
  def destroy_membership
    @collective_membership = CollectiveMembership.find(params[:id])
    @collective = @collective_membership.collective
    @collective_membership.destroy
     respond_to do |format|
      format.html { redirect_to edit_collective_memberships_url(@collective) }
      format.xml  { head :ok }
    end
  end
  
  def add_membership
    @collective = Collective.find(params[:id])
    @user = User.find_by_login(params[:login])
    if @user
      @collective.users << @user 
      respond_to do |format|
        flash[:notice] = "User '#{@user.login}' was added to '#{@collective.name}'"
        format.html { redirect_to edit_collective_memberships_url }
        format.xml  { head :ok }
      end
    else
      respond_to do |format|
        flash[:notice] = "User '#{params[:login]}' not found."
        format.html { redirect_to edit_collective_memberships_url }
        format.xml  { head :ok }
      end
    end
  end
  
  protected
  
  # Checks membership to see if a given user can edit this collective.
  #
  def can_edit?
    return true if current_user.is_member_of?(Collective.find(params[:id]))
    #return true if current_user.has_permission?("edit_own_content")  && Content.find(params[:id]).user == current_user
    security_error
  end  
  
  # Checks membership to see if a given user can destroy memberships in this collective.
  # It works a little differently from the 'can_edit?' filter because in this case 
  # params[:id] is the id of the CollectiveMembership, not that id of the collective.
  #
  def can_destroy_membership?
    return true if CollectiveMembership.find(params[:id]).collective.users.include?(current_user)
    security_error
  end
  
  # Checks permissions to see if the current user can destroy a collective.
  #
  def can_destroy?
    return true if current_user.has_permission?("destroy")  
    security_error
  end  
  
end