use std::{env, fs};
use zed_extension_api::{self as zed, settings::LspSettings, LanguageServerId, Result};

const SERVER_PATH: &str = "node_modules/basedpyright/langserver.index.js";
const PACKAGE_NAME: &str = "basedpyright";

/// Xonsh language extension for Zed
///
/// Provides xonsh shell script support by:
/// - Using Python's tree-sitter grammar (xonsh is a Python superset)
/// - Integrating with basedpyright for language server features
struct XonshExtension {
    cached_binary_path: Option<String>,
}

impl XonshExtension {
    fn server_exists(&self) -> bool {
        fs::metadata(SERVER_PATH).is_ok_and(|stat| stat.is_file())
    }

    fn server_script_path(&mut self, language_server_id: &LanguageServerId) -> Result<String> {
        // Check for cached path first
        if let Some(path) = &self.cached_binary_path {
            if self.server_exists() {
                return Ok(path.clone());
            }
        }

        zed::set_language_server_installation_status(
            language_server_id,
            &zed::LanguageServerInstallationStatus::CheckingForUpdate,
        );

        let version = zed::npm_package_latest_version(PACKAGE_NAME)?;

        if !self.server_exists()
            || zed::npm_package_installed_version(PACKAGE_NAME)?.as_ref() != Some(&version)
        {
            zed::set_language_server_installation_status(
                language_server_id,
                &zed::LanguageServerInstallationStatus::Downloading,
            );
            let result = zed::npm_install_package(PACKAGE_NAME, &version);
            match result {
                Ok(()) => {
                    if !self.server_exists() {
                        Err(format!(
                            "installed package '{PACKAGE_NAME}' did not contain expected path '{SERVER_PATH}'",
                        ))?;
                    }
                }
                Err(error) => {
                    if !self.server_exists() {
                        Err(error)?;
                    }
                }
            }
        }

        self.cached_binary_path = Some(SERVER_PATH.to_string());
        Ok(SERVER_PATH.to_string())
    }
}

impl zed::Extension for XonshExtension {
    fn new() -> Self {
        Self {
            cached_binary_path: None,
        }
    }

    fn language_server_command(
        &mut self,
        language_server_id: &LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<zed::Command> {
        // Check for user-configured binary path
        let binary_settings = LspSettings::for_worktree(language_server_id.as_ref(), worktree)
            .ok()
            .and_then(|lsp_settings| lsp_settings.binary);

        let binary_args = binary_settings
            .as_ref()
            .and_then(|settings| settings.arguments.clone());

        // Use configured path if provided
        if let Some(path) = binary_settings.and_then(|settings| settings.path) {
            return Ok(zed::Command {
                command: path,
                args: binary_args.unwrap_or_else(|| vec!["--stdio".to_string()]),
                env: Default::default(),
            });
        }

        // Try to find basedpyright-langserver in PATH
        if let Some(path) = worktree.which("basedpyright-langserver") {
            return Ok(zed::Command {
                command: path,
                args: binary_args.unwrap_or_else(|| vec!["--stdio".to_string()]),
                env: Default::default(),
            });
        }

        // Fall back to npm-installed version
        let server_path = self.server_script_path(language_server_id)?;
        let server_path = env::current_dir()
            .unwrap()
            .join(&server_path)
            .to_string_lossy()
            .to_string();

        Ok(zed::Command {
            command: zed::node_binary_path()?,
            args: vec![server_path, "--stdio".to_string()],
            env: Default::default(),
        })
    }

    fn language_server_workspace_configuration(
        &mut self,
        server_id: &LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<Option<zed::serde_json::Value>> {
        let settings = LspSettings::for_worktree(server_id.as_ref(), worktree)
            .ok()
            .and_then(|lsp_settings| lsp_settings.settings)
            .unwrap_or_default();
        Ok(Some(settings))
    }

    fn language_server_initialization_options(
        &mut self,
        server_id: &LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<Option<zed::serde_json::Value>> {
        let init_options = LspSettings::for_worktree(server_id.as_ref(), worktree)
            .ok()
            .and_then(|lsp_settings| lsp_settings.initialization_options);
        Ok(init_options)
    }
}

zed::register_extension!(XonshExtension);
