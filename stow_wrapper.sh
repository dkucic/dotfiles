#!/bin/bash
# stow_wrapper.sh - A simple wrapper for GNU Stow with automatic backups
# ./stow_wrapper.sh * stows all packages except README.md, stow_wrapper.sh and .git

# Configuration
DOTFILES_DIR="$HOME/GitRepos/dotfiles"
TARGET_DIR="$HOME"
BACKUP_SUFFIX="_orig"
IGNORE_LIST=("README.md" "stow_wrapper.sh" ".git")

if [ ! -x "$(command -v stow)" ]; then
    echo "Install gnu stow"
    exit 1
fi

# Function to check if a file exists and back it up if needed
backup_if_needed() {
    local target_file="$1"
    
    # Skip if it's a directory
    if [ -d "$target_file" ]; then
        return
    fi
    
    # If file exists and is not a symlink or is a symlink pointing elsewhere
    if [ -e "$target_file" ] && { [ ! -L "$target_file" ] || [[ "$(readlink "$target_file")" != "$DOTFILES_DIR"/* ]]; }; then
        echo "Backing up $target_file to ${target_file}${BACKUP_SUFFIX}"
        mv "$target_file" "${target_file}${BACKUP_SUFFIX}"
    fi
}

# Function to find all files that would be stowed
find_stow_targets() {
    local package="$1"
    
    # Find all files in the package
    find "$DOTFILES_DIR/$package" -type f | while read -r source_file; do
        # Get the relative path from the package directory
        local rel_path="${source_file#"$DOTFILES_DIR"/"$package"/}"
        
        # Construct the target path
        local target_file="$TARGET_DIR/$rel_path"
        
        # Output the target file path
        echo "$target_file"
    done
}

# Function to check if a package should be ignored
should_ignore() {
    local package="$1"
    
    # Check if package is in the ignore list
    for ignore_item in "${IGNORE_LIST[@]}"; do
        if [ "$package" = "$ignore_item" ]; then
            return 0  # Should ignore
        fi
    done
    
    return 1  # Should not ignore
}

# Main function
stow_with_backup() {
    # Check if any packages were specified
    if [ $# -eq 0 ]; then
        echo "Usage: $(basename "$0") package1 [package2 ...] or * for all packages"
        echo "Available packages:"
        # List available packages
        for pkg in "$DOTFILES_DIR"/*; do
            if [ -d "$pkg" ]; then
                pkg_name=$(basename "$pkg")
                if ! should_ignore "$pkg_name"; then
                    echo "  $pkg_name"
                fi
            fi
        done
        exit 1
    fi
    
    # Process each package
    for package in "$@"; do
        # Handle wildcard case
        if [ "$package" = "*" ]; then
            # Process all directories in DOTFILES_DIR except those in IGNORE_LIST
            for pkg in "$DOTFILES_DIR"/*; do
                if [ -d "$pkg" ]; then
                    pkg_name=$(basename "$pkg")
                    if ! should_ignore "$pkg_name"; then
                        stow_single_package "$pkg_name"
                    fi
                fi
            done
            return
        else
            stow_single_package "$package"
        fi
    done
}

# Function to stow a single package
stow_single_package() {
    local package="$1"
    
    echo "Processing package: $package"
    
    # Check if package should be ignored
    if should_ignore "$package"; then
        echo "Skipping ignored package: $package"
        return
    fi
    
    # Check if package exists
    if [ ! -d "$DOTFILES_DIR/$package" ]; then
        echo "Error: Package '$package' not found in $DOTFILES_DIR"
        return
    fi
    
    # Find and backup existing files
    while read -r target_file; do
        backup_if_needed "$target_file"
    done < <(find_stow_targets "$package")
    
    # Stow the package
    echo "Stowing $package..."
    stow -t "$TARGET_DIR" -d "$DOTFILES_DIR" "$package"
    echo "Done with $package"
    echo
}

# Run the main function with all arguments
stow_with_backup "$@"