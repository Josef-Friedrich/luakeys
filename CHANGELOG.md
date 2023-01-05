# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `utils.log.get()`

### Changed

- `utils.log.set_log_level()` -> `utils.log.set()`

### Fixed

- ...

## [0.12.0] - 2023-01-05

### Added

- Macros \LuakeysGetPackageOptions, \LuakeysGetClassOptions.
- Option “accumulated_result”.
- Data type “list” to the attribute “data_type”.
- Attribute “description”.
- Tables “utils.log” and “utils.ansi_color”.
- Table “errors_message” to set custom messages.
- Short form syntax for the definition attribute “opposite_keys”.

### Changed

- Breaking change! luakeys exports now a function instead of a table.
  Use “require('luakeys')()” or “luakeys.new()” instead of
  “require('luakeys')”.
- Breaking change! “luakeys.parse()”, “luakeys.define()”, “luakeys.save()”
  and “luakeys.get()” can’t be used anymore from the global variable luakeys.
- New name for the function “new()” instead of “get_private_instance()".
