# frozen_string_literal: true

begin
  require 'rubocop/rake_task'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  RuboCop::RakeTask.new

  task lint: :rubocop
  task fix: 'rubocop:autocorrect'

  task default: :spec
rescue LoadError
  # ok on production
end
