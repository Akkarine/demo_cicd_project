#!/bin/bash

name=`date +%F-%H`.sql.gz
target_dir=`date +%F`
cd /tmp
su postgres -c "pg_dump -U $DB_USER --no-password $DB_NAME > /tmp/backup.sql"
cd ~
mv /tmp/backup.sql .
gzip -9 backup.sql
mv backup.sql.gz $name
fail_text=
# Проверить, есть ли папка с текущей датой и заодно удалить все бэкапы старше 31дня
ssh -o StrictHostKeyChecking=no $BACKUP_DB_SERVER_USER@$BACKUP_DB_SERVER_IP -i /backupsrvkey "test -e $BACKUP_DB_SERVER_PATH/$target_dir && \
          find $BACKUP_DB_SERVER_PATH/ -ctime +31 -maxdepth 1 -exec rm -r '{}' \;"
if [ $? -ne 0 ]; then
	ssh -o StrictHostKeyChecking=no $BACKUP_DB_SERVER_USER@$BACKUP_DB_SERVER_IP -i /backupsrvkey "mkdir $BACKUP_DB_SERVER_PATH/$target_dir";
fi
for filename in ./*.sql.gz; do
	if [[ $filename = *00* ]]; then
		scp -o StrictHostKeyChecking=no -i /backupsrvkey $filename $BACKUP_DB_SERVER_USER@$BACKUP_DB_SERVER_IP:/$BACKUP_DB_SERVER_PATH/old/$filename >> log_00
	fi
	scp -o StrictHostKeyChecking=no -i /backupsrvkey $filename $BACKUP_DB_SERVER_USER@$BACKUP_DB_SERVER_IP:/$BACKUP_DB_SERVER_PATH/$target_dir/$filename >> log
	if [[ $? == 0 ]]; then
  		rm $filename
	else
		fail_text=$fail_text$'\n'$filename
	fi
done

if [[ $fail_text != "" ]]; then
	fail_text="Не удалось отправить следующие файлы:"$'\n'$fail_text
	echo $fail_text | mail -s "Бэкап не удался" -a 'Content-type: text/plain; charset="utf-8"' admin@company.ru
fi