describe "hyrax/admin/stats/show.html.erb", type: :view do
  require 'rspec/expectations'
  include RSpecHtmlMatchers

  # controller.request.path_parameters[:controller] == "hyrax/admin/stats"
  let(:presenter) do
    Hyrax::AdminStatsPresenter.new({}, 5)
  end
  let(:user) { stub_model(User, user_key: 'jane@example.edu') }
  let(:recent_users) do
    users = []
    (1..4).each do |i|
      users << stub_model(User, user_key: "user-#{i.to_s}@example.edu", name: "User #{i}", created_at: Time.now, department: 'Potions')
    end
    users
  end
  let(:depositors) do
    depositors = []
    count = 6
    recent_users.each do |user|
      depositors << { user: user, depositors: count }
      count = count + 3
    end
    depositors
  end

  before do
    allow(view).to receive(:params).and_return({})
    allow(view).to receive(:signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
    assign(:user, user)
    assign(:presenter, presenter)
    allow(presenter).to receive(:works_count).and_return({ :total => 15, :registered => 10, :private => 5 })
    allow(presenter).to receive(:top_formats).and_return([])
    allow(presenter).to receive(:depositors).and_return([])
    #{ key: key, deposits: deposits, user: user }
    allow(presenter).to receive(:active_users).and_return([])
    #app/services/hyrax/statistics/term_query.rb:15:in `query'
    assign(:recent_users, recent_users)
    assign(:depositors, depositors)
  end

  it "renders _stats_by_date partial" do
    # assign(:params, {})
    render
    expect(view).to render_template(:partial => "_stats_by_date", :count => 1)
  end

  it "renders _top_data partial" do
    # assign(:params, {})
    render
    expect(view).to render_template(:partial => "_top_data", :count => 1)
  end

  it "renders _works partial" do
    # assign(:params, {})
    render
    expect(view).to render_template(:partial => "_works", :count => 1)
  end

  it "renders _deposits partial" do
    # assign(:params, {})
    render
    expect(view).to render_template(:partial => "_deposits", :count => 1)
  end

  it "renders _new_users partial" do
    # assign(:params, {})
    render
    expect(view).to render_template(:partial => "_new_users", :count => 1)
  end

  context "in _new_user partial" do
    before do
      allow(presenter).to receive(:recent_users).and_return(recent_users)
    end

    it "correctly escapes user_key" do
      render
      recent_users.each do |user|
        # user_url = url_for( only_path: true, controller: '/hyrax/users', action: :show, id: user.to_param )
        good_url = url_for("/users/#{user.to_param}")
        expect(rendered).to have_tag('ul') do
          with_tag 'a', :with => { :href => good_url }, text: user.name
        end
      end
    end

    it "no longer incorrectly escapes user_key" do
      render
      recent_users.each do |user|
        # user_url = url_for( only_path: true, controller: '/hyrax/users', action: :show, id: user.to_param )
        bad_url = url_for("/users/#{user.user_key}")
        expect(rendered).not_to have_tag( 'a', :with => { :href => bad_url } )
      end
    end
  end

  context "in _deposits partial" do
    before do
      allow(presenter).to receive(:depositors).and_return(depositors)
    end

    it "correctly escapes user_key" do
      render
      recent_users.each do |user|
        # user_url = url_for( only_path: true, controller: '/hyrax/users', action: :show, id: user.to_param )
        good_url = url_for("/users/#{user.to_param}")
        expect(rendered).to have_tag('ul') do
          with_tag 'a', :with => { :href => good_url }, text: user.name
        end
      end
    end

    it "no longer incorrectly escapes user_key" do
      render
      recent_users.each do |user|
        # user_url = url_for( only_path: true, controller: '/hyrax/users', action: :show, id: user.to_param )
        bad_url = url_for("/users/#{user.user_key}")
        expect(rendered).not_to have_tag( 'a', :with => { :href => bad_url } )
      end
    end
  end

end
