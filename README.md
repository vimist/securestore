# SecureStore

SecureStore is a [`pass`][pass]-like file store that uses your existing
[GPG][gpg] key-pair to provide robust, industry standard encryption to store
your important files.

SecureStore is a generalised, encrypted file store, built with flexibility and
simplicity in mind. Employing a layered approach to it's architecture enables
extensions and other applications to easily make use of it's features. Want a
revision controlled store? Sure, take a look at [`vcstore`][vcs], how about a
[`pass`][pass]-like program? No problem, check out [our `pass`
implementation][sspass]. Building on a secure foundation, it's easy to develop
your own tools and applications to extend and use all of the existing
functionality.

Take a look at the "Getting Started" section below to see some examples of how
it can be used.

## Installation

Download or clone this repository onto your computer and run `sudo ./install.sh
<prog>` where `<prog>` is either `securestore`, `vcstore` or `pass`. See the
"Getting Started" documentation below to understand what each provides.

Prerequisites:

- For `securestore`:
  - [Bash][bash] - Everything is written in Bash flavoured shell.
  - [GPG][gpg] - to perform the key management and encryption.
  - `tree` - to list the contents of the store (although you're
    welcome to use `securestore command ls` instead if you wish).
- For `vcstore`, all of the above as well as:
  - [Git][git] - if you want the revision controlled functionality.
- For `pass`, all of the above as well as:
  - `xdotool` - for auto-typing.
  - `xclip` - for clipboard management.

## Generating a GPG Key-Pair

SecureStore uses [GPG][gpg] to encrypt data, but in order to make use of it,
you're going to need you're own key-pair. To generate your own key-pair run `gpg
--full-gen-key` and follow the prompts.

Take a look at [the GNU Privacy Handbook][gpg_handbook] for more information on
how to manage your keys.

## Getting Started with SecureStore

Once you've installed SecureStore and have generated a key-pair, it's easy to
get started. Firstly, we need to initialise our store:

- Make a new directory anywhere and navigate to it: `mkdir mystore`, `cd
  mystore`
- Get your GPG key ID (the 40 character hex string): `gpg --list-keys`
- Initialise the store: `securestore init <your_gpg_key_id>`

SecureStore doesn't output anything on success, but lets just check things
worked as expected anyway: `cat .gpg_id`. If you see your GPG key ID printed to
the terminal, everything worked!

There are only a few commands to learn in order to manage your SecureStore and
most of the are pretty intuitive anyway; run `securestore help` to see what's
available.

### Revision Control

So you want your file store to have revision control? Perhaps you want to use
SecureStore to store version controlled, sensitive notes? The `vcstore` layer
allows you to do exactly that.

So what commands are available for the revision control layer? Well, it's
exactly the same as the standard SecureStore, just replace `securestore` with
`vcstore` and you're good to go (also see `vcstore help`), but this time the
subcommand operations will be tracked using [Git][git]. Try initialising a new
store and adding some files, once you've done that, run `vcstore git log` to see
the repository log.

You can run any Git commands (or any command in general) you like on your store,
just run `vcstore <command>`. For instance, add a Git remote run `vcstore git
remote add origin <location>`.

### Password Manager

Layered on top of the previously mentioned functionality is our password store.
It features both the `securestore` layer and the `vcstore` layer, giving you
both encryption and revision control.

Here's where it gets cool though, unlike [`pass`][pass], where the *primary* use
case is storing a single line of text (usually a password), our password manager
can store as many key-value pairs as you like **and even executable code**. This
is what an entry could look like:

```bash
Username=""
Password="{PASSWORD}"

URL=""

AutoType() {
	type "$Username"
	key Tab
	type "$Password"
	key Return
}
```

You can change this file to anything you like. The only restriction is that it
must be a valid shell script. You can name the variables whatever you like,
rename the `AutoType` function, add more variables, functions, comments,
whatever you like.

The password manager layer provides even more functionality on top of what we
covered in the `securestore` layer and the `vcstore` layer (see `pass help` for
a list of all subcommands). Briefly though, we can run:

- `pass list-properties <entry_name>` to list all variables in a given entry.
- `pass get-property <entry_name> <variable_name>` to get a specific variable
  from an entry.
- `pass type-property <entry_name> <variable_name>` to type the contents of a
  specific variable (using `xdotool`).
- `pass copy-property <entry_name> <variable_name>` to copy the contents of a
  specific variable to the clipboard for one-time use (using `xclip`).
- `pass open-property <entry_name> <variable_name>` to open a URL or file path
  (using `xdg-open`).
- `pass run-function <entry_name> <function_name>` to run a function defined in
  the entry, `AutoType` for example.

These simple commands open up a world of opportunity for automation and
extension. A great example is getting `pass` to auto-type your credentials into
a website using a really simple script.

- Ensure your entry has an `AutoType` function (you can call it whatever you
  like, but that's the name we'll use here).
- Get the current window title in a script using something like `xdotool
  getwindowname $(xdotool getactivewindow)`
- Use an `if`/`else` or `switch`/`case` statement to match the current window
  title to an entry in your store.
- Run `pass run-function <entry_name> AutoType`.


[bash]: https://www.gnu.org/software/bash/
[gpg]: https://gnupg.org
[gpg_handbook]: https://gnupg.org/gph/en/manual.html
[git]: https://git-scm.com
[pass]: https://www.passwordstore.org
[vcs]: vcstore
[sspass]: pass
