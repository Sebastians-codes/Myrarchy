# Fish Configuration

set fish_greeting
set fish_color_user b06767
set fish_color_host CDCDCD
set fish_color_command deb896
set fish_color_param be8c8c
set fish_color_autosuggestion C2966B
set fish_color_cwd b06767
set fish_color_normal b06767
set -gx EDITOR nvim

# Dotnet aliases
function new
    if test (count $argv) -eq 0
        echo "Usage: new <template> [project-name]"
        echo "Examples:"
        echo "  new console MyApp        # Creates console app in ./MyApp folder"
        echo "  new console              # Creates console app in current directory"
        echo "  new webapi MyApi         # Creates web API in ./MyApi folder"
        echo "  new classlib MyLibrary   # Creates class library in ./MyLibrary folder"
        echo "  new sln MySolution       # Creates solution file"
        echo "  new sln                  # Creates solution file in current directory"
        echo "  new gitignore            # Creates .gitignore file"
        return 1
    end

    set template $argv[1]
    set project_name ""

    if test (count $argv) -ge 2
        set project_name $argv[2]
    end

    if test "$template" = "sln" -o "$template" = "gitignore" -o "$template" = "editorconfig" -o "$template" = "nugetconfig" -o "$template" = "tool-manifest" -o "$template" = "globaljson"
        if test -n "$project_name"
            dotnet new $template -n $project_name
        else
            dotnet new $template
        end
        return $status
    end

    if test -n "$project_name"
        echo "Creating $template project '$project_name' in ./$project_name/"
        dotnet new $template -n $project_name -o ./$project_name

        if test $status -ne 0
            echo "Failed to create project"
            return 1
        end

        set sln_files (ls *.sln 2>/dev/null)
        if test (count $sln_files) -gt 0
            set sln_file $sln_files[1]
            echo "Adding project to solution: $sln_file"
            dotnet sln $sln_file add ./$project_name/$project_name.csproj
            if test $status -eq 0
                echo "Successfully added project to solution"
            else
                echo "Warning: Failed to add project to solution (project still created)"
            end
        else
            echo "No solution file found - project created without solution integration"
        end
    else
        echo "Creating $template project in current directory"
        dotnet new $template
    end
end

