# sshcommand [![Build Status](https://img.shields.io/circleci/project/dokku/sshcommand/master.svg?style=flat-square "Build Status")](https://circleci.com/gh/dokku/sshcommand/tree/master)

Simplifies running a single command over SSH, and manages authorized keys (ACL) and users in order to do so.

It basically simplifies running:

```
ssh user@server 'ls -l <your-args>'
```

into:

```
ssh ls@server <your-args>
```

## Commands

```shell
sshcommand create     <USER> <COMMAND>                 # Creates a user forced to run command when SSH connects
sshcommand acl-add    <USER> <NAME> <KEY_FILE>         # Adds named SSH key to user from STDIN or argument
sshcommand acl-remove <USER> <NAME>                    # Removes SSH key by name
sshcommand list       <USER> [<NAME>] [<OUTPUT_TYPE>]  # Lists SSH keys by user, an optional name and a optional output format (JSON)
sshcommand help       <COMMAND>                        # Shows help information
sshcommand version                                     # Shows version
```

## Example

On a server, create a new command user:

    $ sshcommand create cmd /path/to/command

On your computer, add authorized keys with your key:

    $ cat ~/.ssh/id_rsa.pub | ssh root@server sshcommand acl-add cmd progrium

If the public key is already on the server, you may also specify it as an argument:

    $ ssh root@server sshcommand acl-add cmd progrium ~/.ssh/id_rsa.pub

By default, key names and fingerprints must be unique. Both of these checks can be disabled by setting the following environment variables to `false`:

    export SSHCOMMAND_CHECK_DUPLICATE_FINGERPRINT="false"
    export SSHCOMMAND_CHECK_DUPLICATE_NAME="false"

Now anywhere with the private key you can easily run:

    $ ssh cmd@server

Anything you pass as the command string will be appended to the command. You can use this
to pass arguments or if your command takes subcommands, expose those subcommands easily.

    $ /path/to/command subcommand

Can be run remotely with:

    $ ssh cmd@server subcommand

When adding an authorized key, you can also specify custom options for `AUTHORIZED_KEYS`
by specifying the `SSHCOMMAND_ALLOWED_KEYS` environment variable. This should be a list
of comma-separated options. The default keys are as follows:

```
no-agent-forwarding,no-user-rc,no-X11-forwarding,no-port-forwarding
```

This can be useful for cases where the ssh server does not allow certain options or you
wish to further constrain a user's environment. Please see `man sshd` for more information.
