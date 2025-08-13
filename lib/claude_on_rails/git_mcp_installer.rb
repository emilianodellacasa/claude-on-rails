# frozen_string_literal: true

module ClaudeOnRails
  # Interactive installer for Git MCP Server
  class GitMCPInstaller
    def run
      puts "\e[32m🔧 ClaudeOnRails Git MCP Server Setup\e[0m"
      puts "\e[32m#{'=' * 50}\e[0m"

      check_git_availability
      check_mcp_server_availability

      if GitMCPSupport.usable?
        puts "\e[32m✓ Git MCP Server setup is complete!\e[0m"
        show_repo_status
      else
        handle_setup_requirements
      end

      puts "\n\e[32m✅ Setup process completed!\e[0m"
      show_next_steps
    end

    private

    def check_git_availability
      if GitMCPSupport.git_repo_available?
        puts "\e[32m✓ Git repository detected\e[0m"
      else
        puts "\e[31m✗ No Git repository found\e[0m"
      end
    end

    def check_mcp_server_availability
      if GitMCPSupport.available?
        puts "\e[32m✓ Git MCP Server is already installed\e[0m"
      else
        puts "\e[31m✗ Git MCP Server not found\e[0m"
      end
    end

    def show_repo_status
      status = GitMCPSupport.repo_status
      return unless status[:initialized]

      puts "\n\e[33mRepository Status:\e[0m"
      puts "\e[36m  • Repository: #{status[:clean] ? 'Clean' : 'Has changes'}\e[0m"
      puts "\e[36m  • Staged files: #{status[:has_staged] ? 'Yes' : 'No'}\e[0m" if status[:has_staged]
      puts "\e[36m  • Unstaged changes: #{status[:has_unstaged] ? 'Yes' : 'No'}\e[0m" if status[:has_unstaged]
      puts "\e[36m  • Untracked files: #{status[:has_untracked] ? 'Yes' : 'No'}\e[0m" if status[:has_untracked]
    end

    def handle_setup_requirements
      puts "\n\e[33mGit MCP Server provides your AI agents with:\e[0m"
      puts "\e[36m  • Complete Git repository management\e[0m"
      puts "\e[36m  • Branch and merge operations\e[0m"
      puts "\e[36m  • Commit history analysis\e[0m"
      puts "\e[36m  • Diff and blame functionality\e[0m"
      puts "\e[36m  • Stash and tag management\e[0m"

      unless GitMCPSupport.available?
        if prompt_yes_no?("\nWould you like to install Git MCP Server? (Y/n)")
          install_git_mcp_server
        else
          puts "\n\e[33mSkipping Git MCP Server installation.\e[0m"
        end
      end

      return if GitMCPSupport.git_repo_available?

      if prompt_yes_no?("\nWould you like to initialize a Git repository? (Y/n)")
        initialize_git_repository
      else
        puts "\n\e[33mSkipping Git repository initialization.\e[0m"
        puts "\e[36mNote: Git MCP Server requires a Git repository to function.\e[0m"
      end
    end

    def install_git_mcp_server
      puts "\n\e[32mInstalling Git MCP Server globally...\e[0m"

      # Install without documentation to avoid conflicts
      if system('gem install git-mcp-server --no-document')
        puts "\e[32m✓ Git MCP Server installed successfully!\e[0m"
      else
        puts "\n\e[31m❌ Failed to install Git MCP Server\e[0m"
        puts "\e[33mPlease try running manually:\e[0m"
        puts "\e[36m  gem install git-mcp-server --no-document\e[0m"
      end
    end

    def initialize_git_repository
      puts "\n\e[32mInitializing Git repository...\e[0m"

      if system('git init')
        puts "\e[32m✓ Git repository initialized successfully!\e[0m"

        if prompt_yes_no?("Would you like to make an initial commit? (Y/n)")
          system('git add .')
          if system('git commit -m "Initial commit"')
            puts "\e[32m✓ Initial commit created!\e[0m"
          else
            puts "\e[33m⚠ Could not create initial commit (possibly no files to commit)\e[0m"
          end
        end
      else
        puts "\n\e[31m❌ Failed to initialize Git repository\e[0m"
        puts "\e[33mPlease try running manually:\e[0m"
        puts "\e[36m  git init\e[0m"
      end
    end

    def show_next_steps
      puts "\n\e[33mNext steps:\e[0m"

      if GitMCPSupport.usable?
        puts "\e[36m1. Run the swarm generator to include Git MCP Server:\e[0m"
        puts "\e[36m   rails generate claude_on_rails:swarm --git-mcp\e[0m"
        puts "\n\e[36m2. Start your enhanced Rails development swarm:\e[0m"
        puts "\e[36m   claude-swarm\e[0m"
        puts "\n\e[32mYour AI agents now have full Git repository access! 🎉\e[0m"
      else
        puts "\e[36m1. Complete the missing requirements above\e[0m"
        puts "\e[36m2. Run setup again: bundle exec rake claude_on_rails:setup_git_mcp\e[0m"
        puts "\e[36m3. Then run the swarm generator:\e[0m"
        puts "\e[36m   rails generate claude_on_rails:swarm --git-mcp\e[0m"
      end

      puts "\n\e[36mFor more information:\e[0m"
      puts "\e[36m  • Check Git status: bundle exec rake claude_on_rails:git_status\e[0m"
      puts "\e[36m  • View repository: bundle exec rake claude_on_rails:repo_info\e[0m"
      puts "\e[36m  • Documentation: https://github.com/obie/claude-on-rails\e[0m"
    end

    def prompt_yes_no?(question)
      print "\e[32m#{question} \e[0m"
      response = $stdin.gets.chomp.downcase
      response.empty? || response.start_with?('y')
    end
  end
end