function ref
    if test (count $argv) -lt 1 -o (count $argv) -gt 2
        echo "Usage: ref <target-project> [from-project]"
        echo "Examples:"
        echo "  ref MyLibrary                    # Add MyLibrary reference to current directory project"
        echo "  ref MyLibrary MyConsoleApp       # Add MyLibrary reference to MyConsoleApp project"
        echo "  ref ../Shared/MyLibrary          # Add reference using relative path"
        return 1
    end

    set target_project $argv[1]
    set from_project ""

    if test (count $argv) -eq 2
        set from_project $argv[2]
    end

    function find_project_file -a project_name

        if string match -q "*.csproj" $project_name
            echo $project_name
            return
        end

        if test -d $project_name -a -f $project_name/$project_name.csproj
            echo $project_name/$project_name.csproj
            return
        end

        if test -d $project_name
            set csproj_files (ls $project_name/*.csproj 2>/dev/null)
            if test (count $csproj_files) -eq 1
                echo $csproj_files[1]
                return
            else if test (count $csproj_files) -gt 1
                echo "Multiple .csproj files found in $project_name:" >&2
                for file in $csproj_files
                    echo "  $file" >&2
                end
                return 1
            end
        end

        set current_csproj (ls $project_name.csproj 2>/dev/null)
        if test -f "$current_csproj"
            echo $current_csproj
            return
        end

        echo "Could not find project: $project_name" >&2
        return 1
    end

    set target_path (find_project_file $target_project)
    if test $status -ne 0
        return 1
    end

    if test -n "$from_project"
        set from_path (find_project_file $from_project)
        if test $status -ne 0
            return 1
        end
    else
        set current_csproj (ls *.csproj 2>/dev/null)
        if test (count $current_csproj) -eq 1
            set from_path $current_csproj[1]
        else if test (count $current_csproj) -gt 1
            echo "Multiple .csproj files in current directory. Please specify which project:"
            for file in $current_csproj
                echo "  $file"
            end
            return 1
        else
            echo "No .csproj file found in current directory"
            return 1
        end
    end

    echo "Adding reference: $target_path -> $from_path"
    dotnet add $from_path reference $target_path

    if test $status -eq 0
        echo "Successfully added project reference"
    else
        echo "Failed to add project reference"
        return 1
    end
end

function sln
    if test (count $argv) -eq 0
        echo "Usage: sln <command> [arguments]"
        echo "Commands:"
        echo "  sln add <project>        # Add project to solution"
        echo "  sln remove <project>     # Remove project from solution"
        echo "  sln list                 # List projects in solution"
        echo "Examples:"
        echo "  sln add MyProject        # Add MyProject to solution"
        echo "  sln add ./MyApp          # Add project from directory"
        echo "  sln remove MyProject     # Remove project from solution"
        echo "  sln list                 # Show all projects in solution"
        return 1
    end

    set command $argv[1]

    set sln_files (ls *.sln 2>/dev/null)
    if test (count $sln_files) -eq 0
        echo "Error: No .sln file found in current directory"
        return 1
    else if test (count $sln_files) -gt 1
        echo "Multiple solution files found. Please specify which one to use:"
        for file in $sln_files
            echo "  $file"
        end
        return 1
    end

    set sln_file $sln_files[1]

    function find_project_file -a project_name
        if string match -q "*.csproj" $project_name
            if test -f $project_name
                echo $project_name
                return
            else
                echo "Project file not found: $project_name" >&2
                return 1
            end
        end

        if test -d $project_name -a -f $project_name/$project_name.csproj
            echo $project_name/$project_name.csproj
            return
        end

        if test -d $project_name
            set csproj_files (ls $project_name/*.csproj 2>/dev/null)
            if test (count $csproj_files) -eq 1
                echo $csproj_files[1]
                return
            else if test (count $csproj_files) -gt 1
                echo "Multiple .csproj files found in $project_name:" >&2
                for file in $csproj_files
                    echo "  $file" >&2
                end
                return 1
            end
        end

        if test -f "$project_name.csproj"
            echo $project_name.csproj
            return
        end

        echo "Could not find project: $project_name" >&2
        return 1
    end

    switch $command
        case "add"
            if test (count $argv) -ne 2
                echo "Usage: sln add <project>"
                return 1
            end

            set project_name $argv[2]
            set project_path (find_project_file $project_name)
            if test $status -ne 0
                return 1
            end

            echo "Adding project to solution: $project_path -> $sln_file"
            dotnet sln $sln_file add $project_path

            if test $status -eq 0
                echo "Successfully added project to solution"
            else
                echo "Failed to add project to solution"
                return 1
            end

        case "remove"
            if test (count $argv) -ne 2
                echo "Usage: sln remove <project>"
                return 1
            end

            set project_name $argv[2]
            set project_path (find_project_file $project_name)
            if test $status -ne 0
                return 1
            end

            echo "Removing project from solution: $project_path"
            dotnet sln $sln_file remove $project_path

            if test $status -eq 0
                echo "Successfully removed project from solution"
            else
                echo "Failed to remove project from solution"
                return 1
            end

        case "list"
            echo "Projects in solution: $sln_file"
            dotnet sln $sln_file list

        case "*"
            echo "Unknown command: $command"
            echo "Available commands: add, remove, list"
            return 1
    end
end

# Basic aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias update='paru -Syu'
alias search='paru -Ss --bottomup'
alias install='paru -S'
alias uninstall='paru -R'
alias off='shutdown -h now'
alias wifi-list='nmcli d wifi list'
alias wifi-connect='nmcli d wifi connect'
alias v='nvim'
alias vv='nvim .'
alias sv='sudo nvim'
alias cc='code .'
alias c='code'
alias zz='zellij'
alias zl='zellij list-sessions'
alias zk='zellij kill-sessions'
alias zka='zellij kill-all-sessions'
alias zd='zellij delete-session'
alias zda='zellij delete-all-sessions'
alias za='zellij attach'
alias docker='sudo docker'

# Basic Git aliases
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gps='git push'
alias gpl='git pull'
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gstd='git stash drop'

function mine
    # Get local IP address
    set local_ip (ip route get 1.1.1.1 | grep -oP 'src \K\S+' 2>/dev/null || ip addr show | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}' | cut -d'/' -f1)
    
    # Print IP information
    echo "🌐 Local IP: $local_ip"
    echo "🚀 Starting Minecraft server in new terminal..."
    
    # Change this path to your Minecraft server directory
    set server_path "$HOME/minecraftserver"
    
    # Launch server in new terminal window (using ghostty since that's your terminal)
    # You can change the terminal command and server startup command as needed
    ghostty -e fish -c "
        echo '🎮 Minecraft Server Starting...'
        echo 'Server IP: $local_ip:25565'
        echo 'Press Ctrl+C to stop the server'
        echo ''
        cd '$server_path'
        java -Xmx4G -Xms4G -jar server.jar nogui
    " &
    
    echo "✅ Server terminal launched!"
    echo "📍 Players can connect to: $local_ip:25565"
end

# Show complete git commit history with nice formatting
function ghi
    echo "📜 Complete Git Commit History"
    echo "=============================="

    # Check if we're in a git repository
    if not git rev-parse --git-dir > /dev/null 2>&1
        echo "❌ Not in a git repository"
        return 1
    end

    # Show complete history with nice formatting
    git --no-pager log --all --graph --pretty=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --abbrev-commit --date=relative

    echo ""
end

# Alternative with more detailed info
function ghid
    echo "📜 Detailed Git Commit History"
    echo "=============================="

    if not git rev-parse --git-dir > /dev/null 2>&1
        echo "❌ Not in a git repository"
        return 1
    end

    git --no-pager log --all --graph --pretty=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n%C(white)%s%C(reset)%n%C(dim white)Author: %an <%ae>%C(reset)%n' --abbrev-commit

    echo ""
end

# Compact one-liner version
function ghic
    echo "📜 Compact Git History"
    echo "====================="

    if not git rev-parse --git-dir > /dev/null 2>&1
        echo "❌ Not in a git repository"
        return 1
    end

    git --no-pager log --all --oneline --graph --decorate

    echo ""
end

# Interactive history browser
function ghib
    echo "📜 Interactive Git History Browser"
    echo "================================="

    if not git --no-pager rev-parse --git-dir > /dev/null 2>&1
        echo "❌ Not in a git repository"
        return 1
    end

    git --no-pager log --all --graph --pretty=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --abbrev-commit

    echo ""
end

# Create new branch and push to origin
function gnewb
    if test (count $argv) -eq 0
        echo "Usage: gnewb <branch-name>"
        echo "Creates a new branch and pushes it to origin"
        return 1
    end

    set branch_name $argv[1]
    echo "🌿 Creating and switching to branch: $branch_name"

    if git checkout -b "$branch_name"
        echo "🚀 Pushing branch to origin..."
        if git push -u origin "$branch_name"
            echo "✅ Branch '$branch_name' created and pushed!"
        else
            echo "❌ Failed to push branch"
        end
    else
        echo "❌ Failed to create branch"
    end

    echo ""
end

# Switch to existing branch
function gco
    if test (count $argv) -eq 0
        echo "Usage: gco <branch-name>"
        echo "Switch to an existing branch"
        return 1
    end

    set branch_name $argv[1]
    echo "🔄 Switching to branch: $branch_name"

    if git checkout "$branch_name"
        echo "✅ Switched to branch '$branch_name'"
    else
        echo "❌ Failed to switch to branch '$branch_name'"
        echo "💡 Branch might not exist. Use 'gnewb $branch_name' to create it."
    end

    echo ""
end

# List all branches
function gb
    echo "📋 All branches:"
    git --no-pager branch -a

    echo ""
end

# List local branches only
function gbl
    echo "📋 Local branches:"
    git --no-pager branch

    echo ""
end

# Delete branch (local and remote)
function gdel
    if test (count $argv) -eq 0
        echo "Usage: gdel <branch-name>"
        echo "Delete branch locally and remotely"
        return 1
    end

    set branch_name $argv[1]
    echo "🗑️  Deleting branch: $branch_name"

    # Switch to main if we're on the branch we want to delete
    set current_branch (git branch --show-current)
    if test "$current_branch" = "$branch_name"
        echo "🔄 Switching to main first..."
        git checkout main
    end

    # Delete local branch
    if git branch -d "$branch_name"
        echo "✅ Local branch '$branch_name' deleted"

        # Try to delete remote branch
        if git push origin --delete "$branch_name" 2>/dev/null
            echo "✅ Remote branch '$branch_name' deleted"
        else
            echo "⚠️  Remote branch '$branch_name' might not exist or already deleted"
        end
    else
        echo "❌ Failed to delete local branch. Use 'git branch -D $branch_name' to force delete."
    end

    echo ""
end

# Create new GitHub repository
function gnewrepo
    if test (count $argv) -eq 0
        echo "Usage: gnewrepo <repository-name> [description]"
        echo "Creates a private GitHub repository and sets it as remote origin"
        return 1
    end

    set repo_name $argv[1]
    set description "Created via command line"
    if test (count $argv) -gt 1
        set description $argv[2]
    end

    echo "🚀 Creating private repository: $repo_name"

    if gh repo create "$repo_name" --private --description "$description"
        echo "✅ Repository created on GitHub"

        if not test -d ".git"
            git init
            echo "📁 Initialized local git repository"
        end

        # Remove origin if it already exists
        if git remote get-url origin > /dev/null 2>&1
            echo "🔄 Removing existing origin remote"
            git remote remove origin
        end

        set username (gh api user --jq .login)
        git remote add origin "https://github.com/$username/$repo_name.git"
        echo "🔗 Remote origin added"

        # Check if there are files to commit
        if test (count (ls -A)) -gt 0
            echo "📁 Files found in directory"
            read -l -P "Create initial commit with current files? (y/n): " confirm
            if test "$confirm" = "y" -o "$confirm" = "Y"
                git add .
                git commit -m "Initial commit"
                git branch -M main
                git push -u origin main
                echo "🎉 Initial commit pushed!"
            end
        else
            echo "📁 No files in current directory"
        end

        echo "🌐 Repository URL: https://github.com/$username/$repo_name"
    else
        echo "❌ Failed to create repository"
        return 1
    end

    echo ""
end

# Create Pull Request
function gpr
    if test (count $argv) -eq 0
        echo "Usage: gpr <title> [body] [base]"
        echo "Creates a PR from current branch"
        return 1
    end

    set title $argv[1]
    set body ""
    set base "main"
    
    if test (count $argv) -gt 1
        set body $argv[2]
    end
    if test (count $argv) -gt 2
        set base $argv[3]
    end
    
    set current_branch (git branch --show-current)

    echo "🚀 Creating PR: $title"
    echo "📝 From: $current_branch → $base"

    if gh pr create --title "$title" --body "$body" --base "$base"
        echo "✅ PR created successfully!"
        gh pr view --web
    else
        echo "❌ Failed to create PR"
        return 1
    end

    echo ""
end

# List Pull Requests
function prs
    echo "📋 Open Pull Requests:"
    gh pr list
end

# View specific PR
function prv
    if test (count $argv) -eq 0
        echo "Usage: prv <pr-number>"
        echo "View details of a specific PR"
        return 1
    end

    set pr_number $argv[1]
    echo "🔍 Viewing PR #$pr_number:"
    gh pr view "$pr_number"

    echo ""
end

# Approve PR
function prapprove
    if test (count $argv) -eq 0
        echo "Usage: prapprove <pr-number> [comment]"
        echo "Approve a PR with optional comment"
        return 1
    end

    set pr_number $argv[1]
    set comment "LGTM! ✅"
    if test (count $argv) -gt 1
        set comment $argv[2]
    end

    echo "✅ Approving PR #$pr_number..."
    gh pr review "$pr_number" --approve --body "$comment"
    echo "🎉 PR #$pr_number approved!"
end

# Request changes on PR
function prchanges
    if test (count $argv) -lt 2
        echo "Usage: prchanges <pr-number> <comment>"
        echo "Request changes on a PR with required comment"
        return 1
    end

    set pr_number $argv[1]
    set comment $argv[2]

    echo "📝 Requesting changes on PR #$pr_number..."
    gh pr review "$pr_number" --request-changes --body "$comment"
    echo "✏️  Changes requested on PR #$pr_number"
end

# Merge PR
function gmerge
    set merge_type "merge"
    if test (count $argv) -gt 0
        set merge_type $argv[1]
    end

    switch $merge_type
        case "squash" "s"
            echo "🔄 Squash merging PR..."
            gh pr merge --squash --delete-branch
        case "rebase" "r"
            echo "🔄 Rebase merging PR..."
            gh pr merge --rebase --delete-branch
        case "merge" "m" "*"
            echo "🔄 Merge committing PR..."
            gh pr merge --merge --delete-branch
    end

    if test $status -eq 0
        echo "✅ PR merged and branch deleted!"
        git checkout main
        git pull origin main
        echo "🔄 Switched to main and pulled latest changes"
    end

    echo ""
end

# Quick aliases for PR operations
alias prl='gh pr list'
alias prc='gh pr checks'
alias prd='gh pr diff'
alias prco='gh pr checkout'

# Help function - lists all custom Git/GitHub functions
function ghelp
    echo ""
    echo "=== Git & GitHub Helper Functions ==="
    echo ""
    echo -e "\033[33mBASIC GIT COMMANDS:\033[0m"
    echo "  gs              - git status"
    echo "  ga <files>      - git add <files>"
    echo "  gaa             - git add . (add all files)"
    echo "  gc <message>    - git commit -m <message>"
    echo "  gps             - git push"
    echo "  gpl             - git pull"
    echo "  gst             - git stash"
    echo "  gstp            - git stash pop"
    echo "  gstl            - git stash list"
    echo "  gstd            - git stash drop"

    echo ""
    echo -e "\033[33mBRANCH MANAGEMENT:\033[0m"
    echo "  gnewb <name>    - Create new branch and push to origin"
    echo "                    Example: gnewb feature-login"
    echo "  gco <name>      - Switch to existing branch"
    echo "                    Example: gco main"
    echo "  gb              - List all branches (local and remote)"
    echo "  gbl             - List local branches only"
    echo "  gdel <name>     - Delete branch (local and remote)"
    echo "                    Example: gdel old-feature"

    echo ""
    echo -e "\033[33mREPOSITORY MANAGEMENT:\033[0m"
    echo "  gnewrepo <name> [description]"
    echo "                  - Create new private GitHub repo and set remote"
    echo "                    Example: gnewrepo my-project 'Cool new app'"

    echo ""
    echo -e "\033[33mPULL REQUEST CREATION:\033[0m"
    echo "  gpr <title> [body] [base]"
    echo "                  - Create pull request"
    echo "                    Example: gpr 'Add login' 'New feature' main"

    echo ""
    echo -e "\033[33mPULL REQUEST VIEWING:\033[0m"
    echo "  prs             - List all open pull requests"
    echo "  prv <number>    - View specific PR details"
    echo "                    Example: prv 123"
    echo "  prl             - List PRs (alias for prs)"
    echo "  prc <number>    - Check PR status/checks"
    echo "  prd <number>    - View PR diff"
    echo "  prco <number>   - Checkout PR branch locally"

    echo ""
    echo -e "\033[33mPULL REQUEST REVIEW:\033[0m"
    echo "  prapprove <number> [comment]"
    echo "                  - Approve a pull request"
    echo "                    Example: prapprove 123 'Great work!'"
    echo "  prchanges <number> <comment>"
    echo "                  - Request changes on PR (comment required)"
    echo "                    Example: prchanges 123 'Please add tests'"

    echo ""
    echo -e "\033[33mPULL REQUEST MERGING:\033[0m"
    echo "  gmerge [type]   - Merge current branch's PR"
    echo "                    Types: merge (default), squash, rebase"
    echo "                    Example: gmerge squash"

    echo ""
    echo -e "\033[33mHELP:\033[0m"
    echo "  ghelp           - Show this help message"

    echo ""
    echo "=== Usage Examples ==="
    echo -e "\033[32m# Complete workflow:\033[0m"
    echo "gb                          # List branches"
    echo "gnewb feature-auth          # Create new branch"
    echo "# ... make changes ..."
    echo "ga ."
    echo "gc 'Add authentication'"
    echo "gps                         # Push changes"
    echo "gpr 'Add user auth' 'New login system'"
    echo "# ... wait for review ..."
    echo "gmerge                      # Merge when approved"
    echo "gco main                    # Switch back to main"
    echo "gdel feature-auth           # Delete merged branch"
    echo ""
end

set -gx DOTNET_ROOT /usr/share/dotnet
fish_add_path /usr/share/dotnet
fish_add_path /usr/share/dotnet/tools

# Also keep your existing local dotnet
fish_add_path "$HOME/.dotnet/tools"
fish_add_path "$HOME/.dotnet"
fish_add_path "$HOME/source/csharp/Tasker/Cli/bin/Release/net9.0/"

# Claude alias

set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin /home/pmp/.ghcup/bin $PATH # ghcup-env

# =============================================================================
#
# Utility functions for zoxide.
#

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd
    builtin pwd -L
end

# A copy of fish's internal cd function. This makes it possible to use
# `alias cd=z` without causing an infinite loop.
if ! builtin functions --query __zoxide_cd_internal
    string replace --regex -- '^function cd\s' 'function __zoxide_cd_internal ' <$__fish_data_dir/functions/cd.fish | source
end

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd
    if set -q __zoxide_loop
        builtin echo "zoxide: infinite loop detected"
        builtin echo "Avoid aliasing `cd` to `z` directly, use `zoxide init --cmd=cd fish` instead"
        return 1
    end
    __zoxide_loop=1 __zoxide_cd_internal $argv
end

# =============================================================================
#
# Hook configuration for zoxide.
#

# Initialize hook to add new entries to the database.
function __zoxide_hook --on-variable PWD
    test -z "$fish_private_mode"
    and command zoxide add -- (__zoxide_pwd)
end

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function __zoxide_z
    set -l argc (builtin count $argv)
    if test $argc -eq 0
        __zoxide_cd $HOME
    else if test "$argv" = -
        __zoxide_cd -
    else if test $argc -eq 1 -a -d $argv[1]
        __zoxide_cd $argv[1]
    else if test $argc -eq 2 -a $argv[1] = --
        __zoxide_cd -- $argv[2]
    else
        set -l result (command zoxide query --exclude (__zoxide_pwd) -- $argv)
        and __zoxide_cd $result
    end
end

# Completions.
function __zoxide_z_complete
    set -l tokens (builtin commandline --current-process --tokenize)
    set -l curr_tokens (builtin commandline --cut-at-cursor --current-process --tokenize)

    if test (builtin count $tokens) -le 2 -a (builtin count $curr_tokens) -eq 1
        # If there are < 2 arguments, use `cd` completions.
        complete --do-complete "'' "(builtin commandline --cut-at-cursor --current-token) | string match --regex -- '.*/$'
    else if test (builtin count $tokens) -eq (builtin count $curr_tokens)
        # If the last argument is empty, use interactive selection.
        set -l query $tokens[2..-1]
        set -l result (command zoxide query --exclude (__zoxide_pwd) --interactive -- $query)
        and __zoxide_cd $result
        and builtin commandline --function cancel-commandline repaint
    end
end
complete --command __zoxide_z --no-files --arguments '(__zoxide_z_complete)'

# Jump to a directory using interactive search.
function __zoxide_zi
    set -l result (command zoxide query --interactive -- $argv)
    and __zoxide_cd $result
end

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

abbr --erase z &>/dev/null
alias z=__zoxide_z

abbr --erase zi &>/dev/null
alias zi=__zoxide_zi

# =============================================================================
#
# To initialize zoxide, add this to your configuration (usually
# ~/.config/fish/config.fish):
#
#   zoxide init fish | source

#!/usr/bin/env fish

# Add these functions to your config.fish file

# Live server with browser-sync - NO BACKGROUND PROCESSES
function lw
    # Check if browser-sync is installed
    if not command -q browser-sync
        echo "❌ browser-sync not installed"
        echo "📦 Installing browser-sync globally..."
        npm install -g browser-sync
        
        if not command -q browser-sync
            echo "❌ Failed to install browser-sync"
            echo "💡 Try manually: npm install -g browser-sync"
            return 1
        end
        echo "✅ browser-sync installed successfully"
    end
    
    # Check if index.html exists
    if not test -f "index.html"
        echo "❌ No index.html found in current directory"
        echo "📁 Current directory: "(pwd)
        return 1
    end
    
    echo "🚀 Starting live server with auto-refresh..."
    echo "📁 Serving: "(pwd)
    echo "👀 Watching all web files for changes..."
    echo ""
    echo "Press Ctrl+C to stop"
    echo ""
    
    # Start browser-sync in FOREGROUND (blocks terminal, Ctrl+C to stop)
    browser-sync start \
        --server \
        --files "**/*.html" "**/*.css" "**/*.scss" "**/*.js" "**/*.jsx" "**/*.ts" "**/*.tsx" "**/*.json" "**/*.vue" "**/*.svelte" \
        --ignore "node_modules" \
        --no-notify \
        --port 3000
end

# Helper to check for any background processes we might have created
function check-background
    echo "🔍 Checking for background processes..."
    
    # Check for entr
    set entr_procs (pgrep -f entr)
    if test (count $entr_procs) -gt 0
        echo "⚠️  Found entr processes: $entr_procs"
        echo "   Run: pkill -9 -f entr"
    else
        echo "✅ No entr processes"
    end
    
    # Check for background fish
    set fish_procs (pgrep -f "fish -c" | grep -v $fish_pid)
    if test (count $fish_procs) -gt 0
        echo "⚠️  Found background fish: $fish_procs"
        echo "   Run: pkill -9 -f 'fish -c'"
    else
        echo "✅ No background fish processes"
    end
    
    # Check for nohup
    set nohup_procs (pgrep -f nohup)
    if test (count $nohup_procs) -gt 0
        echo "⚠️  Found nohup processes: $nohup_procs"
    else
        echo "✅ No nohup processes"
    end
    
    # Check ports
    if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1
        echo "⚠️  Port 3000 is in use"
    else
        echo "✅ Port 3000 is free"
    end
    
    if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null 2>&1
        echo "⚠️  Port 8000 is in use"
    else
        echo "✅ Port 8000 is free"
    end
end

# Clean up any mess from previous attempts
function cleanup-all
    echo "🧹 Cleaning up all background processes..."
    
    # Kill all the things that might be running
    pkill -9 -f entr 2>/dev/null
    pkill -9 -f "fish -c" 2>/dev/null
    pkill -9 -f nohup 2>/dev/null
    pkill -9 -f "python3 -m http.server" 2>/dev/null
    
    echo "✅ Cleanup complete"
    echo ""
    echo "Running check..."
    check-background
end

# Simple Python server (also foreground only)
function simple-server
    if not test -f "index.html"
        echo "❌ No index.html found"
        return 1
    end
    
    echo "🚀 Starting simple Python server..."
    echo "📁 Serving: "(pwd)
    echo "🌐 http://localhost:8000"
    echo ""
    echo "Press Ctrl+C to stop"
    echo ""
    
    # This runs in foreground - no background process
    python3 -m http.server 8000
end

set -gx GTK_THEME Adwaita:dark

# Enable Vi key bindings
fish_vi_key_bindings

# Custom vim mode indicators that match your theme
function fish_mode_prompt
    switch $fish_bind_mode
        case default
            set_color b06767
            echo '|'
        case insert
            set_color be8c8c
            echo '>'
        case replace_one
            set_color C2966B
            echo 'r'
        case replace
            set_color C2966B
            echo 'r'
        case visual
            set_color be8c8c
            echo '<'
    end
    set_color normal
end

# Yazi help function - displays all keybinds and shortcuts (ACCURATE DEFAULT KEYBINDS)
function yazi-help
    echo ""
    echo "=== YAZI FILE MANAGER KEYBINDS (OFFICIAL DEFAULTS) ==="
    echo ""
    
    echo -e "\033[33mNAVIGATION:\033[0m"
    echo "  k/↑             - Previous file"
    echo "  j/↓             - Next file"
    echo "  h/←             - Back to parent directory"
    echo "  l/→             - Enter child directory"
    echo "  H               - Back to previous directory"
    echo "  L               - Forward to next directory"
    echo "  gg              - Go to top"
    echo "  G               - Go to bottom"
    echo "  Ctrl+u          - Move cursor up half page"
    echo "  Ctrl+d          - Move cursor down half page"
    echo "  Ctrl+b/PageUp   - Move cursor up one page"
    echo "  Ctrl+f/PageDown - Move cursor down one page"
    
    echo ""
    echo -e "\033[33mFILE OPERATIONS:\033[0m"
    echo "  o/Enter         - Open selected files"
    echo "  O/Shift+Enter   - Open selected files interactively"
    echo "  y               - Yank selected files (copy)"
    echo "  x               - Yank selected files (cut)"
    echo "  p               - Paste yanked files"
    echo "  P               - Paste yanked files (overwrite)"
    echo "  d               - Trash selected files"
    echo "  D               - Permanently delete selected files"
    echo "  a               - Create file (end with / for directories)"
    echo "  r               - Rename selected file(s)"
    echo "  -               - Symlink absolute path of yanked files"
    echo "  _               - Symlink relative path of yanked files"
    
    echo ""
    echo -e "\033[33mSELECTION:\033[0m"
    echo "  Space           - Toggle selection and move to next"
    echo "  Ctrl+a          - Select all files"
    echo "  Ctrl+r          - Invert selection of all files"
    echo "  v               - Enter visual mode (selection mode)"
    echo "  V               - Enter visual mode (unset mode)"
    echo "  Y/X             - Cancel yank status"
    
    echo ""
    echo -e "\033[33mSEARCH & FILTER:\033[0m"
    echo "  s               - Search files by name via fd"
    echo "  S               - Search files by content via ripgrep"
    echo "  Ctrl+s          - Cancel ongoing search"
    echo "  f               - Filter files"
    echo "  /               - Find next file"
    echo "  ?               - Find previous file"
    echo "  n               - Next found"
    echo "  N               - Previous found"
    echo "  .               - Toggle visibility of hidden files"
    
    echo ""
    echo -e "\033[33mPREVIEW & SPOT:\033[0m"
    echo "  Tab             - Spot hovered file"
    echo "  K               - Seek up 5 units in preview"
    echo "  J               - Seek down 5 units in preview"
    
    echo ""
    echo -e "\033[33mSORTING:\033[0m"
    echo "  ,m / ,M         - Sort by modified time (normal/reverse)"
    echo "  ,b / ,B         - Sort by birth time (normal/reverse)"
    echo "  ,e / ,E         - Sort by extension (normal/reverse)"
    echo "  ,a / ,A         - Sort alphabetically (normal/reverse)"
    echo "  ,n / ,N         - Sort naturally (normal/reverse)"
    echo "  ,s / ,S         - Sort by size (normal/reverse)"
    echo "  ,r              - Sort randomly"
    
    echo ""
    echo -e "\033[33mTAB MANAGEMENT:\033[0m"
    echo "  t               - Create new tab with current directory"
    echo "  1-9             - Switch to tab 1-9"
    echo "  [/]             - Switch to previous/next tab"
    echo "  {/}             - Swap current tab with previous/next tab"
    
    echo ""
    echo -e "\033[33mGOTO SHORTCUTS:\033[0m"
    echo "  gh              - Go home"
    echo "  gc              - Go to ~/.config"
    echo "  gd              - Go to ~/Downloads"
    echo "  g<Space>        - Jump interactively"
    echo "  gf              - Follow hovered symlink"
    echo "  z               - Jump to file/directory via fzf"
    echo "  Z               - Jump to directory via zoxide"
    
    echo ""
    echo -e "\033[33mCOPY PATH/NAME:\033[0m"
    echo "  cc              - Copy file path"
    echo "  cd              - Copy directory path"
    echo "  cf              - Copy filename"
    echo "  cn              - Copy filename without extension"
    
    echo ""
    echo -e "\033[33mLINE MODES (display format):\033[0m"
    echo "  ms              - Show file sizes"
    echo "  mp              - Show permissions"
    echo "  mb              - Show birth time"
    echo "  mm              - Show modified time"
    echo "  mo              - Show owner"
    echo "  mn              - No line mode"
    
    echo ""
    echo -e "\033[33mSHELL & COMMANDS:\033[0m"
    echo "  ;               - Run shell command"
    echo "  :               - Run shell command (block until finishes)"
    
    echo ""
    echo -e "\033[33mCONTROL:\033[0m"
    echo "  q               - Quit the process"
    echo "  Q               - Quit without outputting cwd-file"
    echo "  Ctrl+c          - Close the current tab, or quit if last"
    echo "  Ctrl+z          - Suspend the process"
    echo "  Esc/Ctrl+[      - Exit visual mode, clear selection, or cancel search"
    echo "  w               - Show task manager"
    echo "  ~/F1            - Open help"
    
    echo ""
    echo -e "\033[32mNOTE:\033[0m These are the official default keybinds from yazi's preset keymap"
    echo -e "\033[32mTIP:\033[0m  Customize in ~/.config/yazi/keymap.toml"
    echo ""
end

function startup-update
    echo "🔄 Starting system update check with retry logic..."

    set -l max_attempts 5
    set -l delay 3  # seconds between attempts
    set -l attempt 1

    while test $attempt -le $max_attempts
        echo "📡 Attempt $attempt/$max_attempts: Checking connection and updates..."

        if ping -c 1 8.8.8.8 >/dev/null 2>&1
            echo "✅ Internet connection detected"

            echo "🔍 Checking for available updates..."
            if paru -Qu | grep -q .
                echo "📦 Updates found! Running update..."
                update  # This uses your existing alias: paru -Syu
                return 0
            else
                echo "✅ System is up to date!"
                return 0
            end
        else
            echo "❌ No internet connection (attempt $attempt)"

            if test $attempt -lt $max_attempts
                echo "⏱️  Waiting $delay seconds before retry..."
                sleep $delay
                set attempt (math $attempt + 1)
            else
                echo "🚫 No internet connection after $max_attempts attempts"
                echo "💡 Updates will be available when connection is restored"
                return 1
            end
        end
    end
end
