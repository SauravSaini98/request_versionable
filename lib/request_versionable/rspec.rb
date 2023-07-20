if defined?(RSpec)
  require 'rspec/expectations'

  # Validate the subject's class did call "acts_as_paranoid"
  RSpec::Matchers.define :save_record_histories do
  end

end
