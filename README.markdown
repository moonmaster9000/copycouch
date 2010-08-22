# Introduction

A mixin for adding per-document replication to your CouchRest::Model::Base objects.

# Installation

    $ gem install copycouch

# Usage

First, mix CopyCouch into your CouchRest::Model::Base derived class: 
    
    COUCH_SERVER = CouchRest.new "http://my.cms.couch.instance"
    CMS_DATABASE = COUCH_SERVER.database! 'library'

    class Book < CouchRest::Model::Base
      include CopyCouch
      use CMS_DATABASE
  
      property :name
    end

Next, create a document.

    @book = Book.create :name => "2001: A Space Odyssey"

Next, replicte it!

    PRODUCTION_COUCH_SERVER = CouchRest.new "http://my.production.couch.instance"
    PRODUCTION_DATABASE = PRODUCTION_COUCH_SERVER.database! 'library'

    @book.replicate PRODUCTION_DATABASE

Now it's replicated. After replication, CopyCouch logged some stuff in your document.

    puts @book.last_replicated_to #==> "http://my.production.couch.instance/library"
    puts @book.last_replicated_revision #==> 1-jkfdlsau94302894032840293
    puts @book.last_replicated_on #==> Sun Aug 22 18:41:57 -0400 2010

You could also find that information under `@book.copycouch_log`
