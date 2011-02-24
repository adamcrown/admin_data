Given /^user config has defined additional_column phone_numbers$/ do
  AdminData.config.columns_order = AdminData.config.columns_order.merge('User' => [:id, :phone_numbers])
  proc = lambda {|model| model.phone_numbers.map {|r| r.number}.join(', ') }
  AdminData.config.column_settings = AdminData.config.column_settings.merge('User' => { :phone_numbers => proc })
end

Then /^table should have additional column phone_numbers with valid data$/ do
  data = tableish('table.table tr', 'th,td')
  data[0][0].should == "Id \342\226\274"
  data[0][1].should == "Phone numbers"
  data[0][2].should == "First name"
  data[0][3].should == "Last name"
  user = User.find(data[1][0].to_i)
  assert_equal user.phone_numbers.map(&:number).join(', '),data[1][1]
end

Then /^reset columns_order and column_settings for User$/ do
  AdminData.config.columns_order = AdminData.config.columns_order.merge('User' => nil)
  AdminData.config.column_settings = AdminData.config.column_settings.merge('User' => nil)
end


Then /^I should see population_5000$/ do
  assert page.has_content?("[:population, 5000]")
end

Then /^(.*)verify that user "(.*)" is "(.*)"$/ do |async, attribute, input|
  wait_until { page.evaluate_script("jQuery.active === 0") } unless async.blank?

  page.has_xpath?("//table[@id='view_table']")
  table =  page.find(:xpath, "//table[@id='view_table']")

  counter = attribute == 'first_name' ? 2 : 3
  regex = Regexp.new(input)

  if async.blank?
    table.find(:xpath, "./tbody/tr/td[#{counter}]", :text => regex )
  else
    table.find(:xpath, "./tbody/tr/td[#{counter}]", :text => regex )
  end
end

Then /^I should see following tabular attributes:$/ do |expected_cukes_table|
  expected_cukes_table.diff!(tableish('table.table tr', 'td,th'))
end

Then /^first id of table should be of "(.*)"$/ do |first_name|
  page.should have_css("#view_table tr td a", :text => User.find_by_first_name(first_name).id.to_s)
end

Then /^I should see tabular attributes for website with custom columns order$/ do
  data = tableish('table.table tr', 'td,th').flatten
  data[0].should == "Id \342\226\274"
  data[1].should == "Created at"
  data[2].should == "Updated at"
  data[3].should == "Url"
  data[4].should == "User"
  data[5].should == "Dns provider"
end

Then /^I should see tabular attributes for city with custom column headers$/ do
  data = tableish('table.table tr', 'td,th').flatten
  data[0].should == "Id"
  data[1].should == "Custom column header"
  data[2].should == "City info"
  data[3].should == "Created at"
  data[4].should == "Updated at"
end
