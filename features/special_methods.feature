Feature: Special methods

  Scenario: Calling a predicate method from Lua
    Given an empty sandbox
    And the following method definition as part of the sandbox: def truthy?; true; end;
    And the following line as Lua script: return(is_truthy);
    When I execute the script
    Then it should return true

  Scenario: Calling a predicate method from Lua
    Given an empty sandbox
    And the following method definition as part of the sandbox: def has_skill?; true; end;
    And the following line as Lua script: return(has_skill);
    When I execute the script
    Then it should return true
