module CopyCouch
  def self.included(base)
    base.property :copycouch_log do |replication_metadata|
      replication_metadata.property :replicated_on, Time
      replication_metadata.property :replicated_to, String
      replication_metadata.property :replicated_revision, String
    end
  end

  def replicated?
    !self.copycouch_log.empty?
  end

  def last_replicated_revision
    self.copycouch_log.last.replicated_revision
  end

  def last_replicated_to
    self.copycouch_log.last.replicated_to
  end

  def last_replicated_on
    self.copycouch_log.last.replicated_on
  end

  def replicate(target, create_target = false, &updates_after_replication)
    raise StandardError, "You may not replicate new (unsaved) documents" if self.new?
      
    RestClient.post(
      "#{self.database.server.uri}/_replicate", 
      {
        :source =>        self.database.name, 
        :target =>        target.root, 
        :create_target => create_target,
        :doc_ids =>       [self.id]
      }.to_json,
      :content_type => :json,
      :accept => :json
    )

    self.copycouch_log << {:replicated_on => Time.now, :replicated_to => target.root.gsub(%r{http://[^:]*:[^\@]*\@}, ""), :replicated_revision => self.rev}
    updates_after_replication.call(self) if updates_after_replication
    self.save!
  end
end
