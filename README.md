# Tern for Vim

This is a [Vim][vim] plugin that provides [Tern][tern]-based
JavaScript editing support.

[vim]: http://www.vim.org/
[tern]: http://ternjs.net

In JavaScript files, the package will hook into
[omni completion][omni] to handle autocompletion, and provide the
following commands:

[omni]: http://vimdoc.sourceforge.net/htmldoc/version7.html#new-omni-completion

`TernDef`: Jump to the definition of the thing under the cursor.

`TernDoc`: Look up the documentation of something.

`TernType`: Find the type of the thing under the cursor.

`TernRefs`: Show all references to the variable or property under the
cursor.

`TernRename`: Rename the variable under the cursor.

## Installation

#### Manual

If you use [Pathogen][path] or something similar, you can clone this
repository to your `~/.vim/bundle` (or equivalent) directory. Make
sure you have [node.js][node] and [npm][npm] installed (Tern is a
JavaScript program), and install the tern server by running `npm
install` in the `bundle/tern_for_vim` directory.

__Caution__:
Because the node process is not run using your standard shell, the NVM version of node.js won't work.
You need a global node executable.

#### apt-vim

Install [apt-vim](https://github.com/egalpin/apt-vim) and then run the
following in terminal:

`apt-vim install -y https://github.com/ternjs/tern_for_vim.git`


## Configuration

The command used to start the Tern server can be overridden by setting
`tern#command` to an array of strings (the binary and its arguments,
if any). You might need this if your node is installed somewhere
that's not in the default path, or if you want to install Tern in some
custom location.

The variable `tern#is_show_argument_hints_enabled` can be set to
something truthy to make the plugin display the arguments to the
current function at the bottom of the screen. This feature is
currently not very mature, and likely to make your editing laggy.

Tern uses `.tern-project` files to configure loading libraries and
plugins for a project. See the [Tern docs][docs] for details.

[docs]: http://ternjs.net/doc/manual.html#configuration
[path]: https://github.com/tpope/vim-pathogen
[node]: http://nodejs.org/
[npm]: https://npmjs.org/
