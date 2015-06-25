Feature: Sandbox exposition

  Scenario: Exposing sandbox getters to the lua script
    Given an empty sandbox
    And the following method definition as part of the sandbox: def meth; 'OK'; end;
    And the following line as Lua script: return(meth);
    When I execute the script
    Then it should return "OK"

  Scenario Outline: Exposing member class methods to the lua script
    Given an sandbox with an empty member class
    And the following method definition as part of the member class: def <method_signature>; <method_body>; end;
    And the following line as Lua script: return(<method_call>);
    When I execute the script
    Then it should return "OK"
    Examples:
      | method_signature      | method_body             | method_call               |
      | meth                  | 'OK'                    | member_class.meth         |
      | meth(arg1, arg2)      | [arg1, arg2].pack("U*") | member_class.meth(79, 75) |
      | meth(arg1, arg2 = 75) | [arg1, arg2].pack("U*") | member_class.meth(79)     |
      | meth(*args)           | 'OK'                    | member_class.meth()       |
      | meth(*)               | 'OK'                    | member_class.meth()       |

  Scenario: Returning values
    Given an empty sandbox
    And the following line as Lua script: return('Hello');
    When I execute the script
    Then it should return "Hello"

  Scenario Outline: Returning values
    Given an empty sandbox
    And the following line as Lua script: return(<lua_value>);
    When I execute the script
    Then it should return <return_value>
    Examples:
      | lua_value           | return_value     |
      | 5                   | 5                |
      | 5.1                 | 5.1              |
      | "Hallo"             | "Hallo"          |
      | { ["Foo"] = "Bar" } | {"Foo" => "Bar"} |
      | {"A", "B", "C"}     | ['A', 'B', 'C']  |
      | true                | true             |

  Scenario Outline: Passing values to methods
    Given an empty sandbox
    And the following method definition as part of the sandbox: attr_accessor :attrib
    And the following line as Lua script: attrib = <lua_value>
    When I execute the script with locales leaking enabled
    Then the attribute "attrib" of the sandbox is <return_value>
    Examples:
      | lua_value           | return_value     |
      | 5                   | 5                |
      | 5.1                 | 5.1              |
      | "Hallo"             | "Hallo"          |
      | { ["Foo"] = "Bar" } | {"Foo" => "Bar"} |
      | {"A", "B", "C"}     | ['A', 'B', 'C']  |
      | true                | true             |


