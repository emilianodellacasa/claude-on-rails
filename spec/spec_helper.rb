# frozen_string_literal: true

require 'bundler/setup'
require 'claude_on_rails'

# Load Git MCP classes for testing
require 'claude_on_rails/git_mcp_support'
require 'claude_on_rails/git_mcp_installer'

# Load generators for testing only if Rails is available
# begin
#   require 'generators/claude_on_rails/swarm/swarm_generator'
# rescue LoadError
#   # Generator may not be available in some contexts
# end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
