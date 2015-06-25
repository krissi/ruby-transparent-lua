guard :rspec,
      cmd:            'bundle exec rspec --fail-fast --color',
      all_on_start:   true,
      all_after_pass: true do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { 'spec' }
  notification :file,
               path:   '.rspec_result',
               format: '%s'
end


guard :cucumber,
      all_on_start:   true do
  watch '.rspec_result' do
    'features' if File.read('.rspec_result').strip == 'success'
  end
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$}) { 'features' }

  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) do |m|
    Dir[File.join("**/#{m[1]}.feature")][0] || 'features'
  end
end
