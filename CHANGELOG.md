# Changelog
All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

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