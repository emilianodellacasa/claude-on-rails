# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Git MCP Integration' do
  describe 'Git prompt template' do
    let(:git_prompt_path) do
      File.join(
        File.dirname(__FILE__),
        '../../lib/generators/claude_on_rails/swarm/templates/prompts/git.md'
      )
    end

    it 'exists and contains expected content' do
      expect(File.exist?(git_prompt_path)).to be true

      content = File.read(git_prompt_path)
      expect(content).to include('Git Repository Management Specialist')
      expect(content).to include('git_status')
      expect(content).to include('git_commit')
      expect(content).to include('git_branch')
      expect(content).to include('conventional commit format')
      expect(content).to include('Pre-commit Checks')
      expect(content).to include('Security Considerations')
    end

    it 'includes all expected Git MCP tools' do
      content = File.read(git_prompt_path)

      %w[
        git_status git_log git_show git_blame
        git_branch git_checkout git_merge git_reset
        git_diff git_commit git_stash
        git_push git_pull git_tag
      ].each do |tool|
        expect(content).to include(tool)
      end
    end

    it 'provides comprehensive Git workflow guidance' do
      content = File.read(git_prompt_path)

      expect(content).to include('Starting New Feature')
      expect(content).to include('Preparing Commits')
      expect(content).to include('Code Review Support')
      expect(content).to include('Release Preparation')
      expect(content).to include('Integration with Rails Development')
      expect(content).to include('Troubleshooting Common Issues')
      expect(content).to include('Collaboration Guidelines')
    end

    it 'includes security best practices' do
      content = File.read(git_prompt_path)

      expect(content).to include('Never commit sensitive information')
      expect(content).to include('Review diffs before pushing')
      expect(content).to include('.gitignore')
      expect(content).to include('audit repository')
    end
  end

  describe 'ERB template integration' do
    let(:swarm_template_path) do
      File.join(
        File.dirname(__FILE__),
        '../../lib/generators/claude_on_rails/swarm/templates/swarm.yml.erb'
      )
    end

    it 'includes Git MCP server configuration section' do
      expect(File.exist?(swarm_template_path)).to be true

      content = File.read(swarm_template_path)
      expect(content).to include('<% if @include_git_mcp %>')
      expect(content).to include('- name: git')
      expect(content).to include('command: git-mcp-server')
      expect(content).to include('GIT_REPO_PATH:')
    end

    it 'includes Git agent configuration section' do
      content = File.read(swarm_template_path)
      expect(content).to include('git:')
      expect(content).to include('Git repository management, version control, and collaboration specialist')
      expect(content).to include('prompt_file: .claude-on-rails/prompts/git.md')
    end
  end

  describe 'architect prompt integration' do
    let(:architect_prompt_path) do
      File.join(
        File.dirname(__FILE__),
        '../../lib/generators/claude_on_rails/swarm/templates/prompts/architect.md'
      )
    end

    it 'includes Git specialist in team description' do
      expect(File.exist?(architect_prompt_path)).to be true

      content = File.read(architect_prompt_path)
      expect(content).to include('**Git**: Version control, repository management, collaboration (when available)')
    end
  end
end
