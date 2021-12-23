curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://ispip.clang.cn/all_cn.txt' > china_ipv4.txt
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://ispip.clang.cn/all_cn_ipv6.txt' > china_ipv6.txt
cat china_ipv4.txt china_ipv6.txt > china_ip.txt

# GFW List
curl -sS https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt | \
    base64 -d | sort -u | sed '/^$\|@@/d'| sed 's#!.\+##; s#|##g; s#@##g; s#http:\/\/##; s#https:\/\/##;' | \
    sed '/apple\.com/d; /sina\.cn/d; /sina\.com\.cn/d; /baidu\.com/d; /qq\.com/d' | \
    sed '/^[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+$/d' | grep '^[0-9a-zA-Z\.-]\+$' | \
    grep '\.' | sed 's#^\.\+##' | sort -u > /tmp/temp_gfwlist1

curl -sS https://raw.githubusercontent.com/hq450/fancyss/master/rules/gfwlist.conf | \
    sed 's/ipset=\/\.//g; s/\/gfwlist//g; /^server/d' > /tmp/temp_gfwlist2

curl -sS https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/gfw.txt > /tmp/temp_gfwlist3

cat /tmp/temp_gfwlist1 /tmp/temp_gfwlist2 /tmp/temp_gfwlist3  | \
    sort -u | sed 's/^\.*//g' > gfwlist.txt
