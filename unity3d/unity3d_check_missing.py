#!/usr/bin/env python
# encoding: UTF-8

import os
import re

# *.meta
# *.mat
# *.unity

def getFileName(path, suffix):
    lst = []
    f_list = os.listdir(path)
    for a_file in f_list:
        ab_path = path + "/" + a_file

        if not os.path.isdir(ab_path):
            if os.path.splitext(ab_path)[1] == suffix:
                lst.append([ab_path])
                # print ab_path
        else:
            lst.extend(getFileName(ab_path, suffix))
    return lst

def getGUID(flst):
    for item in flst:
        file = open(item[0])
        lines = file.readlines(100000)
        if len(lines) > 1:
            ma = re.match(r'guid: (.+)',lines[1])
            if ma:
                item.append(ma.group(1))
            else:
                item.append("none")
        else:
            item.append("none")

def findGUID(flst):
    for item in flst:
        lst = []
        file = open(item[0])
        lines = file.readlines(100000)
        for line in lines:
            ma = re.match(r'.* guid: (\w+)', line)
            if ma:
                mat = ma.group(1)
                lst.append(mat)
        item.append(lst)

def checkGUID(check_list, src_list):
    fail_count = 0
    for item in check_list:
        lst = []
        for item2 in item[1]:
            check_exist = False
            if item2[0:10] == '0000000000':
                continue
            for src in src_list:
                if item2 == src[1]:
                    check_exist = True
                    break
            if check_exist == False:
                lst.append(item2)
        
        if len(lst) > 0:
            fail_count = fail_count + 1
            # print "--> %s " % (item[0])
            # print "----> check %d find %d not exist" % (len(item[1]), len(lst))
            # for val in lst:
            #     print val
    print "All count = %d , fail count = %d" % (len(check_list), fail_count)

check_path = "."
metas  = getFileName(check_path, '.meta')
unitys = getFileName(check_path, '.unity')
mats   = getFileName(check_path, '.mat')

getGUID(metas)
findGUID(unitys)
findGUID(mats)

checkGUID(unitys, metas) # check *.unity
checkGUID(mats, metas)   # check *.mat
