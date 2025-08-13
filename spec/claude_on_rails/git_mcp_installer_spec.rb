# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ClaudeOnRails::GitMCPInstaller do
  let(:installer) { described_class.new }
  let(:stdin_double) { instance_double(IO) }
  let(:original_stdin) { $stdin }

  before do
    # Stub STDOUT/STDERR to avoid cluttering test output
    allow($stdout).to receive(:puts)
    allow($stderr).to receive(:puts)
    allow(installer).to receive(:puts)
    allow(installer).to receive(:print)

    # Replace global $stdin for user input
    $stdin = stdin_double
  end

  after do
    # Restore original $stdin
    $stdin = original_stdin
  end

  describe '#run' do
    context 'when Git MCP Server and repository are already set up' do
      before do
        allow(ClaudeOnRails::GitMCPSupport).to receive(:usable?).and_return(true)
        allow(ClaudeOnRails::GitMCPSupport).to receive(:available?).and_return(true)
        allow(ClaudeOnRails::GitMCPSupport).to receive(:git_repo_available?).and_return(true)
        allow(ClaudeOnRails::GitMCPSupport).to receive(:repo_status).and_return({
                                                                                  initialized: true,
                                                                                  clean: true,
                                                                                  has_staged: false,
                                                                                  has_unstaged: false,
                                                                                  has_untracked: false
                                                                                })
      end

      it 'shows success message and repository status' do
        expect(installer).to receive(:puts).with(/Git MCP Server setup is complete/)
        expect(installer).to receive(:puts).with(/Setup process completed/)

        installer.run
      end
    end

    context 'when setup is required' do
      before do
        allow(ClaudeOnRails::GitMCPSupport).to receive(:usable?).and_return(false)
        allow(ClaudeOnRails::GitMCPSupport).to receive(:available?).and_return(false)
        allow(ClaudeOnRails::GitMCPSupport).to receive(:git_repo_available?).and_return(false)
      end

      it 'calls handle_setup_requirements' do
        expect(installer).to receive(:handle_setup_requirements)

        installer.run
      end
    end
  end

  describe '#handle_setup_requirements' do
    before do
      allow(installer).to receive(:prompt_yes_no?).and_return(false)
      allow(ClaudeOnRails::GitMCPSupport).to receive(:available?).and_return(false)
      allow(ClaudeOnRails::GitMCPSupport).to receive(:git_repo_available?).and_return(false)
    end

    context 'when user agrees to install Git MCP Server' do
      before do
        allow(installer).to receive(:prompt_yes_no?).with(/install Git MCP Server/).and_return(true)
      end

      it 'calls install_git_mcp_server' do
        expect(installer).to receive(:install_git_mcp_server)

        installer.send(:handle_setup_requirements)
      end
    end

    context 'when user declines to install Git MCP Server' do
      before do
        allow(installer).to receive(:prompt_yes_no?).with(/install Git MCP Server/).and_return(false)
      end

      it 'shows skip message' do
        expect(installer).to receive(:puts).with(/Skipping Git MCP Server installation/)

        installer.send(:handle_setup_requirements)
      end
    end

    context 'when Git repository is not available' do
      before do
        allow(ClaudeOnRails::GitMCPSupport).to receive(:available?).and_return(true)
        allow(installer).to receive(:prompt_yes_no?).with(/initialize a Git repository/).and_return(true)
      end

      it 'calls initialize_git_repository' do
        expect(installer).to receive(:initialize_git_repository)

        installer.send(:handle_setup_requirements)
      end
    end
  end

  describe '#install_git_mcp_server' do
    context 'when installation succeeds' do
      before do
        allow(installer).to receive(:system).with('gem install git-mcp-server --no-document').and_return(true)
      end

      it 'shows success message' do
        expect(installer).to receive(:puts).with(/Git MCP Server installed successfully/)

        installer.send(:install_git_mcp_server)
      end
    end

    context 'when installation fails' do
      before do
        allow(installer).to receive(:system).with('gem install git-mcp-server --no-document').and_return(false)
        allow(installer).to receive(:exit)
      end

      it 'shows error message and manual instructions' do
        expect(installer).to receive(:puts).with(/Failed to install Git MCP Server/)
        expect(installer).to receive(:puts).with(/gem install git-mcp-server --no-document/)

        installer.send(:install_git_mcp_server)
      end
    end
  end

  describe '#initialize_git_repository' do
    context 'when git init succeeds' do
      before do
        allow(installer).to receive(:system).with('git init').and_return(true)
        allow(installer).to receive(:prompt_yes_no?).with(/initial commit/).and_return(false)
      end

      it 'shows success message' do
        expect(installer).to receive(:puts).with(/Git repository initialized successfully/)

        installer.send(:initialize_git_repository)
      end

      context 'and user wants initial commit' do
        before do
          allow(installer).to receive(:prompt_yes_no?).with(/initial commit/).and_return(true)
          allow(installer).to receive(:system).with('git add .').and_return(true)
          allow(installer).to receive(:system).with('git commit -m "Initial commit"').and_return(true)
        end

        it 'creates initial commit' do
          expect(installer).to receive(:system).with('git add .')
          expect(installer).to receive(:system).with('git commit -m "Initial commit"')
          expect(installer).to receive(:puts).with(/Initial commit created/)

          installer.send(:initialize_git_repository)
        end
      end
    end

    context 'when git init fails' do
      before do
        allow(installer).to receive(:system).with('git init').and_return(false)
      end

      it 'shows error message and manual instructions' do
        expect(installer).to receive(:puts).with(/Failed to initialize Git repository/)
        expect(installer).to receive(:puts).with(/git init/)

        installer.send(:initialize_git_repository)
      end
    end
  end

  describe '#show_next_steps' do
    context 'when Git MCP is usable' do
      before do
        allow(ClaudeOnRails::GitMCPSupport).to receive(:usable?).and_return(true)
      end

      it 'shows setup completion steps' do
        expect(installer).to receive(:puts).with(/rails generate claude_on_rails:swarm --git-mcp/)
        expect(installer).to receive(:puts).with(/claude-swarm/)
        expect(installer).to receive(:puts).with(/Your AI agents now have full Git repository access/)

        installer.send(:show_next_steps)
      end
    end

    context 'when Git MCP is not usable' do
      before do
        allow(ClaudeOnRails::GitMCPSupport).to receive(:usable?).and_return(false)
      end

      it 'shows prerequisite steps' do
        expect(installer).to receive(:puts).with(/Complete the missing requirements/)
        expect(installer).to receive(:puts).with(/bundle exec rake claude_on_rails:setup_git_mcp/)

        installer.send(:show_next_steps)
      end
    end
  end

  describe '#prompt_yes_no?' do
    context 'when user enters yes' do
      before do
        allow(stdin_double).to receive(:gets).and_return("yes\n")
      end

      it 'returns true' do
        result = installer.send(:prompt_yes_no?, 'Test question?')
        expect(result).to be true
      end
    end

    context 'when user enters y' do
      before do
        allow(stdin_double).to receive(:gets).and_return("y\n")
      end

      it 'returns true' do
        result = installer.send(:prompt_yes_no?, 'Test question?')
        expect(result).to be true
      end
    end

    context 'when user enters empty string (default yes)' do
      before do
        allow(stdin_double).to receive(:gets).and_return("\n")
      end

      it 'returns true' do
        result = installer.send(:prompt_yes_no?, 'Test question?')
        expect(result).to be true
      end
    end

    context 'when user enters no' do
      before do
        allow(stdin_double).to receive(:gets).and_return("no\n")
      end

      it 'returns false' do
        result = installer.send(:prompt_yes_no?, 'Test question?')
        expect(result).to be false
      end
    end
  end
end
