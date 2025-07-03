# Contributing to Bash Backup Script

Thank you for your interest in contributing to the Bash Backup Script project! We welcome contributions from everyone.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code. Please be respectful and constructive in all interactions.

## How Can I Contribute?

### 🐛 Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Environment details** (OS, Bash version, etc.)
- **Log files** or error messages
- **Screenshots** if applicable

### 💡 Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- **Clear description** of the enhancement
- **Use case** or problem it solves
- **Proposed implementation** (if you have ideas)
- **Alternatives considered**

### 🔧 Code Contributions

We welcome code contributions! Here are some areas where help is appreciated:

- Bug fixes
- Performance improvements
- Cross-platform compatibility
- New features
- Documentation improvements
- Test coverage improvements

## Development Setup

### Prerequisites

- Bash 4.0 or higher
- Git
- Text editor or IDE
- shellcheck (for code quality)

### Setup Steps

1. **Fork the repository**
   ```bash
   # Click "Fork" on GitHub, then clone your fork
   git clone https://github.com/yourusername/backup-script.git
   cd backup-script
   ```

2. **Create a development branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b bugfix/issue-number
   ```

3. **Install development tools**
   ```bash
   # Install shellcheck for Linux/macOS
   sudo apt-get install shellcheck  # Ubuntu/Debian
   brew install shellcheck          # macOS
   
   # For Windows, use package manager or download from:
   # https://github.com/koalaman/shellcheck
   ```

## Coding Standards

### Bash Style Guide

- **Indentation**: Use 4 spaces (not tabs)
- **Line length**: Maximum 100 characters
- **Variable naming**: Use lowercase with underscores (`backup_dir`)
- **Constants**: Use uppercase (`BACKUP_DIR`)
- **Quotes**: Always quote variables: `"$variable"`
- **Error handling**: Check exit codes and handle errors gracefully

### Example Code Style

```bash
#!/bin/bash

# Good variable usage
backup_dir="$1"
source_path="$2"
readonly SCRIPT_NAME="backup.sh"

# Good function definition
create_backup() {
    local source="$1"
    local destination="$2"
    
    if [[ -z "$source" || -z "$destination" ]]; then
        echo "Error: Missing required arguments" >&2
        return 1
    fi
    
    # Implementation here
}

# Good error handling
if ! tar -czf "$backup_file" "$source"; then
    echo "Error: Failed to create backup" >&2
    exit 1
fi
```

### Comments and Documentation

- Add comments for complex logic
- Use descriptive function and variable names
- Document function parameters and return values
- Keep comments up-to-date with code changes

```bash
# Creates a timestamped backup archive
# Arguments:
#   $1 - source path to backup
#   $2 - destination directory
# Returns:
#   0 on success, 1 on failure
create_backup() {
    # Implementation
}
```

## Testing Guidelines

### Manual Testing

Test your changes on multiple platforms:

- **Linux** (Ubuntu, CentOS, etc.)
- **macOS**
- **Windows Git Bash**

### Test Cases

Ensure your changes work with:

1. **File backups**: Single files of various sizes
2. **Directory backups**: Empty, small, and large directories
3. **Special characters**: Paths with spaces, unicode characters
4. **Edge cases**: Non-existent sources, permission issues
5. **Error conditions**: Full disk, invalid paths

### Automated Testing

Run shellcheck to catch common issues:

```bash
shellcheck backup.sh
```

### Creating Test Scripts

Create test scripts for new features:

```bash
#!/bin/bash
# test_backup.sh

set -euo pipefail

# Create test data
mkdir -p test_source test_dest
echo "test content" > test_source/test.txt

# Test the backup script
if ./backup.sh test_source test_dest; then
    echo "✅ Test passed"
else
    echo "❌ Test failed"
    exit 1
fi

# Cleanup
rm -rf test_source test_dest
```

## Submitting Changes

### Before Submitting

1. **Test thoroughly** on multiple platforms
2. **Run shellcheck** and fix any issues
3. **Update documentation** if needed
4. **Add or update tests** for your changes
5. **Follow commit message conventions**

### Commit Message Format

Use clear, descriptive commit messages:

```
type(scope): brief description

Longer description if needed, explaining what and why.

Fixes #issue-number
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat: add compression level option
fix: handle paths with spaces correctly
docs: update installation instructions
```

### Pull Request Process

1. **Create a pull request** from your feature branch
2. **Fill out the PR template** completely
3. **Link related issues** using keywords (fixes #123)
4. **Request review** from maintainers
5. **Address feedback** promptly and professionally
6. **Squash commits** if requested before merging

### Pull Request Template

```markdown
## Description
Brief description of changes and motivation.

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Tested on Linux
- [ ] Tested on macOS  
- [ ] Tested on Windows Git Bash
- [ ] Added/updated tests
- [ ] Ran shellcheck

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings or errors
```

## Reporting Issues

### Security Issues

For security-related issues, please email security@yourproject.com instead of creating a public issue.

### Bug Reports

Use the bug report template and include:

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Run command '...'
2. See error

**Expected behavior**
What you expected to happen.

**Environment:**
- OS: [e.g. Ubuntu 20.04]
- Bash version: [e.g. 5.0.17]
- Script version: [e.g. 1.0.0]

**Additional context**
Add any other context about the problem here.
```

## Getting Help

- **Documentation**: Check the README and this guide first
- **Discussions**: Use GitHub Discussions for questions
- **Issues**: Create an issue for bugs or feature requests
- **Email**: Contact maintainers at support@yourproject.com

## Recognition

Contributors will be recognized in:
- CHANGELOG.md file
- GitHub contributors section
- Release notes for significant contributions

Thank you for contributing to making backups easier and more reliable for everyone! 🙏