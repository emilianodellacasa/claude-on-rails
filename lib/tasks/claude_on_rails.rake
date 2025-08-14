# frozen_string_literal: true

namespace :claude_on_rails do
  desc 'Setup Rails MCP Server for enhanced documentation access'
  task setup_mcp: :environment do
    require 'claude_on_rails/mcp_installer'
    ClaudeOnRails::MCPInstaller.new.run
  end

  desc 'Check Rails MCP Server status and available resources'
  task mcp_status: :environment do
    if ClaudeOnRails::MCPSupport.available?
      puts '✓ Rails MCP Server is installed'

      downloaded = ClaudeOnRails::MCPSupport.downloaded_resources
      missing = ClaudeOnRails::MCPSupport.missing_resources

      if downloaded.any?
        puts "\nDownloaded resources:"
        downloaded.each { |resource| puts "  ✓ #{resource}" }
      end

      if missing.any?
        puts "\nMissing resources:"
        missing.each { |resource| puts "  ✗ #{resource}" }
        puts "\nRun 'bundle exec rake claude_on_rails:setup_mcp' to download missing resources."
      else
        puts "\n✓ All resources are downloaded"
      end
    else
      puts '✗ Rails MCP Server is not installed'
      puts "\nRun 'bundle exec rake claude_on_rails:setup_mcp' to install and configure it."
    end
  end

  desc 'Check Git MCP Server status and repository information'
  task git_status: :environment do
    if ClaudeOnRails::GitMCPSupport.available?
      puts '✓ Git MCP Server is installed'
    else
      puts '✗ Git MCP Server is not installed'
      puts "\nRun 'bundle exec rake claude_on_rails:setup_git_mcp' to install it."
    end

    if ClaudeOnRails::GitMCPSupport.git_repo_available?
      puts '✓ Git repository detected'
      status = ClaudeOnRails::GitMCPSupport.repo_status
      puts "\nRepository status:"
      puts "  • Clean: #{status[:clean] ? 'Yes' : 'No'}"
      puts "  • Staged files: #{status[:has_staged] ? 'Yes' : 'No'}"
      puts "  • Unstaged changes: #{status[:has_unstaged] ? 'Yes' : 'No'}"
      puts "  • Untracked files: #{status[:has_untracked] ? 'Yes' : 'No'}"
    else
      puts '✗ No Git repository found'
      puts "\nRun 'git init' to initialize a repository."
    end
  end
end
