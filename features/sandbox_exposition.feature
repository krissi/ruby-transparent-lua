Feature: Sandbox exposition

  Scenario: Exposing sandbox getters to the lua script
    Given an empty sandbox
    And the following method definition as part of the sandbox: def meth; 'OK'; end;
    And the following line as Lua script: return(meth);
    When I execute the script
    Then it should return "OK"

  Scenario Outline: Exposing member class methods to the lua script
    Given a sandbox with an empty member class
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

  Scenario: Calling Lua functions
    Given an empty sandbox
    And the following line as Lua script: return(string.upper('Hello'));
    When I execute the script
    Then it should return "HELLO"

  Scenario: Setting attributes of members
    Given an empty sandbox
    And the following code executed in the sandbox: def struct; @struct ||= Struct.new(:attr).new; end
    And the following Lua script:
    """
    s = struct
    s.attr = 'Hi'
    """
    When I execute the script
    Then the result of @sandbox.struct.values should include('Hi')

  Scenario: Passing instances to methods as arguments
    Given a sandbox with an empty member class
    And the following code executed in the sandbox: def ret(param); param.inspect; end
    And the following Lua script:
    """
    return(ret(member_class));
    """
    When I execute the script
    Then it should return "#<Sandbox Member Class>"

  Scenario: Passing plain lua tables to methods as arguments
    Given an empty sandbox
    And the following code executed in the sandbox: def ret(param); param.inspect; end
    And the following Lua script:
    """
    return(ret({foo = "bar"}));
    """
    When I execute the script
    Then it should return {'foo' => 'bar'}.inspect

  Scenario: Requiring virtual files
    Given an empty sandbox
    And the following code executed in the sandbox:
    """
      def can_require_module?(modname)
        modname == 'virtual_module'
      end

      def require_module(modname)
        <<-EOMOD
          function virtual_function()
            return('Virtual return value')
          end
        EOMOD
      end
    """
    And the following Lua script:
    """
    require('virtual_module');
    return(virtual_function());
    """
    When I execute the script
    Then it should return "Virtual return value"


