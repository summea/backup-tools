# Backup Tools

Backup tools for the Bash shell.

## Requirements

* [Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell))

## License
MIT (Please check LICENSE file for license information.)

## Backup Tools
<a href="#backup">backup</a><br>
<a href="#restore">restore</a><br>
<a href="#db-backup">db-backup</a><br>
<a href="#db-restore">db-restore</a><br>

<hr>

<a name="backup"></a>
### backup

A simple program for backing up files or folders.<br><br>

Before this program is run you will need to make changes to the <b>config/conf</b> file in order to choose what you would like backup. If nothing is specified in the conf file... nothing will be backed up.<br><br>

#### How to Run this Program
If you are using Bash, you should be able to use the following command:

    ./backup

<hr>

<a name="restore"></a>
### restore
A simple program for restoring files or folders that were backed up with <b>backup.</b><br><br>

Before this program is run you will need to make changes to the <b>config/conf</b> file in order to choose what you would like to restore. If nothing is specified in the conf file... nothing will be restored. If you have used the <b>backup</b> program and have not made any changes to the conf file yet, you can safely run the <b>restore</b> program.

#### How to Run this Program
If you are using Bash, you should be able to use:

    ./restore source_file.tar.gz

<hr>

<a name="db-backup"></a>
### db-backup
A simple program for backing up databases.<br><br>

Before this program is run you will need to make changes to the <b>config/conf</b> file in order to choose what databases you would like backup. If nothing is specified in the conf file... nothing will be backed up.

#### How to Run this Program
If you are using Bash, you should be able to use:

    ./db-backup

<hr>

<a name="db-restore"></a>
### db-restore
A simple program for restoring databases that were backed up with <b>db-backup.</b><br><br>

Before this program is run you will need to make changes to the <b>config/conf</b> file in order to choose what you would like to restore. If nothing is specified in the conf file... nothing will be restored. If you have used the <b>db-backup</b> program and have not made any changes to the conf file yet, you can safely run the <b>db-restore</b>
program.

#### How to Run this Program
If you are using Bash, you should be able to use:

    ./db-restore source_file.tar.gz
