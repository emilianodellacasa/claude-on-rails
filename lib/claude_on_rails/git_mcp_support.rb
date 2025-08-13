# frozen_string_literal: true

module ClaudeOnRails
  # Support module for Git MCP Server integration
  module GitMCPSupport
    class << self
      # Check if Git MCP Server gem is available on the system
      def available?
        # Check if the gem is installed
        system('gem list -i git-mcp-server > /dev/null 2>&1') ||
          # Also check if the executable is available
          system('which git-mcp-server > /dev/null 2>&1')
      rescue StandardError
        false
      end

      # Check if a Git repository exists
      def git_repo_available?
        File.directory?('.git') || system('git rev-parse --git-dir > /dev/null 2>&1')
      rescue StandardError
        false
      end

      # Get the MCP server configuration for swarm
      def server_config(environment = 'development')
        {
          name: 'git',
          type: 'stdio',
          command: 'git-mcp-server',
          args: [],
          env: { 'ENVIRONMENT' => environment }
        }
      end

      # Check if we can use Git MCP functionality
      def usable?
        available? && git_repo_available?
      end

      # Get available Git tools
      def available_tools
        %w[
          git_status
          git_log
          git_diff
          git_branch
          git_commit
          git_push
          git_pull
          git_checkout
          git_merge
          git_stash
          git_reset
          git_tag
          git_blame
          git_show
        ]
      end

      # Generate installation instructions
      def installation_instructions
        instructions = []

        unless available?
          instructions << "Install Git MCP Server:"
          instructions << "  gem install git-mcp-server --no-document"
          instructions << ""
        end

        unless git_repo_available?
          instructions << "Initialize Git repository:"
          instructions << "  git init"
          instructions << "  git add ."
          instructions << "  git commit -m 'Initial commit'"
          instructions << ""
        end

        instructions
      end

      # Check Git repository status
      def repo_status
        return { initialized: false, clean: false } unless git_repo_available?

        status_output = `git status --porcelain 2>/dev/null`
        {
          initialized: true,
          clean: status_output.strip.empty?,
          has_staged: status_output.lines.any? { |line| line[0] != ' ' && line[0] != '?' },
          has_unstaged: status_output.lines.any? { |line| line[1] != ' ' },
          has_untracked: status_output.lines.any? { |line| line.start_with?('??') }
        }
      rescue StandardError
        { initialized: false, clean: false }
      end
    end
  end
end
