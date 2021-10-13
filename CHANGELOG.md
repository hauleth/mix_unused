<a name="unreleased"></a>
## [Unreleased]

### Bug Fixes
- properly fail when the severity is high enough
- relicense to MIT
- older Erlang versions do not provide doc chunk
- use documentation chunk for extracting callbacks

### Documentation
- fix escaping in the task documentation


<a name="v0.2.0"></a>
## [v0.2.0] - 2021-09-27
### Bug Fixes
- print path to file as a relative path ([`44264a2`](https://github.com/hauleth/mix_unused/commit/44264a2b30e91b038194fd7fa2d43f2ba0740947))
- test against "textual" representation of atoms as well ([`b2faff2`](https://github.com/hauleth/mix_unused/commit/b2faff2ec34b952b21de192f4f557b6032a6a296))

### Documentation
- improve documentation of `compile.unused` ([`a16b2a4`](https://github.com/hauleth/mix_unused/commit/a16b2a48fb458341e4e722c18f4aae588b0bc274))

### Features
- add support for macros ([`a28a339`](https://github.com/hauleth/mix_unused/commit/a28a339d916a146f1d74fbf783e6fe27589ee6a7))
- sort results to return predictable results ([`3ad4b79`](https://github.com/hauleth/mix_unused/commit/3ad4b792f1e8c0af70fc0fc75f8479262da56291))
- allow filtering using regular expressions ([`3f39f90`](https://github.com/hauleth/mix_unused/commit/3f39f907b9f0129aeafc9da336b25ef04b804d28))


<a name="v0.1.0"></a>
## v0.1.0 - 2021-08-28
### Bug Fixes
- ignore additional flags ([`4e74480`](https://github.com/hauleth/mix_unused/commit/4e744800656aa31d49992a9a97424bbc3555c844))
- remove inspect ([`b2036d8`](https://github.com/hauleth/mix_unused/commit/b2036d858953d758bab691b79f75ddee3b4a72e9))

### Documentation
- write documentation and provide basic options ([`a71ef2e`](https://github.com/hauleth/mix_unused/commit/a71ef2ebbd1c475648d931ebea162778328379d1))

### Features
- migrate to compiler tracers ([`e3fda01`](https://github.com/hauleth/mix_unused/commit/e3fda011f43392f6091e5a46a9ead93bdb3eb08a))

### Features
- simplify matching patterns by allow just atoms and 2-ary tuples ([`7d10f78`](https://github.com/hauleth/mix_unused/commit/7d10f7898e6e4693ac09678b5f7ec19c40018c31))
- update filtering ([`7c4717b`](https://github.com/hauleth/mix_unused/commit/7c4717b70461f993cdc782af34a75c5867100523))
- add module.behaviour_info/1 to list of ignored built ins ([`df2f7e2`](https://github.com/hauleth/mix_unused/commit/df2f7e2209f5ee229d9c3c5efe3ee5c9b40f3261))


[Unreleased]: https://github.com/hauleth/mix_unused/compare/v0.2.0...HEAD
[v0.2.0]: https://github.com/hauleth/mix_unused/compare/v0.1.0...v0.2.0
