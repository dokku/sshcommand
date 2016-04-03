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
sshcommand create     <USER> <COMMAND>          # Creates a user forced to run command when SSH connects
sshcommand acl-add    <USER> <NAME>             # Adds named SSH key to user from STDIN or argument
sshcommand acl-remove <USER> <NAME>             # Removes SSH key by name
sshcommand help       <COMMAND>                 # Shows help information
```

## Example

On a server, create a new command user:

    $ sshcommand create cmd /path/to/command

On your computer, add authorized keys with your key:

    $ cat ~/.ssh/id_rsa.pub | ssh root@server sshcommand acl-add cmd progrium

Now anywhere with the private key you can easily run:

    $ ssh cmd@server

Anything you pass as the command string will be appended to the command. You can use this
to pass arguments or if your command takes subcommands, expose those subcommands easily.

    $ /path/to/command subcommand

Can be run remotely with:

    $ ssh cmd@server subcommand
