# Standard DevOps Framework

Standard is a Nix Flakes-based DevOps framework that organizes your development lifecycle into Cells (folders) and Cell Blocks (Nix files). It provides a CLI/TUI for discovering and running targets across the entire SDLC.

**ALWAYS follow these instructions first and fallback to search or exploration commands only when you encounter unexpected information that does not match the information here.**

## Working Effectively

### Prerequisites and Installation
- **CRITICAL**: Install Nix package manager first:
  ```bash
  curl -L https://nixos.org/nix/install | sh
  ```
  or use the Determinate Systems installer:
  ```bash
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  ```
- Install direnv for automatic environment loading:
  ```bash
  # See https://direnv.net/docs/installation.html for your platform
  curl -sfL https://direnv.net/install.sh | bash
  ```
- Configure your shell for direnv (add to `.bashrc`/`.zshrc`):
  ```bash
  eval "$(direnv hook bash)"  # or zsh
  ```

### Environment Setup and Entry
- **ALWAYS** start by entering the development environment:
  ```bash
  direnv allow
  ```
  **First time takes 5-15 minutes** - NEVER CANCEL. This downloads and builds the development dependencies.
- Alternative environment entry (if direnv fails):
  ```bash
  direnv allow || nix develop -c "$SHELL"
  ```
  **Takes 5-15 minutes** - NEVER CANCEL.
- **After making changes to Nix files**, reload the environment:
  ```bash
  direnv reload
  ```
- **Verify environment loaded correctly**:
  ```bash
  std --help  # Should show Standard CLI help
  ```

### Build Commands
- **Build the entire project** - NEVER CANCEL: Build takes 10-30 minutes. Set timeout to 45+ minutes:
  ```bash
  nix build
  ```
- **Build and check all flake outputs** (includes tests):
  ```bash
  nix flake check
  ```
  **Takes 15-45 minutes** - NEVER CANCEL. Set timeout to 60+ minutes.
- **Build specific targets** using the Standard CLI:
  ```bash
  std  # Launch the TUI to see available targets
  std //local/shells:default  # Build specific target
  ```
- **Verify build without execution**:
  ```bash
  nix build --dry-run
  ```

### Testing
- **Run snapshot tests** - NEVER CANCEL: Tests take 5-15 minutes. Set timeout to 30+ minutes:
  ```bash
  namaka check
  # or via Standard CLI:
  std //tests/checks/snapshots:eval
  ```
- **Run all CI checks** as they would run in GitHub Actions:
  ```bash
  nix flake check
  ```
  **Takes 15-45 minutes** - NEVER CANCEL. Set timeout to 60+ minutes.

### Formatting and Linting
- **ALWAYS run formatting before committing** (CI will fail otherwise):
  ```bash
  treefmt
  ```
- **Format only changed files**:
  ```bash
  treefmt $(git diff --name-only --cached)
  ```
- **License compliance check** (required for CI):
  ```bash
  reuse lint
  ```

## Validation

### Manual Validation Requirements
**ALWAYS run these validation steps after making changes:**

1. **Environment validation**: Verify the development environment loads correctly:
   ```bash
   direnv reload && echo "Environment loaded successfully"
   ```

2. **Build validation**: Ensure the project builds successfully:
   ```bash
   nix build && echo "Build completed successfully"
   ```

3. **Standard CLI validation**: Test the CLI functionality:
   ```bash
   std --help  # Should show help without errors
   std  # Should launch TUI - exit with 'q'
   ```

4. **Test validation**: Run the test suite:
   ```bash
   namaka check && echo "All tests passed"
   ```

5. **Documentation validation**: If docs were modified, build them:
   ```bash
   mdbook build  # Builds to docs/book/
   ```
   **Takes 2-5 minutes** - do not cancel.

### Critical Validation Scenarios
After making code changes, ALWAYS test these complete workflows:

1. **Fresh environment setup** (simulates new contributor):
   ```bash
   direnv disallow && direnv allow
   # Should complete without errors in 5-15 minutes
   ```

2. **Full development cycle**:
   ```bash
   # Make a trivial change, then:
   treefmt                    # Format code
   nix build                  # Build project  
   namaka check               # Run tests
   reuse lint                 # Check licenses
   ```

3. **Template functionality** (if templates were modified):
   ```bash
   nix flake init -t .#minimal /tmp/test-project
   cd /tmp/test-project && direnv allow
   # Should work without errors - takes 5-15 minutes first time
   ```

## Common Tasks

