# *qadrsc*

**Table of contents**
*   [Definition](#definition)
*   [Details](#details)
*   [Usage](#usage)

----

## Definition

Simple script to securely copy files from the local to a remote system as root even though SSH root login is not permitted.

[Top](#)

## Details

Usually, logging into a remote system using the root account via SSH is disabled on servers for security reasons. Instead, there is a separate user account to use for that purpose, e. g. `johndoe`.

Now, if you use that user in combination via *rsync* or *scp*, you can't copy files in the remote `/root` or `/etc` directory, due to the fact, that `johndoe` does not have the permission to write to those locations.

You could copy the files to `/tmp`, however, you would have to change the owner on the remote system to have a consistent file ownership.

This script allows to securely copy files to system directories on a remote system (like *scp*) with root as owner no matter which user is being used on the local system.

As the name implies, it is a quick-and-dirty solution.

Feel free to modify!

[Top](#)

## Usage

The command-line arguments have been revised in version 1.1.0 of the project. From now on, you can use the typical *rsync* or *scp* syntax for the destination path.

So, let's assume you have the server `192.168.2.1` which does not permit logging in via SSH as root, but with the user `johndoe`.

Now, you want to copy the local file `/etc/foobar.conf` to the `/etc` directory of the server. You can do that as follows:

```
$ ./qadrsc.sh /etc/foobar.conf johndoe@192.168.2.1:/etc
```

In the next step you want to copy the contents of `/tmp/somestuff` to `/root` on the remote system. Simply use the following command:

```
$ ./qadrsc.sh '/etc/somestuff/*' johndoe@192.168.2.1:/root
```

Notice that when using asterisks (`*`) in the source path, the path must either be enclosed with single (`'`) or double (`"`) quotes. Otherwise an argument error (too many arguments) will occur.

Using a dynamic path also works, for example:

```
$ cd /etc
$ ./qadrsc.sh ./foobar.conf johndoe@192.168.2.1:/etc
```

[Top](#)
