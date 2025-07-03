# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive documentation with examples and troubleshooting
- Contributing guidelines and development setup instructions
- MIT License for open source distribution
- Cross-platform compatibility documentation

### Changed
- Enhanced README with detailed usage examples
- Improved project structure and documentation organization

## [1.0.0] - 2024-01-01

### Added
- Initial release of bash backup script
- Timestamped backup archives using tar.gz compression
- Comprehensive logging with timestamps
- Support for both files and directories
- Cross-platform compatibility (Linux, macOS, Windows Git Bash)
- Error handling and validation
- Basic usage examples

### Features
- Creates compressed backups with timestamps in format `YYYY-MM-DD_HH-MM-SS`
- Logs all backup operations to `backup.log`
- Validates input arguments before processing
- Supports automation via cron jobs and task schedulers
- Compatible with Windows through Git Bash

---

## Release Types

- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** for vulnerability fixes

## Version Numbering

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible API changes
- **MINOR** version for new functionality in a backwards compatible manner
- **PATCH** version for backwards compatible bug fixes