module ContentControllerTest
  
  def test_list
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:content)
    assert_equal 6, assigns(:content).size
  end  
  
  # There is one fixture with a promoted event.
  def test_list_promoted
    get :list_promoted
    assert_response :success
    assert_template 'list_promoted'
    assert_not_nil assigns(:content)
    assert_equal 2, assigns(:content).size
  end

  def test_a_show
    get :show, {:id => @first_id}
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:content)
    assert assigns(:content).valid?
    assert_no_match(/Hide this event/, @response.body, "Unhidden event shouldn't show hiding controls if user not logged in.")
  end
  
  def test_a_show_as_admin
    get :show, {:id => @first_id}, as_admin
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:content)
    assert assigns(:content).valid?
    assert_match(/Hide this event/, @response.body, "Unhidden event should show hiding controls.")
  end  
  
  def test_a_show_hidden
    get :show, {:id => @hidden_id}
    assert_no_match(/Unhide this event/, @response.body)
    assert_match(/This event has been hidden/, @response.body)
  end
  
  def test_a_show_hidden_as_admin
    get :show, {:id => @hidden_id}, as_admin
    assert_match(/This event has been hidden/, @response.body)
    assert_match(/Unhide this event/, @response.body)
  end  

  def test_new
    get :new
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:content)
  end
  
  def test_create
    num_content = model_class.count
    post :create, :content => {
                              :title => "Test content",
                              :date => DateTime.new(2007,1,1),
                              :body => "This is a test",
                              :published_by => "Yoss", 
                              :place => "London" 
                            }, 
                  :tags => "foo bar",
                  :place_tags => ""
    
    content = model_class.find_by_title("Test content")
    assert_match("foo", content.tag_list)
    assert_match("bar", content.tag_list)
    if model_class == Event
      assert content.taggings.map(&:event_date).include?(content.date)
    end
    assert_response :redirect
    assert_redirected_to :action => 'show'
    assert_equal num_content + 1, model_class.count
  end  
  
  
end