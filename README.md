# *qadrsc*

**Table of contents**
*   [Definition](#definition)
*   [Details](#details)
*   [Preparation](#preparation)
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

## Preparation

Before you can use the script, you have to prepare the **remote system**.

1.  Create a user which you want to use for the remote interaction, e. g. `johndoe`.

    ```
    # useradd johndoe
    ```

1.  Set a password for the new user.

    ```
    # passwd johndoe
    ```

1.  Run `visudo` and add the following line at the end of the file:

    ```ruby
    johndoe     ALL=(ALL)   NOPASSWD: ALL
    ```

1.  Save the changes and exit.

[Top](#)

## Usage

The command-line arguments have been revised in version 1.1.0 of the project. From now on, you can use the typical *rsync* or *scp* syntax for the destination path.

Notice that when using asterisks (`*`) in the source path, the whole path must either be enclosed with single (`'`) or double (`"`) quotes. Otherwise an argument error will occur (too many arguments).

### Examples with remote destinations

#### Static source path

So, let's assume you have the server `192.168.2.1` which does not permit logging in via SSH as root, but with the user `johndoe`.

Now, you want to copy the local file `/etc/foobar.conf` to the `/etc` directory of the server. You can do that as follows:

```
$ ./qadrsc.sh /etc/foobar.conf johndoe@192.168.2.1:/etc
```

In the next step you want to copy the contents of `/tmp/somestuff` to `/root` on the remote system. Simply use the following command:

```
$ ./qadrsc.sh '/tmp/somestuff/*' johndoe@192.168.2.1:/root
```

You can also copy the entire directory:

```
$ ./qadrsc.sh /tmp/somestuff johndoe@192.168.2.1:/root
```

#### Dynamic source path

Using a dynamic path also works. In the following example the `qadrsc.sh` script is located in `/opt/qadrsc`.

```
$ cd /etc
$ /opt/qadrsc/qadrsc.sh ./foobar.conf johndoe@192.168.2.1:/etc
```

### Example with a remote source

Since version 1.2.0 you can also use a remote path as source, for example:

```
$ ./qadrsc.sh johndoe@192.168.2.1:/etc/foobar.conf /tmp
```

### Bash alias

In order to simplify and speed up the use of the script, you can add a *Bash* alias to `/etc/bashrc` (system wide) or `~/.bashrc` (for the current user).

```bash
alias qadrsc='/opt/qadrsc/qadrsc.sh'
```

[Top](#)
