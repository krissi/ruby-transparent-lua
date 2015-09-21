Feature: Special methods

  Scenario: Calling a predicate method from Lua
    Given an empty sandbox
    And the following method definition as part of the sandbox: def test?; true; end;
    And the following line as Lua script: return(test_huh);
    When I execute the script
    Then it should return true
