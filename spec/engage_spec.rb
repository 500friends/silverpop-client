require 'spec_helper'
require 'oauth2'

describe Silverpop::Engage do

  before :all do
    token = 'test_token'
    @connection = Silverpop::Client.new_connection(token)
    @request = Silverpop::Engage.new(@connection)
  end

  describe "#schedule_mailing" do
    it "should send a template-based mailing to a specific list" do
      stub_engage_post("?access_token=test_token").
          with(:body => fixture("schedule_mailing_request.xml")).
          to_return(:status => 200, :body => fixture("schedule_mailing_response.xml"), :headers => {'Content-type' => "text/xml"})
      options = {
          send_html: nil,
          send_aol: nil,
          send_text: nil,
          subject: 'This is the new subject',
          from_name: 'Senders Name',
          from_address: 'sender@domain.com',
          reply_to: 'sender@domain.com',
          visibility: Silverpop::Engage::LIST_VISIBILITY_PRIVATE,
          parent_folder_path: 'Sent Folder Name',
          create_parent_folder: nil,
          scheduled: '10/13/2011 12:00:00 AM',
          suppression_lists: [{suppression_list_id: 37782}, {suppression_list_id: 37744}],
          substitutions: [{substitution: [{name: 'Sub_Value_1'}, {value: 'The value I would like to put in my mailing.'}]},
                          {substitution: [{name: 'Sub_Value_2'}, {value: 'Another value I would like to put in my mailing.'}]}]
      }

      request = @request.schedule_mailing(1000, 100, 'New Mailing Name', options)
      request.should == fixture_content('schedule_mailing_request.xml')
    end
  end

  describe "#import_list" do
    it "should import a batch file" do
      stub_engage_post("?access_token=test_token").
          with(:body => fixture("import_list_request.xml")).
          to_return(:status => 200, :body => fixture("import_list_response.xml"), :headers => {'Content-type' => "text/xml"})
      map_file = 'list_import_map.xml'
      source_file = 'list_create.csv'

      request = @request.import_list(map_file, source_file)
      request.should == fixture_content('import_list_request.xml')
    end
  end

  describe "#list_import" do
    it "should create a new database" do
      columns = [{name: 'EMAIL', type: Silverpop::Engage::COLUMN_TYPE_SYSTEM, is_required: true},
                 {name: 'CustID', type: Silverpop::Engage::COLUMN_TYPE_TEXT, is_required: true, key_column: true}]
      mapping = [{index: 1, name: 'EMAIL', include: true},
                 {index: 2, name: 'CustID', include: true}]

      request = @request.list_import('CREATE', 'Premier Accts', Silverpop::Engage::LIST_VISIBILITY_PRIVATE, Silverpop::Engage::FILE_TYPE_CSV, true, {}, columns, mapping)
      request.should == fixture_content('list_import_create.xml')
    end

    it "should only update the existing contacts in the database" do
      options = {sync_fields: [{sync_field: [{name: 'EMAIL'}]}, sync_field: [{name: 'Customer Id'}]]}
      mapping = [{index: 1, name: 'EMAIL', include: true},
                 {index: 2, name: 'Customer Id', include: true},
                 {index: 3, name: 'First_Name', include: true}]

      request = @request.list_import('UPDATE_ONLY', 50194, Silverpop::Engage::LIST_VISIBILITY_PRIVATE, Silverpop::Engage::FILE_TYPE_CSV, true, options, [], mapping)
      request.should == fixture_content('list_import_update_only.xml')
    end

    it "should process all contacts in the source file" do
      columns = [{name: 'EMAIL', type: Silverpop::Engage::COLUMN_TYPE_SYSTEM, is_required: true, key_column: true},
                 {name: 'CustID', type: Silverpop::Engage::COLUMN_TYPE_TEXT, is_required: true, key_column: true},
                 {name: 'Att1', type: Silverpop::Engage::COLUMN_TYPE_TEXT, is_required: false, default_value: nil},
                 {name: 'Att2', type: Silverpop::Engage::COLUMN_TYPE_TEXT, is_required: false, default_value: nil},
                 {name: 'CountryField1', type: Silverpop::Engage::COLUMN_TYPE_TEXT, is_required: false, default_value: nil},
                 {name: 'CountryField2', type: Silverpop::Engage::COLUMN_TYPE_TEXT, is_required: false, default_value: nil},
                 {name: 'DateField1', type: Silverpop::Engage::COLUMN_TYPE_DATE, is_required: false, default_value: nil}]
      mapping = [{index: 1, name: 'EMAIL', include: true},
                 {index: 2, name: 'EMAIL_TYPE', include: true},
                 {index: 3, name: 'CustID', include: true},
                 {index: 4, name: 'DateField1', include: true}]
      contact_lists = {contact_lists: [{contact_list_id: 31279}, {contact_list_id: 54564}]}

      request = @request.list_import('ADD_AND_UPDATE', 50194, Silverpop::Engage::LIST_VISIBILITY_PRIVATE, Silverpop::Engage::FILE_TYPE_CSV, true, {}, columns, mapping, contact_lists)
      request.should == fixture_content('list_import_add_and_update.xml')
    end
  end

  describe "#export_list" do
    it "should export a list" do
      stub_engage_post("?access_token=test_token").
          with(:body => fixture("export_list_request.xml")).
          to_return(:status => 200, :body => fixture("export_list_response.xml"), :headers => {'Content-type' => "text/xml"})

      options = {'ADD_TO_STORED_FILES' => nil,
                 'DATE_START' => DateTime.new(2011,7,25,12,12,11).strftime("%m/%d/%Y %H:%M:%S"),
                 'DATE_END' => DateTime.new(2011,9,30,14,14,11).strftime("%m/%d/%Y %H:%M:%S"),
                 'EXPORT_COLUMNS' => [{'COLUMN' => 'FIRST_NAME'}, {'COLUMN' => 'INITIAL'}, {'COLUMN' => 'LAST_NAME'}]}
      request = @request.export_list(59294, 'ALL', 'CSV', options)
      request.should == fixture_content('export_list_request.xml')
    end
  end

  describe "#purge_data" do
    it "should generate xml" do
      stub_engage_post("?access_token=test_token").
          with(:body => fixture("purge_data_request.xml")).
          to_return(:status => 200, :body => fixture("purge_data_response.xml"), :headers => {'Content-type' => "text/xml"})

      request = @request.purge_data(87981, 64987)
      request.should == fixture_content('purge_data_request.xml')
    end
  end

  describe "#create_table" do
    it "should generate xml" do
      columns = [{name: 'Record Id', type: 'NUMERIC', is_required: true, key_column: true},
                 {name: 'Purchase Date', type: 'DATE', is_required: true},
                 {name: 'Product Id', type: 'NUMERIC', is_required: true}]

      r = @request.create_table('Purchases', columns)
      r.should == fixture_content('create_table_request.xml')
    end
  end

  describe "#join_table" do
    it "should generate xml" do
      map_fields = [{list_field: 'ItemID', table_field: 'Item ID'},
                    {list_field: 'PurchPrice', table_field: 'Purchase Price'}]
      r = @request.join_table({:table_name => 'Shared/Web Analytics/Purchases'}, 65745, map_fields)
      r.should == fixture_content('join_table_request.xml')
    end
  end

  describe "#insert_update_relational_table" do
    it "should generate xml" do
      rows = [[{name: 'Record Id', value: 'GHbjh73643hsdiy'},
               {name: 'Purchase Date', value: '01/09/1975'},
               {name: 'Product Id', value: '123454'}],
              [{name: 'Record Id', value: 'WStfh73643hsdgw'},
               {name: 'Purchase Date', value: '02/11/1980'},
               {name: 'Product Id', value: '45789'}],
              [{name: 'Record Id', value: 'Yuhbh73643hsfgh'},
               {name: 'Purchase Date', value: '05/10/1980'},
               {name: 'Product Id', value: '4766454'}]]
      r = @request.insert_update_relational_table(86767, rows)
      r.should == fixture_content('insert_update_relational_table_request.xml')
    end
  end
end
