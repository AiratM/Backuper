#!/bin/bash
#config variables
RemoteUser="RemoteUserName" #User name for authorization by SSH on remote server
RemoteKeyPath="/path/to/key/.ssh/id_dsa" #SSH key for authorization by SSH on remote server
Server="BackupServer" #IP address or server name
ServerPath="/remote/path/" #Remote directory for keeping created backups
LocalPath="/path/to/local/folder/" #Created archives will store in this folder before copying
LogName="backup.log" #Log file name. Log file store on server in ServerPath directory
ConfigFile="/usr/local/sbin/list.txt" #List of directories for backuping
RemoteUser="RemoteUserName" #User name for authorization by SSH on remote server
RemoteKeyPath="/path/to/key/.ssh/id_dsa" #SSH key for authorization by SSH on remote server
Server="BackupServer" #IP address or server name
ServerPath="/remote/path/" #Remote directory for keeping created backups
LocalPath="/path/to/local/folder/" #Created archives will store in this folder before copying
LogName="backup.log" #Log file name. Log file store on server in ServerPath directory
ConfigFile="/usr/local/sbin/list.txt" #List of directories for backuping
##################
msg="Backup fileserver"
TimeStamp=`date +%Y-%m-%d_%H:%M:%S`
echo "${TimeStamp}$msg"  | ssh -i ${RemoteKeyPath} ${RemoteUser}@${Server} "cat >> ${ServerPath}${LogName}"
while read line; do
	BackupFileName=`basename ${line}`
	ArchName=${BackupFileName}.tgz
	msg="Start archiving ${line}"
	TimeStamp=`date +%Y-%m-%d_%H:%M:%S`
	echo "${TimeStamp}: $msg"  | ssh -i ${RemoteKeyPath} ${RemoteUser}@${Server} "cat >> ${ServerPath}${LogName}"
	tar -zcf ${LocalPath}${ArchName} ${line}
	TimeStamp=`date +%Y-%m-%d_%H:%M:%S`
	msg="${TimeStamp}: Archive ${LocalPath}${ArchName} created"
	echo "$msg"  | ssh -i ${RemoteKeyPath} ${RemoteUser}@${Server} "cat >> ${ServerPath}${LogName}"
	dd if=${LocalPath}${ArchName} conv=sync,noerror bs=16384K | ssh -i ${RemoteKeyPath} ${RemoteUser}@${Server} "dd of=${ServerPath}${ArchName}"
	TimeStamp=`date +%Y-%m-%d_%H:%M:%S`
	msg="${TimeStamp}: Archive copied to server"
	echo "$msg"  | ssh -i ${RemoteKeyPath} ${RemoteUser}@${Server} "cat >> ${ServerPath}${LogName}"
#md5 coming soon with some optimization
done < ${ConfigFile}
