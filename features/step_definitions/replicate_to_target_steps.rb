When /^I try to replicate a new \(unsaved\) document$/ do
  @book = Book.new
end

Then /^I should recieve an exception message informing that I am not allowed to do that$/ do
  proc {@book.replicate COPYCOUCH_DEST_TEST_DB}.should raise_error(StandardError, "You may not replicate new (unsaved) documents")
end

Given /^I have several documents in my source database$/ do
  @b1 = Book.create :name => "book 1"
  @b2 = Book.create :name => "book 2"
  @b3 = Book.create :name => "book 3"
end

Given /^I have no documents in my target database$/ do
end

When /^I replicate a single document to the target database$/ do
  @b1.replicate COPYCOUCH_DEST_TEST_DB
end

Then /^that document should appear in the target database$/ do
  response = RestClient.get "#{COPYCOUCH_DEST_TEST_DB.server.uri}/#{COPYCOUCH_DEST_TEST_DB.name}/#{@b1.id}", :accept => :json
  response.code.should == 200
  JSON(response.body)["_id"].should == @b1.id
end

Then /^none of the other documents should have been replicated$/ do
  proc {RestClient.get("#{COPYCOUCH_DEST_TEST_DB.server.uri}/#{COPYCOUCH_DEST_TEST_DB.name}/#{@b2.id}", :accept => :json)}.should raise_error(RestClient::ResourceNotFound)
  proc {RestClient.get("#{COPYCOUCH_DEST_TEST_DB.server.uri}/#{COPYCOUCH_DEST_TEST_DB.name}/#{@b3.id}", :accept => :json)}.should raise_error(RestClient::ResourceNotFound)
end

Given /^a document in my source database$/ do
  @book = Book.create :name => "ruby book!"
end

When /^I replicate it to the target database$/ do
  @book.replicate(COPYCOUCH_DEST_TEST_DB) do |b|
    b.published = true
  end
end

Then /^the document in the source database should contain information about which version was replicated$/ do
  @book.last_replicated_revision.match(/^1-.*$/).should_not be_nil
end

Then /^the document in the source database should contain information about when it was replicated$/ do
  @book.last_replicated_on.class.should == Time
end

Then /^the document in the source database should contain information about where it was replicated to$/ do
  @book.last_replicated_to.should == COPYCOUCH_DEST_TEST_DB.root.gsub(%r{http://[^:]*:[^\@]*\@}, "")
end

Then /^the document in the source database should contain all custom updates I requested after replication$/ do
  @book.new?.should == false
  @book.published.should == true
end
