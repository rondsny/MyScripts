#!/bin/sh
# @Author: weiyg
# @Date:   2014-11-21 18:01:09
# @Last Modified by:   weiyg
# @Last Modified time: 2014-12-17 12:56:43
# @doc : 安装 Erlang 服务器基础环境
#
#        由于openssl默认安装不启用动态链接库，所以需要特殊处理
#        能够保证erlang可以运行crypto:start() 即可
#
#        基础环境（inst_basic函数）需要使用root权限
#        Erlang 可以自行选择是否安装在普通用户下
#        安装路径可以自行修改
#
#        return 0 和;(分号)会结束cd的作用域，修改代码需要注意

INS_HOME=`pwd`

SSL_PATH=/usr/local/ssl-1.0.1j
ERL_PATH=/usr/local

ERL_FILE="otp_src_R16B03-1"
ERL_FILE_TG="$ERL_FILE.tar.gz"

# install basic environment
inst_basic()
{
	yum -y install gcc
	yum -y install gcc-c++
	yum -y install make

    yum -y install xsltproc         ## 生成doc 的时候会用到
    yum -y install fop              ## 生成doc 的时候会用到
    yum -y install tk               ## 图形工具
    yum -y install unixODBC         ## ODBC
    yum -y install unixODBC-devel   ## ODBC
    yum -y install kernel-devel     ## 内核工具
    yum -y install m4               ## 宏处理器
    yum -y install ncurses-devel    ## 编译依赖
    return 0
}

## install openssl-devel
inst_ssl()
{
    if [ ! -f "openssl-1.0.1j.tar.gz" ];then
        wget http://www.openssl.org/source/openssl-1.0.1j.tar.gz
    fi
    tar xzvf openssl-1.0.1j.tar.gz
    cd openssl-1.0.1j
    ./config --prefix=$SSL_PATH
    # CFLAG加上-fPIC参数，以相对地址的方式编译链接库
    sed -i 's/CFLAG= -DOPENSSL/CFLAG= -fPIC -DOPENSSL/g' Makefile
    make && make install
    return 0
}

## install Erlang
inst_erlang()
{
	if [ ! -f "$ERL_FILE_TG" ];then
		wget http://www.erlang.org/download/$ERL_FILE_TG
    fi
	tar -zxvf $ERL_FILE_TG
    cd $ERL_FILE
    ./configure --prefix=$ERL_PATH --with-ssl=$SSL_PATH
    make
    make install
    return 0
}

inst_basic

cd $INS_HOME
inst_ssl

cd $INS_HOME
inst_erlang
