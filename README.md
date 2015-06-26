# Description
This library makes it easy to provide a complex API for Lua scripts. It
uses [RLua](https://github.com/whitequark/rlua) internally and therefore it
has the same compatibility and restrictions.

# Example code
Lets say we have these classes:

```ruby
User = Struct.new(:name, :favorite_food, :age)
Food = Struct.new(:name, :cooking_time) do
  def prepare(timer)
    if timer == cooking_time
      "This #{name} is delicious"
    elsif timer > cooking_time
      "This #{name} is awfully burnt"
    else
      "Smells like frozen #{name}..."
    end
  end

  def buy(*)
    'Got one'
  end
end

Pizza   = Food.new('Pizza', 16)
Lasagne = Food.new('Lasagne', 40)

class Sandbox
  def get(username)
    users.detect { |u| u.name == username }
  end

  def users
    [
        User.new('Kyle', Pizza, 43),
        User.new('Lisa', Pizza, 25),
        User.new('Ben', Lasagne, 6),
    ]
  end
end
```
    
To make it available to our Lua script we can use this code:

```ruby
require 'transparent_lua'

tlua = TransparentLua.new(Sandbox.new)
tlua.call(<<-EOF)
      print(get_user('Kyle').name .. " likes " .. get_user('Kyle').favorite_food.name .. ".");
      print(get_user('Kyle').favorite_food.buy());
      print("It needs to cook exactly " .. get_user('Kyle').favorite_food.cooking_time .. " minutes");

      my_cooking_time = 270;
      print(get_user('Kyle').name .. " cooks it for " .. my_cooking_time .. " minutes.");
      print(get_user('Kyle').favorite_food.prepare(my_cooking_time));
EOF

Pizza.cooking_time = 270

tlua.call(<<-EOF)
      print("Lets try it again for " .. my_cooking_time .. " minutes. Maybe it works now...");

      print(get_user('Kyle').name .. " cooks it for " .. my_cooking_time .. " minutes.");
      print(get_user('Kyle').favorite_food.prepare(my_cooking_time));
EOF
```

# Types of methods
 * Methods without arguments are created as index of the Lua table
 * Methods with arguments are created as a callable metatable.
 * To make clear, that an argumentless method is a method (`food.buy()` vs. `food.buy`),
   discard any arguments (`def buy(*)`)

# Type conversion
In addition to RLuas type conversion, this library converts Lua tables to either Hashes or
Arrays (when all keys are Numeric).

