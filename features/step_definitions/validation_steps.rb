Then(/^it should return (.*)$/) do |expected_return_value|
  expected_return_value = eval(expected_return_value)
  expect(@return_value).to eq(expected_return_value)
end


Then(/^the attribute "([^"]*)" of the sandbox is (.*)$/) do |attribute, expected_return_value|
  expected_return_value = eval(expected_return_value)

  expect(@sandbox.public_send(attribute.to_sym)).to eq(expected_return_value)
end
