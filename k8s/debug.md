# 调大kubelet日志级别

curl -k  -X PUT   -H  'Authorization: Bearer kubeletpassword'  https://localhost:10250/debug/flags/v -d "1"