### Repository Structure
```
.
├── .envrc                  # direnv configuration - auto-loads dev environment
├── flake.nix              # Main Nix flake definition - project entry point  
├── dogfood.nix            # Project self-configuration - how std uses itself
├── src/
│   ├── local/             # Local development environment
│   │   ├── shells.nix     # Development shells - FREQUENTLY MODIFIED
│   │   ├── configs.nix    # Tool configurations (treefmt, nixago, etc.)
│   │   └── tasks.nix      # Automation tasks
│   ├── std/               # Standard framework core - MAIN CODEBASE
│   │   ├── fwlib/         # Framework library - core abstractions
│   │   │   ├── actions/   # Build/run actions for targets
│   │   │   └── blockTypes/ # Cell Block type definitions
│   │   ├── cli.nix        # CLI/TUI implementation
│   │   └── templates/     # Project templates
│   └── tests/             # Test suites - snapshot tests
├── docs/                  # Documentation source (mdbook)
│   ├── explain/           # Why Nix? Why Standard? 
│   ├── tutorials/         # Step-by-step guides
│   ├── guides/            # How-to guides
│   └── reference/         # API documentation
└── .github/workflows/     # CI/CD pipelines - uses std-action
```

### Frequently Modified Files
- `src/local/shells.nix` - Add tools, modify dev environment
- `src/local/configs.nix` - Configure treefmt, linting, nixago tools
- `src/std/fwlib/blockTypes/` - Extend Standard with new block types
- `src/std/templates/` - Add/modify project templates  
- `docs/` - Documentation updates
- `flake.nix` - Project inputs and core configuration

### Standard Framework Concepts
- **Cells**: Folders that group related functionality (e.g., `local`, `std`, `tests`)
- **Cell Blocks**: Nix files that define outputs (e.g., `shells.nix`, `packages.nix`)
- **Targets**: Individual functions/packages within Cell Blocks
- **Actions**: Operations you can perform on targets (build, run, etc.)

### Key Commands Reference
```bash
# Environment
direnv allow              # Enter dev environment (5-15 min first time)
direnv reload            # Reload after changes
nix develop             # Alternative environment entry

# Building  
nix build               # Build everything (10-30 min, NEVER CANCEL)
std                     # Launch TUI to see targets
std //local/shells:default  # Build specific target

# Testing
namaka check            # Run snapshot tests (5-15 min, NEVER CANCEL)
nix flake check         # Run all checks (15-45 min, NEVER CANCEL)

# Formatting & Linting
treefmt                 # Format all files (REQUIRED before commit)
reuse lint              # Check license compliance

# Documentation
mdbook build            # Build documentation (2-5 min)
mdbook serve            # Serve docs locally at localhost:3000
```

### File Watching and Live Reload
- The `.envrc` file automatically watches relevant Nix files for changes
- When you modify shell configurations, direnv will prompt to reload
- Documentation can be live-reloaded: `mdbook serve`

### Troubleshooting
- **"command not found: std"**: Run `direnv reload` or `nix develop -c "$SHELL"`
- **Build failures**: Check `nix log` output for specific errors; try `nix build --show-trace` for more details
- **Slow builds**: This is normal for Nix - do not cancel, builds are cached after first success
- **direnv not working**: Ensure direnv is installed and shell hook is configured
- **Network errors during setup**: Some dependencies require internet access; check firewall/proxy settings
- **Flake lock issues**: In subflakes, run `./.github/workflows/update-subflake.sh` to update lock files
- **"error: getting status of '/nix/store/...'**: Usually means incomplete download; try `nix build` again
- **Out of disk space**: Nix store can get large; run `nix-collect-garbage` to clean up

### Performance Notes
- **First-time setup**: Expect 5-15 minutes for initial environment build
- **Subsequent environment loads**: Usually under 30 seconds due to Nix caching
- **Full builds**: 10-30 minutes depending on what changed
- **Tests**: 5-15 minutes for complete test suite
- **CI builds**: 15-45 minutes for full CI pipeline

**CRITICAL TIMING REMINDERS:**
- **NEVER CANCEL** any nix build, test, or environment setup commands
- Always set timeouts to at least 2x the expected time
- Use `timeout` values of 60+ minutes for builds and 30+ minutes for tests
- If a command appears stuck, wait at least 15 minutes before investigating

### Integration with CI
- All formatting and linting must pass for CI to succeed
- CI uses the same Standard framework via `divnix/std-action`
- Local validation with `nix flake check` mirrors CI exactly
- Always run `treefmt` and `reuse lint` before pushing
- **CI timing expectations**: Full CI takes 15-45 minutes across multiple platforms (Linux/macOS)

### Common Development Patterns

#### Adding a new tool to the development environment:
1. Edit `src/local/shells.nix` 
2. Add package to `commands` list with appropriate category
3. Run `direnv reload` to update environment
4. Test with the new tool available

#### Modifying Standard framework behavior:
1. Core logic in `src/std/fwlib/` 
2. Block types in `src/std/fwlib/blockTypes/`
3. Actions in `src/std/fwlib/actions/`
4. Always run full test suite after changes

#### Working with documentation:
1. Source in `docs/` using mdbook format
2. Live preview: `mdbook serve` at localhost:3000
3. Build: `mdbook build` outputs to `docs/book/`
4. Documentation includes auto-generated API docs via paisano-preprocessor

#### Template development:
1. Templates in `src/std/templates/`
2. Test with: `nix flake init -t .#<template-name> /tmp/test`
3. Verify template works: `cd /tmp/test && direnv allow`