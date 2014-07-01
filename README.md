# Gh-Diff

Take diffs between local and a github repository files.

## Installation

Add this line to your application's Gemfile:

    gem 'gh-diff'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gh-diff

## Usage

Gh-Diff have `gh-diff` terminal command.

```bash
% gh-diff
Commands:
  gh-diff diff LOCAL\_FILE [REMOTE\_FILE]  # Compare FILE(s) between local and remote repository. LOCAL_FILE can be DIRECTORY.
  gh-diff dir_diff DIRECTORY  # Print added and removed files in remote repository
  gh-diff get FILE            # Get FILE content from github repository
  gh-diff help [COMMAND]      # Describe available commands or one specific command

Options:
  -g, [--repo=REPO]          # target repository
  -r, [--revision=REVISION]  # target revision
                             # Default: master
  -p, [--dir=DIR]            # target file directory
      [--username=USERNAME]  # github username
      [--password=PASSWORD]  # github password
      [--token=TOKEN]        # github API access token
```

To take diff of `README.md` for 'melborne/tildoc' repo, do this;

```bash
% gh-diff diff README.md --repo=melborne/tildoc
Diff found on README.md <-> README.md [6147df8:master]
```

By setting `--name_only` option false, the diff will be print out.

```bash
% gh-diff diff README.md --repo=melborne/tildoc --no-name_only
Base revision: 6147df8378545a4807a2ed73c9e55f8d7204c14c[refs/heads/master]
--- README.md
+++ README.md


 Add String#~ for removing leading margins of heredocs.

-Added this line to local.
-
 ## Installation

 Add this line to your application's Gemfile:
```

To save the result of diff, put `--save` option to diff command.

### For Translation-like project

If you have translated files in which original text inserted with
html comment tags, and want to compare the original with the remote,
`commentout` option helps you.

    % gh-diff diff README.ja.md README.md --commentout

This extract commented text in `README.ja.md`, then compare it with remote `README.md`.

See `gh-diff help diff` for more info.

### Options in ENV

These options can be preset as ENV variables with prefix `GH_`

    % export GH_USERNAME=melborne
    % export GH_PASSWORD=xxxxxxxx
    % export GH_TOKEN=1234abcd5678efgh

Also, you can set them in `.env` file in the root of your project.

    #.env
    REPO=jekyll/jekyll
    DIR=site

ENVs in `.env` overwrite global ENVs with prefix `GH_`.

There is rate limit for accessing GitHub API. While you can make it
up with Basic Authentication(username and password) or API token, 
setting them are preferable.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/gh-diff/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
