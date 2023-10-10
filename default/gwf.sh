# IP库
mkdir -p ip
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://ispip.clang.cn/all_cn.txt' > ip/ChinaIpv4.txt
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://ispip.clang.cn/all_cn_ipv6.txt' > ip/ChinaIpv6.txt
cat ip/ChinaIpv4.txt > ip/ChinaIp.txt
cat ip/ChinaIpv6.txt >> ip/ChinaIp.txt

# clash 规则
mkdir -p clash
cat ip/ChinaIpv4.txt | perl -ne '/(.+\/\d+)/ && print "IP-CIDR,$1,no-resolve\n"' | sed "s/|/'/g" > clash/RuleSet/ChinaIpv4.list
cat ip/ChinaIpv6.txt | perl -ne '/(.+\/\d+)/ && print "IP-CIDR6,$1,no-resolve\n"' | sed "s/|/'/g" > clash/RuleSet/ChinaIpv6.list
cat clash/RuleSet/ChinaIpv4.list > clash/RuleSet/ChinaIp.list
cat clash/RuleSet/ChinaIpv6.list >> clash/RuleSet/ChinaIp.list

cat ip/ChinaIpv4.txt | perl -ne '/(.+\/\d+)/ && print "  - IP-CIDR,$1,no-resolve\n"' | sed "s/|/'/g" > clash/RuleSet/ChinaIpv4.yaml
cat ip/ChinaIpv6.txt | perl -ne '/(.+\/\d+)/ && print "  - IP-CIDR6,$1,no-resolve\n"' | sed "s/|/'/g" > clash/RuleSet/ChinaIpv6.yaml
cat clash/RuleSet/ChinaIpv4.yaml > clash/RuleSet/ChinaIp.yaml
cat clash/RuleSet/ChinaIpv6.yaml >> clash/RuleSet/ChinaIp.yaml
sed -i '1 i\payload:' clash/RuleSet/ChinaIp.yaml
sed -i '1 i\payload:' clash/RuleSet/ChinaIpv4.yaml
sed -i '1 i\payload:' clash/RuleSet/ChinaIpv6.yaml

# 直连域名
# direct
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/apple.china.conf' > apple.china.tmp
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/Loyalsoldier/domain-list-custom/release/icloud.txt' > icloud.tmp
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/direct-list.txt' > direct-list.tmp

cat icloud.tmp | grep -E "^(full|domain):" | awk -F ':' '{printf "%s\n", $2}' | sed "s/|/'/g" > direct.tmp
cat apple.china.tmp | perl -ne '/^server=\/([^\/]+)\// && print "$1\n"' | sed "s/|/'/g" >> direct.tmp
cat direct-list.tmp | grep -Ev "^(regexp|keyword|full):" | perl -ne '/^(domain:|full:)?([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "$2\n"' | sed "s/|/'/g" >> direct.tmp
cat direct.tmp | xargs -n 1 | sort -u | uniq | sed "s/|/'/g" > direct.txt
sed -i '/cloudflare/d' direct.txt

# clash
mkdir -p clash/RuleSet
cat clash/RuleSet/XiaoNuoDirect.list.tmp > clash/RuleSet/XiaoNuoDirect.list
cat direct.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "DOMAIN-SUFFIX,$1\n"' | sed "s/|/'/g" >> clash/RuleSet/XiaoNuoDirect.list
cat clash/RuleSet/XiaoNuoDirect.yaml.tmp > clash/RuleSet/XiaoNuoDirect.yaml
cat direct.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "  - DOMAIN-SUFFIX,$1\n"' | sed "s/|/'/g" >> clash/RuleSet/XiaoNuoDirect.yaml

# smartdns
mkdir -p smartdns
cat direct.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "nameserver /.$1/xiaonuo\n"' | sed "s/|/'/g" > smartdns/smartdns_xiaonuo_domain.conf

# 代理域名
# proxy

curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/google.china.conf' > google.china.tmp
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/proxy-list.txt' > proxy-list.tmp
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/gfw.txt' > gwf.tmp
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/greatfire.txt' > greatfire.tmp
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/Loyalsoldier/domain-list-custom/release/tld-!cn.txt' | perl -ne '/^domain:([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "$1\n"' | sed "s/|/'/g" | xargs -n 1 | sort -u | uniq > tld-not-cn.tmp

cat tld-not-cn.tmp > proxy.tmp
cat google.china.tmp | perl -ne '/^server=\/([^\/]+)\// && print "$1\n"' | sed "s/|/'/g" >> proxy.tmp
cat proxy-list.tmp | grep -Ev "^(regexp|keyword|full):" | perl -ne '/^(domain:|full:)?([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "$2\n"' | sed "s/|/'/g" >> proxy.tmp
cat gwf.tmp | grep -Ev "^(regexp|keyword|full):" | perl -ne '/^(domain:|full:)?([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "$2\n"' | sed "s/|/'/g" >> proxy.tmp
cat greatfire.tmp | grep -Ev "^(regexp|keyword|full):" | perl -ne '/^(domain:|full:)?([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "$2\n"' | sed "s/|/'/g" >> proxy.tmp
cat proxy.tmp | xargs -n 1 | sort -u | uniq | sed "s/|/'/g" > proxy.txt

# clash
mkdir -p clash/RuleSet
cat clash/RuleSet/XiaoNuoProxy.list.tmp> clash/RuleSet/XiaoNuoProxy.list
cat proxy.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "DOMAIN-SUFFIX,$1\n"' | sed "s/|/'/g" >> clash/RuleSet/XiaoNuoProxy.list
cat clash/RuleSet/XiaoNuoProxy.yaml.tmp > clash/RuleSet/XiaoNuoProxy.yaml
cat proxy.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "  - DOMAIN-SUFFIX,$1\n"' | sed "s/|/'/g" >> clash/RuleSet/XiaoNuoProxy.yaml

# 拒绝域名
# reject
mkdir -p clash/RuleSet
cat clash/RuleSet/XiaoNuoReject.list.tmp> clash/RuleSet/XiaoNuoReject.list
cat clash/RuleSet/XiaoNuoReject.yaml.tmp > clash/RuleSet/XiaoNuoReject.yaml

# smartdns
mkdir -p smartdns
cat proxy.txt | perl -ne '/([-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*)/ && print "nameserver /.$1/gwf\n"' | sed "s/|/'/g" > smartdns/smartdns_gfw_domain.conf

# MMDB库
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/alecthw/mmdb_china_ip_list/release/Country.mmdb' > Country.mmdb

rm -rf *.tmp

# chatgpt
pip3 install pandora pandora-chatgpt
mkdir -p chatgpt
python3 default/chatgpt_accounts_token.py default/chatgpt_accounts.txt > chatgpt/chatgpt_token.txt
