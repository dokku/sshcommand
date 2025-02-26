# sshcommand

Simplifies running a single command over SSH, and manages authorized keys (ACL) and users in order to do so.

It basically simplifies running:

```shell
ssh user@server 'ls -l <your-args>'
```

into:

```shell
ssh ls@server <your-args>
```

## Commands

```shell
sshcommand create                    <USER> <COMMAND>                # Creates a local system user and installs sshcommand skeleton
sshcommand acl-add                   <USER> <NAME> <KEY_FILE>        # Adds named SSH key to user from STDIN or argument
sshcommand acl-remove                <USER> <NAME>                   # Removes SSH key by name
sshcommand acl-remove-by-fingerprint <USER> <FINGERPRINT>            # Removes SSH key by fingerprint
sshcommand list                      <USER> [<NAME>] [<OUTPUT_TYPE>] # Lists SSH keys by user, an optional name and a optional output format (JSON)
sshcommand help                      <COMMAND>                       # Shows help information
sshcommand version                                                   # Shows version
```

## Example

On a server, create a new command user:

```shell
sshcommand create cmd /path/to/command
```

On your computer, add authorized keys with your key:

```shell
cat ~/.ssh/id_rsa.pub | ssh root@server sshcommand acl-add cmd progrium
```

If the public key is already on the server, you may also specify it as an argument:

```shell
ssh root@server sshcommand acl-add cmd progrium ~/.ssh/id_rsa.pub
```

By default, key names and fingerprints must be unique. Both of these checks can be disabled by setting the following environment variables to `false`:

```shell
export SSHCOMMAND_CHECK_DUPLICATE_FINGERPRINT="false"
export SSHCOMMAND_CHECK_DUPLICATE_NAME="false"
```

Now anywhere with the private key you can easily run:

```shell
ssh cmd@server
```

Anything you pass as the command string will be appended to the command. You can use this
to pass arguments or if your command takes subcommands, expose those subcommands easily.

```shell
/path/to/command subcommand
```

Can be run remotely with:

```shell
ssh cmd@server subcommand
```

When adding an authorized key, you can also specify custom options for `AUTHORIZED_KEYS`
by specifying the `SSHCOMMAND_ALLOWED_KEYS` environment variable. This should be a list
of comma-separated options. The default keys are as follows:

```shell
no-agent-forwarding,no-user-rc,no-X11-forwarding,no-port-forwarding
```

This can be useful for cases where the ssh server does not allow certain options or you
wish to further constrain a user's environment. Please see `man sshd` for more information.

Existing keys can be listed via the `list` subcommand:

```shell
# in text format
sshcommand list cmd

# filter by a particular name
sshcommand list cmd progrium

# in json format
sshcommand list cmd "" json

# with name filtering
sshcommand list cmd progrium json

# ignore validation errors (though they will be printed to stderr)
export SSHCOMMAND_IGNORE_LIST_WARNINGS=true
sshcommand list cmd
```
