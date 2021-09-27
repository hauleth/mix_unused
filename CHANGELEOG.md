<a name="v0.2.0"></a>
## v0.2.0 - 2021-09-27

### Chore
- release v0.2.0
- add Credo
- fix formatting
- split code into modules for easier testing

### Docs
- improve documentation of `compile.unused`

### Fix
- print path to file as a relative path
- test against "textual" representation of atoms as well

### Ft
- add support for macros
- sort results to return predictable results
- allow filtering using regular expressions


<a name="v0.1.0"></a>
## v0.1.0 - 2021-08-28
### Chore
- prepare first release
- add GitHub Actions

### Docs
- write documentation and provide basic options

### Feat
- simplify matching patterns by allow just atoms and 2-ary tuples
- update filtering
- add module.behaviour_info/1 to list of ignored built ins

### Fix
- ignore additional flags
- remove inspect

### Ft
- migrate to compiler tracers

### Pull Requests
- Merge pull request [#3](https://github.com/hauleth/mix_unused/issues/3) from hauleth/chore/add-ci-actions
- Merge pull request [#2](https://github.com/hauleth/mix_unused/issues/2) from hauleth/ft/migrate-to-compiler-tracers


[Unreleased]: https://github.com/hauleth/mix_unused/compare/v0.1.0...HEAD
