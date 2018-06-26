<?php

/**
 * @Author: weiyanguang
 * @Date:   2018-06-25 15:49:15
 * @Last Modified by:   weiyanguang
 * @Last Modified time: 2018-06-25 16:04:53
 * @Doc: 白名单检查
 */

class rWhiteList
{
    // 点分十进制地址转十进制
    public static function ipStr2Decimal($ip){
        $tmps    = explode(".", $ip);
        $decimal = 0;

        for($i=0;$i<4;$i++){
            $ip_tmp  = (int)$tmps[$i];
            $ip_tmp  = $ip_tmp * pow(2, (8 * (3-$i)));
            $decimal = $decimal + $ip_tmp;
        }
        return $decimal;
    }

    // 获取请求ip地址
    public static function getIp()
    {
        if (getenv('HTTP_CLIENT_IP')) {
            $ip = getenv('HTTP_CLIENT_IP');
        } else if (getenv('HTTP_X_FORWARDED_FOR')) {
            $ip = getenv('HTTP_X_FORWARDED_FOR');
        } else if (getenv('REMOTE_ADDR')) {
            $ip = getenv('REMOTE_ADDR');
        } else {
            $ip = $_SERVER['REMOTE_ADDR'];
        }
        $ips = explode(',', $ip);
        if (count($ips) > 1) {
            $ip = $ips[0];
        }
        return $ip;
    }

    /**
     * @cur_ip 检查的ip地址，如"127.0.0.1"
     * @check_ip_list 白名单列表，格式为"192.168.0.0/16"的列表，没有子网掩码时
     *      按照32计算
     */
    public static function checkWhiteIpList($cur_ip, $check_ip_list){

        $cur_decimal = sgComUtil::ipStr2Decimal($cur_ip);

        foreach ($check_ip_list as $key => $value) {
            $ipl      = explode("/", $value);
            $duan     = 32;
            $check_ip = $ipl[0];
            if(count($ipl) > 1){
                $duan = $ipl[1];
            }

            $a_decimal = sgComUtil::ipStr2Decimal($check_ip);

            $step = 32-$duan; // 右移偏移量

            $a_step = $a_decimal >> $step;
            $b_step = $cur_decimal >> $step;

            if($a_step==$b_step){
                return true;
            }
        }
        return false;
    }

    // 检查当前ip是否合法
    public static function checkCurIp($check_ip_list){
        $cur_ip = sgComUtil::getIp();
        return sgComUtil::checkWhiteIpList($cur_ip, $check_ip_list);
    }
}
