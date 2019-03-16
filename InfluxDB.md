

```
# 插入数据
curl 'http://127.0.0.1:8086/write?db=db_name' --data-binary "table_name val1=$VAL1,val2=$VAL2"


# 备份
influxd backup
    [ -database <db_name> ]  --> 指定需要备份的数据库名
    [ -portable ]            --> 表示在线备份
    [ -host <host:port> ]    --> influxdb服务所在的机器，端口号默认为8088
    [ -retention <rp_name> ] | [ -shard <shard_ID> -retention <rp_name> ]  --> 备份的保留策略，注意shard是挂在rp下的；我们需要备份的就是shard中的数据
    [ -start <timestamp> [ -end <timestamp> ] | -since <timestamp> ]   --> 备份指定时间段的数据
    <path-to-backup>   --> 备份文件的输出地址

## 备份所有表
influxd backup -portable ./backup_data/total
## 备份某表
influxd backup -portable -database db_name ./backup_data/db_name
## 备份某时间段
influxd backup -portable -database db_name -start 2018-06-27T2:31:57Z -end  2018-08-27T2:31:57Z  ./backup_data/db_name

# 恢复
influxd restore 
    [ -db <db_name> ]       --> 待恢复的数据库(备份中的数据库名)
    -portable | -online
    [ -host <host:port> ]    --> influxdb 的服务器
    [ -newdb <newdb_name> ]  --> 恢复到influxdb中的数据库名
    [ -rp <rp_name> ]        --> 备份中的保留策略
    [ -newrp <newrp_name> ]  --> 恢复的保留策略
    [ -shard <shard_ID> ]
    <path-to-backup-files>

influxd restore -portable -db db_name1 -newdb db_new ./data/db_name1

```
