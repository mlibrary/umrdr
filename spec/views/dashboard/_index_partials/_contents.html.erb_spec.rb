require 'rails_helper'

describe "dashboard/_index_partials/_contents.html.erb"  do

  it "returns present activity status" do
    assign(:activity, [])

    allow(view).to receive(:render_recent_notifications) { 'no recent notifications' }
    allow(view).to receive(:link_to_additional_notifications) { 'no additional notifications' }

    render
    
    expect(rendered).to include("no recent activity")
    expect(rendered).to include("no recent notifications")
    expect(rendered).to include("no additional notifications")
  end

end