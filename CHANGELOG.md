# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

### Added

- Add Class `DefinitionManager`.

### Removed

- Remove helper function `utils.scan_oarg()`, use [lparse](https://www.ctan.org/pkg/lparse) instead.

## [0.13.0] - 2023-01-13

### Added

- New function `utils.log.get()` to get the current log level.
- New function `utils.tex_printf()`: Combines `tex.print()` and Lua’s
  `string.format()`.
- More type annotations for better syntax highlighting when used with
  the [lua-language-server](https://github.com/sumneko/lua-language-server)
- Documentation for the `error_messages` table.

### Changed

- Rename the function `utils.log.set_log_level()` into `utils.log.set()`

### Fixed

- Keys with the attribute `opposite_keys` always got a value, even if
  the key wasn’t set.

## [0.12.0] - 2023-01-05

### Added

- Macros `\LuakeysGetPackageOptions`, `\LuakeysGetClassOptions`.
- Option `accumulated_result`.
- Data type `list` to the attribute `data_type`.
- Attribute `description`.
- Tables `utils.log` and `utils.ansi_color`.
- Table `errors_message` to set custom messages.
- Short form syntax for the definition attribute `opposite_keys`.

### Changed

- Breaking change! luakeys exports now a function instead of a table.
  Use `require('luakeys')()` or `luakeys.new()` instead of
  `require('luakeys')`.
- Breaking change! `luakeys.parse()`, `luakeys.define()`, `luakeys.save()`
  and `luakeys.get()` can’t be used anymore from the global variable
  luakeys.
- New name for the function `new()` instead of `get_private_instance()".

## [v0.11.0] - 2022-12-23

### Added

- Add a new function called `get_private_instance()` to load a private
  version of the luakeys module.

## [v0.10.0] - 2022-12-16

### Added

- Add support for an invert flat that flips the value of naked keys.
- Add new options to specify which strings are recognized as Boolean
  values.

## [v0.9.0] - 2022-11-21

### Added

- Add a new function called `any(value)` in the `is` table that accepts
  any data type.

### Changed

- The definition attibute `pick` accepts a new data type: `any`.
- The attribute `pick` accepts now multiple data types specified in
  a table.

### Deprecated

- The attribute value `true` for the attribute `pick` is deprecated.

## [v0.8.0] - 2022-11-17

### Added

- Add 6 new options to change the delimiters: `assignment_operator`,
  `group_begin`, `group_end`, `list_separator`, `quotation_begin`,
  `quotation_end`.
- Extend the documentation about the option `format_keys`.

## [v0.7.0] - 2022-07-06

### Added

- New definition attribute `pick` to pick standalone values and assign
  them to a key.
- New function `utils.scan_oarg()` to search for an optional argument,
  that means scan for tokens that are enclosed in square brackets.

### Changed

- The project now uses semantic versioning.
- Extend and improve the documentation.

## [v0.6.0] - 2022-06-09

### Added

- New feature: keys now can be defined using the function
  `define(defs, opts)` or `define(kv_string, { defs = { key = { ... } } })`
- New option `format_keys`.

### Changed

- Rename the global options table from `default_options` to `opts`.
- The default value of the option `convert_dimension` is now false.
- The option `standalone_as_true` is renamed to `naked_as_value`.
  The boolean value of the option must be changed to the opposite to.
  produce the previous effect.
- The function `print()` is now called `debug()`.

### Removed

- Remove option `case_insensitive_keys`. Use
  `format_keys = { lower }` to achieve the same effect.

## [v0.5.0] - 2022-04-04

### Added

- Add possibility to change options globally.
- New option: standalone_as_true.
- Add a recursive converter callback / hook to process the parse tree.
- New option: case_insensitive_keys.

## [v0.4.0] - 2021-12-31

### Added

- Parser: Add support for nested tables (for example `{{'a', 'b'}}`).
- Parser: Allow only strings and numbers as keys.

### Changed

- Switch the Lua testing framework to busted.

### Removed

- Parser: Remove support from Lua numbers with exponents (for example '5e+20').

## [v0.3.0] - 2021-11-05

### Added

- Add a LuaLaTeX wrapper `luakeys.sty`.
- Add a plain LuaTeX wrapper `luakeys.tex`.

### Changed

- Rename the previous documentation file `luakeys.tex` to luakeys-doc.tex`.

## [v0.2.0] - 2021-09-19

### Added

- New public Lua functions: save(identifier, result), get(identifier).

### Changed

- Allow all recognized data types as keys.
- Allow TeX macros in the values.

## [v0.1.0] - 2021-01-18

### Added

- Inital release
