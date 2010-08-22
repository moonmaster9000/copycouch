require 'spec/expectations'
$LOAD_PATH.unshift './lib'
require 'copycouch'

COUCHDB_SERVER            = CouchRest.new "http://admin:password@localhost:5984"
COPYCOUCH_SOURCE_TEST_DB  = COUCHDB_SERVER.database!('copycouch_source_test')
COPYCOUCH_DEST_TEST_DB    = COUCHDB_SERVER.database!('copycouch_dest_test')

class Book < CouchRest::Model::Base
  include CopyCouch
  use_database COPYCOUCH_SOURCE_TEST_DB
  
  property :name
  property :published, TrueClass
  view_by :name
end

After do |scenario|
  # COPYCOUCH_SOURCE_TEST_DB.delete!
  # COPYCOUCH_DEST_TEST_DB.delete!
  # COPYCOUCH_SOURCE_TEST_DB.create!
  # COPYCOUCH_DEST_TEST_DB.create!
end
