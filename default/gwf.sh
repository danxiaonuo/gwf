# IP库
mkdir -p ip
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://ispip.clang.cn/all_cn.txt' > ip/china_ipv4.txt
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://ispip.clang.cn/all_cn_ipv6.txt' > ip/china_ipv6.txt
cat ip/china_ipv4.txt > ip/china_all.txt
cat ip/china_ipv6.txt >> ip/china_all.txt

# clash 规则
mkdir -p clash
cat ip/china_ipv4.txt | perl -ne '/(.+\/\d+)/ && print "IP-CIDR,$1,no-resolve\n"' | sed "s/|/'/g" > clash/RuleSet/china_ipv4.list
cat ip/china_ipv6.txt | perl -ne '/(.+\/\d+)/ && print "IP-CIDR6,$1,no-resolve\n"' | sed "s/|/'/g" > clash/RuleSet/china_ipv6.list
cat clash/RuleSet/china_ipv4.list > clash/RuleSet/china_all.list
cat clash/RuleSet/china_ipv6.list >> clash/RuleSet/china_all.list

cat ip/china_ipv4.txt | perl -ne '/(.+\/\d+)/ && print "  - IP-CIDR,$1,no-resolve\n"' | sed "s/|/'/g" > clash/RuleSet/china_ipv4.yaml
cat ip/china_ipv6.txt | perl -ne '/(.+\/\d+)/ && print "  - IP-CIDR6,$1,no-resolve\n"' | sed "s/|/'/g" > clash/RuleSet/china_ipv6.yaml
cat clash/RuleSet/china_ipv4.yaml > clash/RuleSet/china_all.yaml
cat clash/RuleSet/china_ipv6.yaml >> clash/RuleSet/china_all.yaml
sed -i '1 i\payload:' clash/RuleSet/china_all.yaml
sed -i '1 i\payload:' clash/RuleSet/china_ipv4.yaml
sed -i '1 i\payload:' clash/RuleSet/china_ipv6.yaml

# 直连域名
# direct_xiaonuo
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/apple.china.conf' > apple.china.tmp
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/Loyalsoldier/domain-list-custom/release/icloud.txt' > icloud.tmp
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/direct-list.txt' > direct-list.tmp

cat icloud.tmp | grep -E "^(full|domain):" | awk -F ':' '{printf "%s\n", $2}' | sed "s/|/'/g" > direct.tmp
cat apple.china.tmp | perl -ne '/^server=\/([^\/]+)\// && print "$1\n"' | sed "s/|/'/g" >> direct.tmp
cat direct-list.tmp | grep -Ev "^(regexp|keyword|full):" | perl -ne '/^(domain:|full:)?([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "$2\n"' | sed "s/|/'/g" >> direct.tmp
cat direct.tmp | xargs -n 1 | sort -u | uniq | sed "s/|/'/g" > direct.txt

# clash
mkdir -p clash/RuleSet
cat clash/RuleSet/XiaoNuoDirect.list.tmp > clash/RuleSet/XiaoNuoDirect.list
cat direct.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "DOMAIN-SUFFIX,+.$1\n"' | sed "s/|/'/g" >> clash/RuleSet/XiaoNuoDirect.list
cat clash/RuleSet/XiaoNuoDirect.yaml.tmp > clash/RuleSet/XiaoNuoDirect.yaml
cat direct.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "  - DOMAIN-SUFFIX,+.$1\n"' | sed "s/|/'/g" >> clash/RuleSet/XiaoNuoDirect.yaml

# smartdns
mkdir -p smartdns
cat direct.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "nameserver /.$1/xiaonuo\n"' | sed "s/|/'/g" > smartdns/smartdns_xiaonuo_domain.conf

# 代理域名
# proxy_xiaonuo

curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/google.china.conf' > google.china.tmp
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/proxy-list.txt' > proxy-list.tmp
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/gfw.txt' > gwf.tmp
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/greatfire.txt' > greatfire.tmp

cat google.china.tmp | perl -ne '/^server=\/([^\/]+)\// && print "$1\n"' | sed "s/|/'/g" > proxy.tmp
cat proxy-list.tmp | grep -Ev "^(regexp|keyword|full):" | perl -ne '/^(domain:|full:)?([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "$2\n"' | sed "s/|/'/g" >> proxy.tmp
cat gwf.tmp | grep -Ev "^(regexp|keyword|full):" | perl -ne '/^(domain:|full:)?([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "$2\n"' | sed "s/|/'/g" >> proxy.tmp
cat greatfire.tmp | grep -Ev "^(regexp|keyword|full):" | perl -ne '/^(domain:|full:)?([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "$2\n"' | sed "s/|/'/g" >> proxy.tmp
cat proxy.tmp | xargs -n 1 | sort -u | uniq | sed "s/|/'/g" > proxy.txt

# clash
cat proxy.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "DOMAIN-SUFFIX,+.$1\n"' | sed "s/|/'/g" > proxy_xiaonuo.list
echo "payload:" > proxy_xiaonuo.yaml
cat proxy.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "  - DOMAIN-SUFFIX,+.$1\n"' | sed "s/|/'/g" >> proxy_xiaonuo.yaml
# smartdns
cat proxy.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "nameserver /.$1/gwf\n"' | sed "s/|/'/g" > smartdns_gfw_domain.conf

# 顶级域名
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/Loyalsoldier/domain-list-custom/release/tld-!cn.txt' | perl -ne '/^domain:([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "$1\n"' | sed "s/|/'/g" | xargs -n 1 | sort -u | uniq > tld-not-cn.tmp
# clash
cat tld-not-cn.tmp | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "DOMAIN-SUFFIX,+.$1\n"' | sed "s/|/'/g" > gwf_tld.list
echo "payload:" > gwf_tld.yaml
cat tld-not-cn.tmp | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "  - DOMAIN-SUFFIX,+.$1\n"' | sed "s/|/'/g" >> gwf_tld.yaml
# smartdns
cat tld-not-cn.tmp | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "nameserver /.$1/gwf\n"' | sed "s/|/'/g" > smartdns_gfw_tld_domain.conf

# MMDB库
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/alecthw/mmdb_china_ip_list/release/Country.mmdb' > Country.mmdb

rm -rf *.tmp
