Feature: Replicate a single document to a target database
  As a systems architect
  I want to replicate single documents between databases
  So that I can design a push-publishing system.

  Scenario: Attempting to replicate an unsaved document should fail
    When I try to replicate a new (unsaved) document
    Then I should recieve an exception message informing that I am not allowed to do that
  
  @run
  Scenario: Replication
    Given I have several documents in my source database
    And I have no documents in my target database
    When I replicate a single document to the target database
    Then that document should appear in the target database
    But none of the other documents should have been replicated

  Scenario: Capturing last version replicated 
    Given a document in my source database
    When I replicate it to the target database
    Then the document in the source database should contain information about which version was replicated
    And the document in the source database should contain information about when it was replicated
    And the document in the source database should contain information about where it was replicated to
    And the document in the source database should contain all custom updates I requested after replication
