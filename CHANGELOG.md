<a name="unreleased"></a>
## [Unreleased]

### Documentation
- add doctest that shows we can ignore based pattern match for the module ([#12](https://github.com/hauleth/mix_unused/issues/12)) ([`786d0ec`](https://github.com/hauleth/mix_unused/commit/786d0ec794e0116c61af9a118824c72b862b671d))


<a name="v0.2.1"></a>
## [v0.2.1] - 2021-10-13
### Bug Fixes
- properly fail when the severity is high enough ([`762ae41`](https://github.com/hauleth/mix_unused/commit/762ae41361bae297b10b431ffc6e31e69d9978e8))
- relicense to MIT ([`ab8eeea`](https://github.com/hauleth/mix_unused/commit/ab8eeea5d7e2b4d98de85e3c51855bebc7d66058))
- older Erlang versions do not provide doc chunk ([`fc087eb`](https://github.com/hauleth/mix_unused/commit/fc087eb99fcce0fcab3646965e9e28c4507030a4))
- use documentation chunk for extracting callbacks ([`6f7b14e`](https://github.com/hauleth/mix_unused/commit/6f7b14e9fe134b6d1e78b5cca5eb8a8a1df6de40))

### Documentation
- fix escaping in the task documentation ([`d5dce78`](https://github.com/hauleth/mix_unused/commit/d5dce78446efb43e7490811db03d957e25a9e228))


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


[Unreleased]: https://github.com/hauleth/mix_unused/compare/v0.2.1...HEAD
[v0.2.1]: https://github.com/hauleth/mix_unused/compare/v0.2.0...v0.2.1
[v0.2.0]: https://github.com/hauleth/mix_unused/compare/v0.1.0...v0.2.0
