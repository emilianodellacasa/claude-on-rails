# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'README Documentation' do
  let(:readme_path) { File.join(File.dirname(__FILE__), '../../README.md') }
  let(:readme_content) { File.read(readme_path) }

  it 'exists' do
    expect(File.exist?(readme_path)).to be true
  end

  describe 'Git MCP Server documentation' do
    it 'includes Git agent in the team description' do
      expect(readme_content).to include('- **Git**: Manages version control and repository collaboration (when enabled)')
    end

    it 'mentions Git MCP Server in installation instructions' do
      expect(readme_content).to include('Git MCP Server for repository management')
    end

    it 'includes Git MCP Server setup in the feature list' do
      expect(readme_content).to include('Optionally set up Git MCP Server for repository management')
    end

    it 'has a dedicated Git MCP Server section' do
      expect(readme_content).to include('## Git Repository Management with Git MCP Server')
    end

    it 'documents Git MCP Server benefits' do
      expect(readme_content).to include('Version Control Operations')
      expect(readme_content).to include('Code History Analysis')
      expect(readme_content).to include('Branch Management')
      expect(readme_content).to include('Release Management')
      expect(readme_content).to include('Collaboration Support')
    end

    it 'includes setup instructions for Git MCP Server' do
      expect(readme_content).to include('bundle exec rake claude_on_rails:setup_git_mcp')
    end

    it 'documents status checking commands' do
      expect(readme_content).to include('bundle exec rake claude_on_rails:git_status')
      expect(readme_content).to include('bundle exec rake claude_on_rails:repo_info')
    end

    it 'lists available Git operations' do
      expect(readme_content).to include('git_status')
      expect(readme_content).to include('git_log')
      expect(readme_content).to include('git_branch')
      expect(readme_content).to include('git_checkout')
      expect(readme_content).to include('git_merge')
      expect(readme_content).to include('git_commit')
      expect(readme_content).to include('git_push')
      expect(readme_content).to include('git_pull')
      expect(readme_content).to include('git_tag')
    end

    it 'includes Git examples in usage section' do
      expect(readme_content).to include('Commit these changes and create a release branch')
      expect(readme_content).to include('Review the commit history for the user model changes')
      expect(readme_content).to include('[Git agent handles version control and branching]')
      expect(readme_content).to include('[Git agent analyzes repository history and provides insights]')
    end

    it 'mentions Git workflow in examples section' do
      expect(readme_content).to include('Git workflow management and collaboration')
    end

    it 'acknowledges Git MCP Server in acknowledgments' do
      expect(readme_content).to include('Supports Git repository management through Git MCP Server')
    end
  end

  describe 'Integration with existing content' do
    it 'maintains Rails MCP Server documentation' do
      expect(readme_content).to include('Enhanced Documentation with Rails MCP Server')
      expect(readme_content).to include('bundle exec rake claude_on_rails:mcp_status')
    end

    it 'maintains existing team structure' do
      expect(readme_content).to include('- **Architect**: Coordinates development')
      expect(readme_content).to include('- **Models**: Handles ActiveRecord')
      expect(readme_content).to include('- **Controllers**: Manages routing')
      expect(readme_content).to include('- **Views**: Creates UI templates')
      expect(readme_content).to include('- **Services**: Implements business logic')
      expect(readme_content).to include('- **Tests**: Ensures comprehensive test coverage')
      expect(readme_content).to include('- **DevOps**: Handles deployment and infrastructure')
    end

    it 'maintains requirements section' do
      expect(readme_content).to include('## Requirements')
      expect(readme_content).to include('Ruby 2.7+')
      expect(readme_content).to include('Rails 6.0+')
      expect(readme_content).to include('claude-swarm')
    end
  end

  describe 'structure and formatting' do
    it 'has proper markdown headers' do
      expect(readme_content).to include('# ClaudeOnRails')
      expect(readme_content).to include('## How It Works')
      expect(readme_content).to include('## Installation')
      expect(readme_content).to include('## Usage')
    end

    it 'includes code blocks for commands' do
      expect(readme_content).to include('```bash')
      expect(readme_content).to include('bundle exec rake')
      expect(readme_content).to include('```ruby')
      expect(readme_content).to include("gem 'claude-on-rails'")
    end

    it 'has proper section ordering' do
      git_section_pos = readme_content.index('## Git Repository Management with Git MCP Server')
      rails_section_pos = readme_content.index('Enhanced Documentation with Rails MCP Server')
      requirements_pos = readme_content.index('## Requirements')

      expect(git_section_pos).to be > rails_section_pos
      expect(requirements_pos).to be > git_section_pos
    end
  end
end
