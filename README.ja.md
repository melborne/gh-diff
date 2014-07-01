# Gh-Diff

<!--original
# Gh-Diff
-->

`Gh-Diff`は、ローカルとGitHubリポジトリのファイルの差分を取ります。

<!--original
Take diffs between local and a github repository files.
-->

## インストール

<!--original
## Installation
-->

アプリケーションのGemfileに以下を追加します。

<!--original
Add this line to your application's Gemfile:
-->

    gem 'gh-diff'


<!--original
    gem 'gh-diff'

-->

そして以下を実行します。

<!--original
And then execute:
-->

    $ bundle


<!--original
    $ bundle

-->

または、自身で次のようにインストールします。

<!--original
Or install it yourself as:
-->

    $ gem install gh-diff


<!--original
    $ gem install gh-diff

-->

## 利用方法

<!--original
## Usage
-->

Gh-Diffには`gh-diff`というターミナルコマンドが付いています。

<!--original
Gh-Diff have `gh-diff` terminal command.
-->

```bash
% gh-diff
Commands:
  gh-diff diff LOCAL_FILE [REMOTE_FILE]  # Compare FILE(s) between local and remote repository. LOCAL_FILE can be DIRECTORY.
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

<!--original
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
-->

'melborne/tildoc'レポジトリの`README.md`を比較するには、こうします。

<!--original
To take diff of `README.md` for 'melborne/tildoc' repo, do this;
-->

```bash
% gh-diff diff README.md --repo=melborne/tildoc
Diff found on README.md <-> README.md [6147df8:master]
```

<!--original
```bash
% gh-diff diff README.md --repo=melborne/tildoc
Diff found on README.md <-> README.md [6147df8:master]
```
-->

`--name_only`オプションをfalseにセットすれば、その差分がプリントアウトされます。

<!--original
By setting `--name_only` option false, the diff will be print out.
-->

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

<!--original
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
-->

差分の結果を保存する場合は、`--save`オプションをdiffコマンドに追加します。

<!--original
To save the result of diff, put `--save` option to diff command.
-->

### 翻訳などのプロジェクトのために

<!--original
### For Translation-like project
-->

HTMLコメントタグを使って原文が挿入された翻訳ファイルがあり、この原文とリモートのオリジナルとを比較したい場合には、`commentout`オプションが役立つでしょう。

<!--original
If you have translated files in which original text inserted with
html comment tags, and want to compare the original with the remote,
`commentout` option helps you.
-->

    % gh-diff diff README.ja.md README.md --commentout


<!--original
    % gh-diff diff README.ja.md README.md --commentout

-->

これは、`README.ja.md`からコメントテキストを抽出し、リモートの`README.md`と比較します。

<!--original
This extract commented text in `README.ja.md`, then compare it with remote `README.md`.
-->

より詳細は`gh-diff help diff`を見てください。

<!--original
See `gh-diff help diff` for more info.
-->

### 環境変数ENVにおけるオプション

<!--original
### Options in ENV
-->

これらのオプションは、接頭辞`GH_`を使って環境変数にプリセットできます。

<!--original
These options can be preset as ENV variables with prefix `GH_`
-->

    % export GH_USERNAME=melborne
    % export GH_PASSWORD=xxxxxxxx
    % export GH_TOKEN=1234abcd5678efgh


<!--original
    % export GH_USERNAME=melborne
    % export GH_PASSWORD=xxxxxxxx
    % export GH_TOKEN=1234abcd5678efgh

-->

また、プロジェクトルートの`.env`ファイルに設定することもできます。

<!--original
Also, you can set them in `.env` file in the root of your project.
-->

    #.env
    REPO=jekyll/jekyll
    DIR=site


<!--original
    #.env
    REPO=jekyll/jekyll
    DIR=site

-->

`.env`の環境変数は、`GH_`で始まるグローバル環境変数を上書きします。

<!--original
ENVs in `.env` overwrite global ENVs with prefix `GH_`.
-->

GitHub APIにはアクセス制限があります。ベーシック認証（usernameとpassword）またはAPIトークンでこれを引き上げることができるので、それらを設定するとよいでしょう。

<!--original
There is rate limit for accessing GitHub API. While you can make it
up with Basic Authentication(username and password) or API token, 
setting them are preferable.
-->

## 貢献

<!--original
## Contributing
-->

1. Fork it ( https://github.com/[my-github-username]/gh-diff/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

<!--original
1. Fork it ( https://github.com/[my-github-username]/gh-diff/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
-->
