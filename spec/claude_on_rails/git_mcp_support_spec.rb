# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ClaudeOnRails::GitMCPSupport do
  describe '.available?' do
    context 'when git-mcp-server gem is installed' do
      before do
        allow(described_class).to receive(:system).with('gem list -i git-mcp-server > /dev/null 2>&1').and_return(true)
      end

      it 'returns true' do
        expect(described_class.available?).to be true
      end
    end

    context 'when git-mcp-server executable is available' do
      before do
        allow(described_class).to receive(:system).with('gem list -i git-mcp-server > /dev/null 2>&1').and_return(false)
        allow(described_class).to receive(:system).with('which git-mcp-server > /dev/null 2>&1').and_return(true)
      end

      it 'returns true' do
        expect(described_class.available?).to be true
      end
    end

    context 'when git-mcp-server is not available' do
      before do
        allow(described_class).to receive(:system).and_return(false)
      end

      it 'returns false' do
        expect(described_class.available?).to be false
      end
    end

    context 'when system command raises an error' do
      before do
        allow(described_class).to receive(:system).and_raise(StandardError)
      end

      it 'returns false' do
        expect(described_class.available?).to be false
      end
    end
  end

  describe '.git_repo_available?' do
    context 'when .git directory exists' do
      before do
        allow(File).to receive(:directory?).with('.git').and_return(true)
      end

      it 'returns true' do
        expect(described_class.git_repo_available?).to be true
      end
    end

    context 'when git command succeeds' do
      before do
        allow(File).to receive(:directory?).with('.git').and_return(false)
        allow(described_class).to receive(:system).with('git rev-parse --git-dir > /dev/null 2>&1').and_return(true)
      end

      it 'returns true' do
        expect(described_class.git_repo_available?).to be true
      end
    end

    context 'when no git repository is available' do
      before do
        allow(File).to receive(:directory?).with('.git').and_return(false)
        allow(described_class).to receive(:system).with('git rev-parse --git-dir > /dev/null 2>&1').and_return(false)
      end

      it 'returns false' do
        expect(described_class.git_repo_available?).to be false
      end
    end

    context 'when system command raises an error' do
      before do
        allow(File).to receive(:directory?).with('.git').and_return(false)
        allow(described_class).to receive(:system).and_raise(StandardError)
      end

      it 'returns false' do
        expect(described_class.git_repo_available?).to be false
      end
    end
  end

  describe '.server_config' do
    it 'returns the correct server configuration' do
      config = described_class.server_config('test')

      expect(config).to eq({
                             name: 'git',
                             type: 'stdio',
                             command: 'git-mcp-server',
                             args: [],
                             env: { 'ENVIRONMENT' => 'test' }
                           })
    end

    it 'defaults to development environment' do
      config = described_class.server_config

      expect(config[:env]).to eq({ 'ENVIRONMENT' => 'development' })
    end
  end

  describe '.usable?' do
    context 'when both server and git repo are available' do
      before do
        allow(described_class).to receive(:available?).and_return(true)
        allow(described_class).to receive(:git_repo_available?).and_return(true)
      end

      it 'returns true' do
        expect(described_class.usable?).to be true
      end
    end

    context 'when server is available but git repo is not' do
      before do
        allow(described_class).to receive(:available?).and_return(true)
        allow(described_class).to receive(:git_repo_available?).and_return(false)
      end

      it 'returns false' do
        expect(described_class.usable?).to be false
      end
    end

    context 'when git repo is available but server is not' do
      before do
        allow(described_class).to receive(:available?).and_return(false)
        allow(described_class).to receive(:git_repo_available?).and_return(true)
      end

      it 'returns false' do
        expect(described_class.usable?).to be false
      end
    end
  end

  describe '.available_tools' do
    it 'returns the list of available Git tools' do
      tools = described_class.available_tools

      expect(tools).to include('git_status', 'git_log', 'git_diff', 'git_branch')
      expect(tools).to include('git_commit', 'git_push', 'git_pull', 'git_checkout')
      expect(tools).to include('git_merge', 'git_stash', 'git_reset', 'git_tag')
      expect(tools).to include('git_blame', 'git_show')
    end
  end

  describe '.installation_instructions' do
    context 'when server is not available and no git repo' do
      before do
        allow(described_class).to receive(:available?).and_return(false)
        allow(described_class).to receive(:git_repo_available?).and_return(false)
      end

      it 'includes both installation and git init instructions' do
        instructions = described_class.installation_instructions

        expect(instructions).to include('Install Git MCP Server:')
        expect(instructions).to include('  gem install git-mcp-server --no-document')
        expect(instructions).to include('Initialize Git repository:')
        expect(instructions).to include('  git init')
      end
    end

    context 'when server is available but no git repo' do
      before do
        allow(described_class).to receive(:available?).and_return(true)
        allow(described_class).to receive(:git_repo_available?).and_return(false)
      end

      it 'includes only git init instructions' do
        instructions = described_class.installation_instructions

        expect(instructions).not_to include('Install Git MCP Server:')
        expect(instructions).to include('Initialize Git repository:')
      end
    end

    context 'when both are available' do
      before do
        allow(described_class).to receive(:available?).and_return(true)
        allow(described_class).to receive(:git_repo_available?).and_return(true)
      end

      it 'returns empty instructions' do
        instructions = described_class.installation_instructions

        expect(instructions).to be_empty
      end
    end
  end

  describe '.repo_status' do
    context 'when git repository is not available' do
      before do
        allow(described_class).to receive(:git_repo_available?).and_return(false)
      end

      it 'returns uninitialized status' do
        status = described_class.repo_status

        expect(status).to eq({ initialized: false, clean: false })
      end
    end

    context 'when git repository is available and clean' do
      before do
        allow(described_class).to receive(:git_repo_available?).and_return(true)
        allow(described_class).to receive(:`).with('git status --porcelain 2>/dev/null').and_return('')
      end

      it 'returns clean status' do
        status = described_class.repo_status

        expect(status[:initialized]).to be true
        expect(status[:clean]).to be true
        expect(status[:has_staged]).to be false
        expect(status[:has_unstaged]).to be false
        expect(status[:has_untracked]).to be false
      end
    end

    context 'when git repository has changes' do
      before do
        allow(described_class).to receive(:git_repo_available?).and_return(true)
        allow(described_class).to receive(:`).with('git status --porcelain 2>/dev/null').and_return(
          " M modified_file.rb\nA  staged_file.rb\n?? untracked_file.rb\n"
        )
      end

      it 'returns detailed status' do
        status = described_class.repo_status

        expect(status[:initialized]).to be true
        expect(status[:clean]).to be false
        expect(status[:has_staged]).to be true     # 'A' for staged file
        expect(status[:has_unstaged]).to be true   # ' M' for unstaged change
        expect(status[:has_untracked]).to be true  # '??' for untracked file
      end
    end

    context 'when git command raises an error' do
      before do
        allow(described_class).to receive(:git_repo_available?).and_return(true)
        allow(described_class).to receive(:`).and_raise(StandardError)
      end

      it 'returns error status' do
        status = described_class.repo_status

        expect(status).to eq({ initialized: false, clean: false })
      end
    end
  end
end
