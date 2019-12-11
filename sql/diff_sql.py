# -*- coding: utf8 -*-

# mysqldiff是MySQL Utilities中的一个脚本，默认的MySQL不包含这个工具集，所以需要独立安装。
# MySQL Utilities下载地址：http://downloads.mysql.com/archives/utilities/。
# 目前已经将所有exe放置在路径下

import os
import time
import re
import sys

DB_HOST = "127.0.0.1"
DB_PORT = 3306
DB_USERNAME = "root"
DB_PASSWORD = "123456"

WORK_DIR = "/".join(os.path.abspath(__file__).split("/")[0:-1])
sys.path.append(WORK_DIR)


# 删除临时数据库
def drop_tmp_db(db_name):
    print "drop_tmp_db db %s ..." % (db_name)
    cmd1 = "mysql -h%s -P%s -u%s -p%s -e \"drop database if exists %s;\"" % \
              (DB_HOST, DB_PORT,
               DB_USERNAME, DB_PASSWORD,
               db_name)

    os.system(cmd1)

    print "drop_tmp_db %s ok ..." % (db_name,)

# 新建最新数据库结构
def create_new_db(db_name, sql_filename):
    print "create db %s from %s ..." % (db_name, sql_filename)
    cmd1 = "mysql -h%s -P%s -u%s -p%s -e \"drop database if exists %s; create database %s\"" % \
              (DB_HOST, DB_PORT,
               DB_USERNAME, DB_PASSWORD,
               db_name, db_name)

    os.system(cmd1)

    cmd2 = "mysql -h%s -P%s -u%s -p%s %s < %s" % \
              (DB_HOST, DB_PORT,
               DB_USERNAME, DB_PASSWORD,
               db_name, sql_filename)

    os.system(cmd2)

    print "create_new_db %s ok ..." % (db_name,)


# 对比数据库
def diff_db(db_name1, db_name2, sql_filename):
    print "diff_db to %s..." % (sql_filename,)

    # mysqldiff --server1=user:pass@host:port:socket --server2=user:pass@host:port:socket --changes-for=server2 db1:db2
    # cmd = "mysqldiff --server1=%s:%s@%s --server2=%s:%s@%s --changes-for=server1 %s:%s -d sql > %s" % \
    cmd = "sqltools\\mysqldiff --server1=%s:%s@%s --server2=%s:%s@%s --changes-for=server1 %s:%s -d sql > %s" % \
            (
                DB_USERNAME, DB_PASSWORD, DB_HOST,
                DB_USERNAME, DB_PASSWORD, DB_HOST,
                db_name1, db_name2, sql_filename,)
    os.system(cmd)


    print "diff_db %s vs %s ok ..." % (db_name1, db_name2)

def show_diff(filename):
    print "diff file content is: \n"
    f = open(filename)
    lines = f.read()
    print lines
    f.close()
    print ""

# 导入差异
def import_diff(db_name, sql_filename):
    print "upgrade db %s from %s ..." % (db_name, sql_filename)

    cmd2 = "mysql -h%s -P%s -u%s -p%s %s < %s" % \
              (DB_HOST, DB_PORT,
               DB_USERNAME, DB_PASSWORD,
               db_name, sql_filename)

    os.system(cmd2)

    print "upgrade %s ok ..." % (db_name,)


if __name__ == "__main__":
    # python diff_sql db_name db_name.sql 0
    # python diff_sql db_name db_name.sql 1

    #os.chdir(WORK_DIR)

    # print u'参数个数为:', len(sys.argv), u'个参数。'
    # print u'参数列表:', str(sys.argv)

    old_db_name = sys.argv[1]
    sql_filename = sys.argv[2]
    is_upgrade_sql = sys.argv[3]

    print 'DB is :', old_db_name
    print 'Sql path is :', sql_filename

    try:

        new_db_name = "tmp_%s" % (old_db_name)
        diff_sql_filename = "temp_diff_%s.sql" % old_db_name

        create_new_db(new_db_name, sql_filename)
        diff_db(old_db_name, new_db_name, diff_sql_filename)
        show_diff(diff_sql_filename)
        if is_upgrade_sql == 1:
            import_diff(old_db_name, diff_sql_filename)
        drop_tmp_db(new_db_name)


    except Exception, Argument:
        print "diff_db> Some Error occured, Msg is:\n", Argument
    except:
        print "diff_db> Some Error occured"

    print "diff done !!!"
