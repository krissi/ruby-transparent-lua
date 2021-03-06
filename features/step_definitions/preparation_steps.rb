require 'transparent_lua'

Given(/^an empty sandbox$/) do
  @sandbox_class = Class.new do
    def inspect
      '#<Empty Sandbox Class>'
    end

    alias :to_s :inspect
  end
end

Given(/^an? sandbox with an empty member class$/) do
  @member_class = Class.new do
    def inspect
      '#<Sandbox Member Class>'
    end

    alias :to_s :inspect
  end

  @sandbox_class = Class.new do
    def inspect
      '#<Sandbox Class>'
    end

    alias :to_s :inspect
  end

  @sandbox_class.class_exec(@member_class) do |member_class|
    define_method(:member_class) { member_class.new }
  end
end

And(/^the following (?:method definition as part of|code executed in) the sandbox: ?(.*)$/) do |*args|
  inline_code, text_code = *args
  code = String(text_code).empty? ? String(inline_code) : String(text_code)
  @sandbox_class.class_eval(code)
end

And(/^the following method definition as part of the member class: (.*)$/) do |method_definition|
  @member_class.class_eval(method_definition)
end

And(/^the following line as Lua script: (.*)$/) do |script|
  @script = String(script).strip
end

And(/^the following Lua script:$/) do |script|
  @script = String(script).strip
end

