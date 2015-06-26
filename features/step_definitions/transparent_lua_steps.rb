When(/^I execute the script$/) do
  @transparent_lua = TransparentLua.new(@sandbox = @sandbox_class.new)

  @return_value = @transparent_lua.call(@script)
end

When(/^I execute the script with locales leaking enabled$/) do
  @transparent_lua = TransparentLua.new(@sandbox = @sandbox_class.new, leak_globals: true)

  @return_value = @transparent_lua.call(@script)
end
