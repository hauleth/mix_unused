<a name="unreleased"></a>
## [Unreleased]


<a name="v0.2.0"></a>
## [v0.2.0] - 2021-09-27
### Docs
- improve documentation of `compile.unused`

### Bug Fixes
- print path to file as a relative path
- test against "textual" representation of atoms as well

### Features
- add support for macros
- sort results to return predictable results
- allow filtering using regular expressions

### Pull Requests
- Merge pull request [#9](https://github.com/hauleth/mix_unused/issues/9) from hauleth/ft/support-elixir-macros
- Merge pull request [#8](https://github.com/hauleth/mix_unused/issues/8) from hauleth/ft/filter-using-regular-expressions


<a name="v0.1.0"></a>
## v0.1.0 - 2021-08-28
### Bug Fixes
- ignore additional flags
- remove inspect

### Features
- migrate to compiler tracers

### Features
- simplify matching patterns by allow just atoms and 2-ary tuples
- update filtering
- add module.behaviour_info/1 to list of ignored built ins

### Docs
- write documentation and provide basic options

### Pull Requests
- Merge pull request [#3](https://github.com/hauleth/mix_unused/issues/3) from hauleth/chore/add-ci-actions
- Merge pull request [#2](https://github.com/hauleth/mix_unused/issues/2) from hauleth/ft/migrate-to-compiler-tracers


[Unreleased]: https://github.com/hauleth/mix_unused/compare/v0.2.0...HEAD
[v0.2.0]: https://github.com/hauleth/mix_unused/compare/v0.1.0...v0.2.0
