# Changelog
All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

- - -
## [v0.30.0](https://github.com/divnix/std/compare/v0.24.0-1..v0.30.0) - 2024-02-17
#### Bug Fixes
- **(kubectl)** diff action and differ command - ([460d53a](https://github.com/divnix/std/commit/460d53a02f290656926b85d912885496050aa62a)) - David Arnold
- **(namaka)** snapshots can change or be generated within std - ([3dca8ed](https://github.com/divnix/std/commit/3dca8edd82ff100878ff0797f67abda629ca8686)) - pegasust
- update the tui for faster builds and to honor lates prj-spec - ([f8e50fa](https://github.com/divnix/std/commit/f8e50faea94509a140ffaf1f9290d4f2798467da)) - David Arnold
- for cog patch release flow - ([bb58aa6](https://github.com/divnix/std/commit/bb58aa6465e6ed1811c26f752e04ad895bc28011)) - David Arnold
- Improve readability of terraform errors - ([9811737](https://github.com/divnix/std/commit/981173777b30972d47ee7b1a22d8bea62e72526f)) - dantefromhell
- quoting of PRJ_PATH/fragment for installables - ([403fd2a](https://github.com/divnix/std/commit/403fd2a949c60fc358be4f7d7ecfb435960b8464)) - Peter Kolloch
- required input lazy on lib - ([a78e6e8](https://github.com/divnix/std/commit/a78e6e88749aa794df4a44aeb2a6508976efdd72)) - David Arnold
- cocogitto cli name in devshell menu - ([a392e57](https://github.com/divnix/std/commit/a392e57b5105bff9990d4dbab9562f2de19fb50d)) - David Arnold
- haumea-style fined to only support scopedImport to avoid ambiguity - ([1d324dc](https://github.com/divnix/std/commit/1d324dca051d263d5e9127304b8a8b72f814b9ae)) - David Arnold
- broken `lib` follows - ([62db3df](https://github.com/divnix/std/commit/62db3df916295dfafda87ba23b14baed1a73e360)) - li
- ease copy paste on require input warning - ([f6e09ec](https://github.com/divnix/std/commit/f6e09ec263882498891690adb070db6fb7926c21)) - David Arnold
- prepare for potential future changes in drv output selection fragment - ([609ea5e](https://github.com/divnix/std/commit/609ea5e46c3d386c188f23a0aede3da6ad574e06)) - David Arnold
#### Continuous Integration
- update nix install action on gh workflow - ([b71778b](https://github.com/divnix/std/commit/b71778b73869829e0f9ca184bc387ec036680759)) - David Arnold
- Create flakehub-publish-tagged.yml - ([20d6292](https://github.com/divnix/std/commit/20d62929c4369aa1e32d7845f9ebea975c53b314)) - David Arnold
#### Documentation
- Fix typo - ([845fd29](https://github.com/divnix/std/commit/845fd2960e312be6e60f49b9f5799ac4f180a111)) - dantefromhell
#### Features
- **(blocktypes/namaka)** allow overriding of subdir - ([66ae24b](https://github.com/divnix/std/commit/66ae24b6086d56d535dc45df895a4773a3ccf0a6)) - pegasust
- **(kubectl)** publish diff if on github ci as PR comment - ([16edd0f](https://github.com/divnix/std/commit/16edd0fc1e98c28180d845ef1011610f7b800976)) - David Arnold
- add nixostests block type - ([d54ba55](https://github.com/divnix/std/commit/d54ba550ba0b68de0f3656ce0b41fb353d3f9298)) - David Arnold
- add haumea-style target finder - ([2494dda](https://github.com/divnix/std/commit/2494dda05eb8e3237f747749144e4aa55bbbfe72)) - David Arnold
- upd paistano tui with some a fix on targets w/ dots in the name - ([1ba107b](https://github.com/divnix/std/commit/1ba107b3a169862fb18fc0fa375866eceb850a60)) - David Arnold
- update paisano core w/ growOn registry list merge improvement - ([0f6abce](https://github.com/divnix/std/commit/0f6abce9bea414424ddb871cfb0037f1a93d68f8)) - David Arnold
#### Miscellaneous Chores
- **(gh-pages)** acquire flake.lock pls - ([b4e0dd9](https://github.com/divnix/std/commit/b4e0dd99ba49f7d26a6f0f17c3c225bfed66e85d)) - pegasust
- ensure a single lib input - ([0ce59ac](https://github.com/divnix/std/commit/0ce59ac671f041183da72e7cd5db9c6eb878e326)) - David Arnold
- remove dead code - ([927807f](https://github.com/divnix/std/commit/927807fc745e158b05b8c7daa733b9412a6322f2)) - David Arnold
- ref CI, change link integrity - ([46878a2](https://github.com/divnix/std/commit/46878a216b4765529d548a09f1746fc27fe47eaf)) - pegasust
- fix gh pages - ([5e7724e](https://github.com/divnix/std/commit/5e7724eb07c8a334e1185e244bf37f4353a867cb)) - pegasust
#### Refactoring
- use findTargets for lib.ops - ([5c6d67b](https://github.com/divnix/std/commit/5c6d67b34c1092f73a5711717e7bac3643478696)) - David Arnold
- use findTargets for lib.dev - ([37eed5c](https://github.com/divnix/std/commit/37eed5c593a8835758e0e09ca042129d81038d53)) - David Arnold
- use findTargets for lib.cfg - ([e9a5684](https://github.com/divnix/std/commit/e9a56845dd7704f972c4e9a2bc2dc18141e0731f)) - David Arnold
- use findTargets for data.configs - ([2033271](https://github.com/divnix/std/commit/20332712304177602ef232786f21c6c010ebcc40)) - David Arnold
- mix std into the dogfood - ([9a2f54e](https://github.com/divnix/std/commit/9a2f54e0e337049f18776db46b1ae9aaa582023b)) - David Arnold
- normalize configs - ([ba79869](https://github.com/divnix/std/commit/ba798696543776c7264c31a675da1d0636e49029)) - David Arnold
- use local config data sets - ([6e058d7](https://github.com/divnix/std/commit/6e058d73d478c4bdefba7548ce9ed01f2d6e0f07)) - David Arnold
- bring back config data sets - ([12b5eb8](https://github.com/divnix/std/commit/12b5eb8912abeec2de3dd10575a8c4432bb5bef8)) - David Arnold
#### Tests
- update snapshot with new tui source - ([4f1a213](https://github.com/divnix/std/commit/4f1a213b6fda8557edae1b56b85a574a1d7b1daf)) - David Arnold
- add snapshot for new nixostests block type - ([edbcecd](https://github.com/divnix/std/commit/edbcecdc9b18c4824d02bd655fd865557024fb6d)) - David Arnold
- update snapshot - ([d53faa8](https://github.com/divnix/std/commit/d53faa8a13af66086499ce9a632e2cf560180162)) - Juanjo Presa
- review and accept new lib.cfg snapshot - ([4a52824](https://github.com/divnix/std/commit/4a528247a3253fa9d57cc7c7387c012307ca6315)) - David Arnold

- - -

## [v0.24.0-1](https://github.com/divnix/std/compare/v0.23.2..v0.24.0-1) - 2023-08-15
#### Bug Fixes
- **(blockTypes)** don't try to be too smart with kubctl & nomad rendering - ([f0a9a55](https://github.com/divnix/std/commit/f0a9a558b23e9ab4d95907f3d0e8dc6883397cc9)) - David Arnold
- **(blockTypes/kubectl)** fix and adapt for use with kustomize - ([7ace4d2](https://github.com/divnix/std/commit/7ace4d2f29cfcde11ca0bbc549ca73c893b8bd98)) - David Arnold
- **(blockTypes/kubectl)** polish off the kubectl block type - ([fb34532](https://github.com/divnix/std/commit/fb34532b5a72f99f9b1f397adb5e18f0fb255d80)) - David Arnold
- **(blockTypes/terra)** shellcheck oversight - ([8106154](https://github.com/divnix/std/commit/8106154c54a7a60ec26717021d92d5b958e73ada)) - David Arnold
- **(direnv/lib)** fix to upstream prj-spec direnv implementation - ([53c435a](https://github.com/divnix/std/commit/53c435a0930be2bc43b5160beb286cc02435c9af)) - David Arnold
- **(fwlib/blockTypes/nixago)** renamed attribute of internal api - ([9ebb1f6](https://github.com/divnix/std/commit/9ebb1f688ddf722096a98398df68e378256d340b)) - David Arnold
- **(lib/ops)** ensure the getName contract is uphold for operables - ([17dc4eb](https://github.com/divnix/std/commit/17dc4eb9587517397dad00617b020769fece3cfe)) - David Arnold
- **(lib/ops)** tag defaulting while forwarding mkStandardOCI to mkOCI - ([301a649](https://github.com/divnix/std/commit/301a649b81276a0a11832b81a09956d0838da7ed)) - David Arnold
- **(templates/rust)** allow rust devshell startup to run 'direnv allow' multiple time - ([78675b5](https://github.com/divnix/std/commit/78675b58a6f95b7b7db3d8935afb09a83287a3ae)) - htran
- solve the path issue of mkDevOCI - ([ec2d87c](https://github.com/divnix/std/commit/ec2d87ca982a714c4d6c99ae04bcbdf33d5103ce)) - guangtao
- indentation would flip flop with typicall md formatters - ([3e62364](https://github.com/divnix/std/commit/3e623646d47ec277947c9626d595f43042b94ab9)) - David Arnold
- heal kubectl deploy action shellcheck - ([95b3280](https://github.com/divnix/std/commit/95b3280bec63b49db5d5fc62cd0536d096536b4f)) - David Arnold
- oversight in container proviso - ([de460f2](https://github.com/divnix/std/commit/de460f2515baccfff7bbb030049f078f051cd6ad)) - David Arnold
- typo that caused block types to fail - ([c95ae2e](https://github.com/divnix/std/commit/c95ae2e11c937484490158722f5a05547e5c4940)) - David Arnold
- container proviso inversed logic - ([f54da22](https://github.com/divnix/std/commit/f54da22d93407f3a2531a7e42d447f11d97e09b4)) - David Arnold
- flakeModule loading after refactoring - ([493e572](https://github.com/divnix/std/commit/493e57257601e76eb256c6ada37f770bf3c5dd72)) - David Arnold
- order matter for the registry, let ci pick up the local stuff - ([1b20a74](https://github.com/divnix/std/commit/1b20a742c5e5735b3c645d9359c0a450c5f25629)) - David Arnold
- requireInput nar hash for none-flake - ([d2614e5](https://github.com/divnix/std/commit/d2614e52e66cafc5b5979748223904facfbd1d64)) - David Arnold
- reduce std input bloat - ([e21ba36](https://github.com/divnix/std/commit/e21ba36cde8c0886320e96faf1f4409d9a47b728)) - David Arnold
- changed input signature on numitde/devshell on templates, too - ([54df16b](https://github.com/divnix/std/commit/54df16bd5a67de7a9ee6b2efb111b4f6e6c764df)) - David Arnold
- changed input signature on numitde/devshell - ([cef9c4b](https://github.com/divnix/std/commit/cef9c4b942f977e6aea766666495e9533eb3ca69)) - David Arnold
- proviso with substituter - ([0e06a70](https://github.com/divnix/std/commit/0e06a7069424f56835d4140da1ce2a09fe9666d4)) - David Arnold
- devshell harvest - ([0f49324](https://github.com/divnix/std/commit/0f4932419825d99a1523248ddafde0b176febfc6)) - David Arnold
- proviso - ([9339bb5](https://github.com/divnix/std/commit/9339bb5a0316a460dd873fe02baf7f6a41822134)) - David Arnold
#### Continuous Integration
- pin nix quick install actio to v25 - ([3c8b627](https://github.com/divnix/std/commit/3c8b627a3dd41e72a2a445717967f8e16213c46e)) - David Arnold
- use nix-quick-install-action master - ([afef95d](https://github.com/divnix/std/commit/afef95d9a7575a89535a9b78f576830a879ee02b)) - David Arnold
- no need to set fail-fast to false - ([1dcaf91](https://github.com/divnix/std/commit/1dcaf91bea501539478329e55db7e98c3fb35f43)) - David Arnold
- remove more lines - ([0a720e1](https://github.com/divnix/std/commit/0a720e111e2b27617f1cecb4bf441f42fd2e692a)) - David Arnold
- factorize subflake/superflake update - ([1da0e7a](https://github.com/divnix/std/commit/1da0e7a26a9849ea6ef47a11ffd3ca694328cbdd)) - David Arnold
- add concurrency setting to cancel previous on push to same ref - ([523b916](https://github.com/divnix/std/commit/523b916d3b485c4ba5116e70ec93be000e914979)) - David Arnold
- simplify jobname handling - ([1b29e7b](https://github.com/divnix/std/commit/1b29e7bf959d1f87eb172fe13f78157437ba8e92)) - David Arnold
- use upstream flake-related automatic setup - ([356b368](https://github.com/divnix/std/commit/356b36834d649ec224100ae559fdf43e95914b86)) - David Arnold
- use upstream flake-related configuration - ([7944dba](https://github.com/divnix/std/commit/7944dba93a9d0feb20ae5faeed599dafcce7b18e)) - David Arnold
- use new action default inputs (less verbose) - ([c4c4d01](https://github.com/divnix/std/commit/c4c4d017a147275d52de13e0c59048fd3fb85c3d)) - David Arnold
- polish a bit - ([762fa9c](https://github.com/divnix/std/commit/762fa9c1d9baa0954cda209483dd9c331df8529d)) - David Arnold
- fix shell builds - ([861d930](https://github.com/divnix/std/commit/861d9307dfd0108fd14cf4f04b21562fff7dd251)) - David Arnold
- hakishly have subflake use superflake as input - ([d2129fd](https://github.com/divnix/std/commit/d2129fd38fe5f4035a8763e6dbe29405b32b2388)) - David Arnold
#### Features
- **(blocktypes)** add terra - ([04990e2](https://github.com/divnix/std/commit/04990e2b6b61f03c6e319716fed5b5aa04cf643a)) - David Arnold
- **(presets/templates/rust)** void unused transitive inputs - ([53a3211](https://github.com/divnix/std/commit/53a321136cadb53316c129d7a5bdcd12d46b1bd7)) - figsoda
- **(std/errors)** add bail-on-dirty warning - ([b5f0b4d](https://github.com/divnix/std/commit/b5f0b4da186ba0fb0841dd4d076fc31089f41990)) - David Arnold
- **(std/fwlib/blockTypes/kubctl)** add new block type w/o proviso - ([e0cde04](https://github.com/divnix/std/commit/e0cde0457aa3a2050022f3f519ddfecb01ef0445)) - David Arnold
- add magic cache - ([7ad8602](https://github.com/divnix/std/commit/7ad8602092f8bafe61fcd68b4f81ed5d4bf6a97b)) - David Arnold
- simplify std-action - ([1dbe033](https://github.com/divnix/std/commit/1dbe0331e723b24d7e7cfdb876bc05c8ea66d5c1)) - David Arnold
- simplify proviso - ([e4b9ae7](https://github.com/divnix/std/commit/e4b9ae73bda29a90f3332bcccf2fc687306f1e6e)) - David Arnold
- action adopt cell's inputs - ([b7a2649](https://github.com/divnix/std/commit/b7a26498fb18678b51719f54b301fb3b5b46e1ad)) - David Arnold
- move input overloading to subflake & shrink std input footprint - ([b542631](https://github.com/divnix/std/commit/b5426310bdf4bf06f249796dc1650c67f5587eaa)) - David Arnold
- check for PRJ spec on all actions - ([4c571a9](https://github.com/divnix/std/commit/4c571a922d79d2849e82bc77202986e1ee920329)) - David Arnold
- add ops.readYAML function - ([91061c6](https://github.com/divnix/std/commit/91061c619639e5d374efe94583937d03db5e65dd)) - David Arnold
#### Miscellaneous Chores
- add top level link to examples - ([f6caa61](https://github.com/divnix/std/commit/f6caa61681288b9a60c69a992c6e1e640d36b8e6)) - David Arnold
- bump paisano direnv lib - ([c886d1e](https://github.com/divnix/std/commit/c886d1e5d8f5d35c3d77fd0ba9911c4bc17e875e)) - David Arnold
- main branch of std-action after merge - ([e3bd1aa](https://github.com/divnix/std/commit/e3bd1aa87130a380764750ddecf3f78113de8c50)) - David Arnold
- remove deprecated direnv_lib.sh - ([041d143](https://github.com/divnix/std/commit/041d1433cafcce76ad699ab7fe788504710ff414)) - David Arnold
- remove just file at most valuable top level estate - ([635bace](https://github.com/divnix/std/commit/635bace27665978635b3947f896fd25124bec74b)) - David Arnold
- bring back dogfood for display - ([c1c2f32](https://github.com/divnix/std/commit/c1c2f324722e81773e84f62bbc2cd323a0b632aa)) - David Arnold
- clarify and curate sub flakes spec - ([b4300e0](https://github.com/divnix/std/commit/b4300e0a92fb81a854e5486ab189aaf94f107a6b)) - David Arnold
- slim rename - ([a5bac1b](https://github.com/divnix/std/commit/a5bac1b83dd91842090622175225848a9e6ffcc6)) - David Arnold
- make actions rely on the global PRJ check and update to spec - ([80e5792](https://github.com/divnix/std/commit/80e5792eae98353a97ab1e85f3fba2784e4a3690)) - David Arnold
- update numtide's devshell - ([8671b68](https://github.com/divnix/std/commit/8671b6892e45d795d7409940750832d68c929dcf)) - David Arnold
- big reshuffling / refactor to update best practices - ([148a699](https://github.com/divnix/std/commit/148a69962d7e74e407ef2049417d49350bb66c73)) - David Arnold
- remove deprecated code - ([1657312](https://github.com/divnix/std/commit/1657312f0fe50bd262b8f9bc01a8184ba16a411e)) - David Arnold
#### Refactoring
- **(blocktypes)** use haumea to load the standard lib parts - ([8917c56](https://github.com/divnix/std/commit/8917c56c86519bee536f6fb4c26f7e448a3faeec)) - David Arnold
- **(proviso)** make clear that no access to nix' lexical scope - ([022acb2](https://github.com/divnix/std/commit/022acb251e8729efed4812a7e915c0c922eae7be)) - David Arnold
- **(std/fwlib)** add trivial nixpkgs to block types - ([23bfacc](https://github.com/divnix/std/commit/23bfacc2d1cdc5c7004b33376395ff2bbc9e02ec)) - David Arnold
- **(std/fwlib/blockTypes/nomad)** rename and factorize - ([bcaec08](https://github.com/divnix/std/commit/bcaec088de1c64f6eb3328fca58122b00fd15ad1)) - David Arnold
- add preLoadStorePaths to the buildLayer of mkDevOCI - ([ac0909b](https://github.com/divnix/std/commit/ac0909bced2374c639081c7b8b90f661a0c83a16)) - guangtao
- add accept-flake-config to mkDevOCI - ([49aaf59](https://github.com/divnix/std/commit/49aaf59d9d45afa15cdb776935a2fee920978e16)) - guangtao
- make standalone lib a cell block & bootstrap - ([4e9e5f0](https://github.com/divnix/std/commit/4e9e5f026ae413bc2c8b41ed9ddd677ecb9e934c)) - David Arnold
- make mkCommand signature more ergonomic in block type development - ([5ffdd93](https://github.com/divnix/std/commit/5ffdd932af9577eb97f9cae0983e7493868ba542)) - David Arnold

- - -

## [v0.23.2](https://github.com/divnix/std/compare/v0.23.1..v0.23.2) - 2023-06-16
#### Features
- start using lazyDerivation for faster TUI response times - ([0a513df](https://github.com/divnix/std/commit/0a513df838207666dd442a6e0a5676260788bd0d)) - David Arnold
#### Miscellaneous Chores
- fix cog patch release automation oversight - ([df4cd51](https://github.com/divnix/std/commit/df4cd51a2a179b6f45410dfacb4382bac046ae8f)) - David Arnold

- - -

## [v0.23.1](https://github.com/divnix/std/compare/v0.23.0..v0.23.1) - 2023-06-15
#### Bug Fixes
- use recent enough nixpkgs lib version for haumea - ([6d9499f](https://github.com/divnix/std/commit/6d9499fea8c917545e58d03d22e6a78955598a6d)) - David Arnold
- ci with new std-action compatible version - ([d6bcee9](https://github.com/divnix/std/commit/d6bcee9c35fb4a905b51c39e4d5ca842e9a421eb)) - David Arnold
- add prj-spec dirs to gitignore - ([658683f](https://github.com/divnix/std/commit/658683f3edeb64c4f39a3bcee76d29adef84c4f0)) - Chris Montgomery
- `.envrc`: shellcheck - ([3947897](https://github.com/divnix/std/commit/39478974cfdfac63d57c7d4900498659dda7c088)) - Chris Montgomery
#### Features
- update templates - ([304c835](https://github.com/divnix/std/commit/304c83597314d4a554997b11af42fbf412ac855c)) - Chris Montgomery
#### Miscellaneous Chores
- **(version)** setup dev version - ([bfd146c](https://github.com/divnix/std/commit/bfd146cd229016ec3353bdac1b9513f0b7c1605d)) - David Arnold
- fix release automation for patch releases - ([7d353de](https://github.com/divnix/std/commit/7d353dee098d213c787b4c6caf34cbba86593684)) - David Arnold

- - -

## [v0.23.0](https://github.com/divnix/std/compare/v0.22.0..v0.23.0) - 2023-06-03
#### Bug Fixes
- mkUser script to keep /etc/{passwd,shadow,group,gshadow} from being overwritten - ([959f54d](https://github.com/divnix/std/commit/959f54d6698ff7fea01e4e6d8e5d7d95fcf66844)) - Gytis Ivaskevicius
#### Miscellaneous Chores
- **(version)** setup dev version - ([909682b](https://github.com/divnix/std/commit/909682bcdc81c4c7d8ba09bfac0a770f8e782244)) - David Arnold
#### Refactoring
- adopt paisano v0.1.0 api - ([00bfdaa](https://github.com/divnix/std/commit/00bfdaadbe95bb0c61311284c5e979f74cee976f)) - David Arnold

- - -

## [v0.22.0](https://github.com/divnix/std/compare/v0.21.4..v0.22.0) - 2023-05-17
#### Bug Fixes
- flaky test - ([dbc7761](https://github.com/divnix/std/commit/dbc7761a64b55e780360c3b1c3c92aee24fb2c18)) - David Arnold
- arion action by providing the arion bin - ([0d8be65](https://github.com/divnix/std/commit/0d8be654f8f811457a0ecacda9b1776599fc7096)) - David Arnold
#### Features
- improve std image - ([27a83ce](https://github.com/divnix/std/commit/27a83ce436ef5d0162e7ab00dde7ca5ae908cb52)) - David Arnold
- bump dmerge - add prepend and fresh array-merge-rhs - ([45b431a](https://github.com/divnix/std/commit/45b431ae09df98e046bcc8271aa209bdfc87444d)) - David Arnold
#### Miscellaneous Chores
- **(version)** pin v0.22.0-dev - ([bcabab5](https://github.com/divnix/std/commit/bcabab562f34c7c29a8afdb44221b3dcd07da6ee)) - David Arnold
#### Refactoring
- clarify the std oci additions by using dmerge for sep of conc. - ([6432c73](https://github.com/divnix/std/commit/6432c739897b409a0b342aa7b0b2075521e4dd44)) - David Arnold

- - -

## [v0.21.4](https://github.com/divnix/std/compare/v0.21.3..v0.21.4) - 2023-05-12
#### Bug Fixes
- update envrc hash for direnv lib - ([9dd89f2](https://github.com/divnix/std/commit/9dd89f2bf2e86fc1f738a43ff11dbe19c40df40e)) - David Arnold
- bump tui fixes - ([aa8e3be](https://github.com/divnix/std/commit/aa8e3be90326f76a09bed625a77a532bd3a10da7)) - David Arnold
#### Documentation
- fix emojis in mdbook - ([0384c91](https://github.com/divnix/std/commit/0384c91ce21f2ad4d8068a3a970ce89a52b0618c)) - figsoda
#### Features
- **(containers)** identify image during copy - ([3038e86](https://github.com/divnix/std/commit/3038e8615c259969d697d4cbde7a5bf295488c4b)) - David Arnold
#### Miscellaneous Chores
- fix patch release version file handling - ([3aa2051](https://github.com/divnix/std/commit/3aa2051ac180b74e0227f5a4645fe4a1476b537a)) - David Arnold
- bump nixago and devshell for feature and fix - ([5623107](https://github.com/divnix/std/commit/562310786b998bf52bd02bf7ac6bfcc743e8d45d)) - David Arnold
- bump nixago with nixpkgs-unfree fixes - ([a0f9dd3](https://github.com/divnix/std/commit/a0f9dd33cff37e2c532e2c236d011e2ecd77286d)) - David Arnold
- fix cog version instrumentation - ([33be14a](https://github.com/divnix/std/commit/33be14a48ffc9daea706acea51a7a8f557798692)) - David Arnold

- - -

## [v0.21.3](https://github.com/divnix/std/compare/v0.21.2..v0.21.3) - 2023-05-04
#### Miscellaneous Chores
- fix cog patch release workflow starting from release branch - ([78d50ae](https://github.com/divnix/std/commit/78d50aeb0d65e3b4a334e6cda84b98d9575a4f41)) - David Arnold
- bump nixago and devshell for feature and fix - ([80d0215](https://github.com/divnix/std/commit/80d0215b963fbed0b8c1e7952df6510bd9b5701a)) - David Arnold
- bump nixago with nixpkgs-unfree fixes - ([39c474c](https://github.com/divnix/std/commit/39c474ccb8fb6d81c6e5b645ba86affc020de8df)) - David Arnold
- fix cog version instrumentation - ([0c01f9c](https://github.com/divnix/std/commit/0c01f9cc9dd09440cf60ef2f2d09ed03500af85f)) - David Arnold

- - -

## [v0.21.1](https://github.com/divnix/std/compare/v0.21.0..v0.21.1) - 2023-04-17
#### Features
- migrate to employ paisano direnv support; direnv_lib.sh compat - ([df0eb70](https://github.com/divnix/std/commit/df0eb7046e00d97f386aef7f764e91f11d6a2ec6)) - David Arnold
#### Miscellaneous Chores
- instrument releases with cog - ([fc19938](https://github.com/divnix/std/commit/fc199384cbdedf4de066cf89992b4e0e7000635c)) - David Arnold
- bump to new version of paisano tui - ([0cae039](https://github.com/divnix/std/commit/0cae039441c3dfd2efeb5f69a4a5825188dea786)) - David Arnold

- - -

Changelog generated by [cocogitto](https://github.com/cocogitto/cocogitto).