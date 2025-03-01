# Dotfiles Management with GNU Stow

This repository contains my personal configuration files (dotfiles), organized to be managed with GNU Stow.

## What is GNU Stow?

GNU Stow is a symlink manager that helps keep your dotfiles organized while making them available in your home directory.

## Repository Structure

```
dotfiles/
├── bash/
│   └── .bashrc
├── git/
│   ├── .gitattributes
│   ├── .gitconfig
│   └── .gitignore
├── nvim/
│   └── .config/
│       └── nvim/
│           └── init.lua
├── ssh/
│   └── .ssh/
│       └── config
├── tmux/
│   └── .tmux.conf
└── vim/
    └── .vimrc

```
## How Stow Works

Stow creates symbolic links from a target directory (usually your home directory) to files in this repository. The key insight is:

**The directory structure inside each package mirrors where the files should appear in your home directory.**

For example:
- `bash/.bashrc` will be symlinked to `~/.bashrc`
- `nvim/.config/nvim/init.lua` will be symlinked to `~/.config/nvim/init.lua`

**Important**: By default, Stow creates symlinks in the parent directory of where you run the command. Since this repository is at `~/GitRepos/dotfiles`, running Stow without options would create symlinks in `~/GitRepos/` instead of your home directory. This is why the `-t ~` option is essential in this setup.

## Installation

### Prerequisites

Install GNU Stow:

```bash
# Ubuntu/Debian
sudo apt install stow
```
### Basic Usage
Since this repository is located at ~/GitRepos/dotfiles (not directly under home), you need to specify the target directory:

```sh
cd ~/GitRepos/dotfiles
stow -t ~ bash git nvim ssh tmux vim
```

```sh
# Just install bash configuration
stow -t ~ bash
```


Remove symlinks for a package:
```sh
stow -t ~ -D bash
```

Dry Run (Simulation)
```sh
stow -t ~ -nv bash
```

Convenient Aliases
```sh
alias stowdot='stow -t ~ -d ~/GitRepos/dotfiles'
stowdot bash
stowdot -D vim  # to remove vim symlinks
stowdot -R git  # to restow git files
```

## Stow Wrapper Script - `stow_wrapper.sh`

This script automates the process of checking and backing up existing config files before symlinking them.

- If a config file **already exists**, it is backed up as `{filename}_orig`.
- Then, the script **creates symlinks** to the corresponding dotfiles.
- Using `*` will back up and symlink **all dotfiles** except `stow_wrapper.sh`, `README.md` and `.git`.

**Example Usage:**
```bash
# Backup and symlink Bash configuration
./stow_wrapper.sh bash

# Backup and symlink everything
./stow_wrapper.sh *
```

## Troubleshooting
- List broken symbolic links in ~: `find ~ -xtype l`
- Find and delete broken symbolic links in ~: `find ~ -xtype l -delete`

> **NOTE:**
> - **Existing Files:** Stow will not overwrite existing files. If you already have a `.bashrc` file, Stow will fail unless you remove or rename it first.
> - **Directory Structure:** The directory structure from the source directory (package subdirectory) will be mirrored via symlinks in the parent directory or the desired target directory (`-t`).
>   - For instance, when running `stow git`, Stow will take the contents of the `./git` repository and symlink the files in it to the target directory. It will not symlink the `git` folder itself, just its contents.
> - **Target Directory:** Since this repository is in `~/GitRepos/dotfiles`, you must use the `-t ~` option to create symlinks in your home directory.
> - **Automatic Directory Creation:** GNU Stow will automatically create target directories if they are missing.
