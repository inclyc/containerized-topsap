#!/usr/bin/env bash

expect_script=/run/topvpn.expect
cat > "$expect_script" <<EOF
#!/usr/bin/env expect
spawn /topsap/topvpn login

expect "Input your server address(example:192.168.74.12:8112): "
send "$TOPVPN_SERVER\r"

expect "Choose the Login_mode: "
send "1\r"

expect "User: "
send "$TOPVPN_USERNAME\r"

expect "Password: "
send "$TOPVPN_PASSWORD\r"

wait
EOF
chmod +x "$expect_script"
"$expect_script"
