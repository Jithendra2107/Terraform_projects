#!/bin/bash
apt update
apt install -y apache2

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
-H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s)

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s \
http://169.254.169.254/latest/meta-data/instance-id)

# Install the AWS CLI
apt install -y awscli

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Terraform Project Server 2</title>

<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">

<style>
*{
    margin:0;
    padding:0;
    box-sizing:border-box;
    font-family:'Poppins',sans-serif;
}

body{
    min-height:100vh;
    display:flex;
    justify-content:center;
    align-items:center;
    background:linear-gradient(-45deg,#667eea,#764ba2,#6a11cb,#2575fc);
    background-size:400% 400%;
    animation:gradientBG 12s ease infinite;
    color:white;
}

@keyframes gradientBG{
    0%{background-position:0% 50%;}
    50%{background-position:100% 50%;}
    100%{background-position:0% 50%;}
}

.container{
    width:90%;
    max-width:900px;
    padding:40px;
    text-align:center;
    background:rgba(255,255,255,0.12);
    backdrop-filter:blur(15px);
    border:1px solid rgba(255,255,255,0.2);
    border-radius:20px;
    box-shadow:0 15px 35px rgba(0,0,0,0.3);
}

h1{
    font-size:3rem;
    margin-bottom:15px;
    animation:glow 2s ease-in-out infinite alternate;
}

@keyframes glow{
    from{
        text-shadow:0 0 10px #fff;
    }
    to{
        text-shadow:0 0 25px #00f7ff,0 0 35px #00f7ff;
    }
}

.subtitle{
    font-size:1.2rem;
    opacity:0.9;
    margin-bottom:30px;
}

.instance-card{
    background:rgba(255,255,255,0.15);
    padding:20px;
    border-radius:15px;
    margin:25px 0;
}

.instance-id{
    color:#00ff99;
    font-weight:700;
    font-size:1.2rem;
}

.status{
    display:inline-block;
    margin-top:20px;
    padding:10px 20px;
    background:#00c853;
    border-radius:50px;
    font-weight:600;
}

.footer{
    margin-top:25px;
    opacity:0.8;
    font-size:0.9rem;
}
</style>
</head>

<body>

<div class="container">

    <h1>🚀 Terraform Project Server 2</h1>

    <p class="subtitle">
        Infrastructure Provisioned with Terraform on AWS
    </p>

    <div class="instance-card">
        <h2>EC2 Instance Details</h2>
        <br>
        <p>
            Instance ID: <span class="instance-id">$INSTANCE_ID</span>
        </p>
    </div>

    <div class="status">
        ✅ Server Running Successfully
    </div>

    <div class="footer">
        <p>Hosted on AWS EC2 | Automated using Terraform</p>
    </div>

</div>

</body>
</html>
EOF

systemctl start apache2
systemctl enable apache2