# Contributing to timescaledb-rails

First off, thanks for investing your time in contributing to timescaledb-rails 🎉

* [Code of Conduct](#code-of-conduct)
* [Getting Started](#getting-started)
    * [Issues](#issues)
    * [Pull Requests](#pull-requests)

## Code of Conduct

Read our [Code of Conduct](./CODE_OF_CONDUCT.md) to keep our community approachable and respectable.

## Getting Started

Contributions are made to this repo via Issues and Pull Requests (PRs). Please, review existing Issues and PRs before creating your own.

### Issues

Issues should be used to:

* Report problems
* Request new features
* Discuss potential changes

If a reported issue is affecting you as well, please, add any extra information that could help contributors to fix it. Also, adding a [reaction](https://github.blog/2016-03-10-add-reactions-to-pull-requests-issues-and-comments/) to a particular issue will help to prioritize important items.

### Pull Requests

PRs are always welcome and can be a quick way to get your fix or improvement slated for the next release. In general, PRs should:

- Only fix/add the functionality in question **OR** address wide-spread whitespace/style issues, not both.
- Add tests for fixed or changed functionality (if a test suite already exists).
- Address a single concern in the least number of changed lines as possible.
- Include documentation in the repo.

For changes that address core functionality or would require breaking changes (e.g. a major release), it's best to open an Issue to discuss your proposal first. This is not required but can save time creating and reviewing changes.

* Fork the repository
* Clone the project to your machine
* Create a branch following naming convention:
  * fixes -> fix/create-hypertable-not-working
  * features -> feat/add-new-api
  * chores -> chore/change-bin-setup
* Commit changes following [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) specification
* Run `bin/ci` to ensure tests and linter are passing
* Push changes to your fork
* Open a PR in our repository
