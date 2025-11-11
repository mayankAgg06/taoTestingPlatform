# AWS EC2 Deployment Guide - TAO Testing Platform

Complete guide to deploy TAO Testing Platform on AWS EC2 with custom Sharda University branding.

## Prerequisites

- AWS Account
- SSH key pair for EC2 access
- Domain name (optional, for HTTPS)

## Step 1: Launch EC2 Instance

### Recommended Instance Configuration

- **Instance Type:** t3.medium or larger (2 vCPU, 4 GB RAM minimum)
- **AMI:** Ubuntu 22.04 LTS
- **Storage:** 30 GB GP3 (minimum)
- **Security Group Rules:**
  - SSH (22) - Your IP only
  - HTTP (80) - 0.0.0.0/0
  - HTTPS (443) - 0.0.0.0/0

### Launch Steps

1. Go to AWS Console → EC2 → Launch Instance
2. Select **Ubuntu Server 22.04 LTS**
3. Choose **t3.medium** instance type
4. Configure storage: **30 GB GP3**
5. Create/select security group with rules above
6. Download your SSH key pair (e.g., `tao-key.pem`)

## Step 2: Connect to EC2 Instance

```


# Set proper permissions for SSH key

chmod 400 tao-key.pem

# Connect to instance (replace with your instance IP)

ssh -i tao-key.pem ubuntu@YOUR_EC2_PUBLIC_IP

```

## Step 3: Install Docker and Docker Compose

```


# Update system

sudo apt update \&\& sudo apt upgrade -y

# Install Docker

sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose

sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add ubuntu user to docker group

sudo usermod -aG docker ubuntu

# Apply group changes (logout and login again, or use)

newgrp docker

# Verify installations

docker --version
docker-compose --version

```

## Step 4: Clone and Deploy TAO

```


# Clone repository

git clone https://github.com/mayankAgg06/taoTestingPlatform.git
cd taoTestingPlatform/example

# Start TAO

docker-compose -f docker-compose-dev.yml up -d --build

```

## Step 5: Monitor Installation

```


# Watch installation logs (takes 3-5 minutes)

docker logs -f example-tao-1

# Wait until you see: "TAO platform was successfully installed"

# Press Ctrl+C to exit log view

# Check all containers are running

docker-compose -f docker-compose-dev.yml ps

```

## Step 6: Configure Domain (Optional)

### For Production with HTTPS

1. **Point your domain to EC2 IP:**
   - Create an A record: `tao.yourdomain.com → EC2_PUBLIC_IP`

2. **Install Certbot for SSL:**

```

sudo apt install -y certbot python3-certbot-nginx

# Stop containers temporarily

cd ~/taoTestingPlatform/example
docker-compose -f docker-compose-dev.yml down

# Get SSL certificate

sudo certbot certonly --standalone -d tao.yourdomain.com

```

3. **Update nginx.conf for HTTPS:**

```

cd ~/taoTestingPlatform/example

# Backup original

cp nginx.conf nginx.conf.backup

# Create HTTPS-enabled nginx config

cat > nginx.conf << 'NGINX_EOF'
server {
listen 80;
server_name tao.yourdomain.com;
return 301 https://$server_name$request_uri;
}

server {
listen 443 ssl;
server_name tao.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/tao.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/tao.yourdomain.com/privkey.pem;
    
    index index.php index.html;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/html;
    
    # Serve static files directly
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
        try_files $uri =404;
    }
    
    location ~ ^/([^//]*)/(views|locales)/. {}
    location /tao/install {}
    location /tao/getFileFlysystem.php {
        rewrite  ^(.*)$ /tao/getFileFlysystem.php last;
    }
    location / {
        rewrite  ^(.*)$ /index.php;
    }
    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }
    
    sendfile off;
    client_max_body_size 100m;
    
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass tao:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }
    }
NGINX_EOF

```

4. **Update docker-compose to mount SSL certificates:**

```


# Edit docker-compose-dev.yml

nano docker-compose-dev.yml

```

Add to the `web` service volumes:

```

web:
image: nginx:1.19
ports:
- "80:80"
- "443:443"  \# Add this
depends_on:
- tao
volumes:
- ./nginx.conf:/etc/nginx/conf.d/default.conf
- tao-code:/var/www/html
- /etc/letsencrypt:/etc/letsencrypt:ro  \# Add this

```

5. **Update URL environment variable:**

```

    environment:
      DB_HOST: database
      DB_NAME: tao
      DB_USER: root
      DB_PASSWORD: r00t
      USER: admin
      PASSWORD: admin123
      URL: https://tao.yourdomain.com  # Add/update this
    ```

6. **Restart with new configuration:**

```

docker-compose -f docker-compose-dev.yml up -d --build

```

## Step 7: Access TAO Platform

**HTTP (Development):**
- URL: `http://YOUR_EC2_PUBLIC_IP`

**HTTPS (Production with domain):**
- URL: `https://tao.yourdomain.com`

**Login Credentials:**
- Username: `admin`
- Password: `admin123`

## Maintenance Commands

### View Logs
```

cd ~/taoTestingPlatform/example
docker logs -f example-tao-1
docker logs -f example-database-1
docker logs -f example-web-1

```

### Restart Services
```

docker-compose -f docker-compose-dev.yml restart

```

### Stop Services
```

docker-compose -f docker-compose-dev.yml down

```

### Backup Database
```

docker exec example-database-1 mysqldump -u root -pr00t tao > tao_backup_\$(date +%Y%m%d).sql

```

### Update Application
```

cd ~/taoTestingPlatform
git pull origin master
cd example
docker-compose -f docker-compose-dev.yml up -d --build

```

## Troubleshooting

### Containers Won't Start
```


# Check logs

docker-compose -f docker-compose-dev.yml logs

# Clean restart

docker-compose -f docker-compose-dev.yml down -v
docker-compose -f docker-compose-dev.yml up -d --build

```

### Database Connection Issues
```


# Check database is running

docker exec example-database-1 mysqladmin -u root -pr00t ping

# Restart database

docker-compose -f docker-compose-dev.yml restart database

```

### Port Already in Use
```


# Check what's using port 80

sudo lsof -i :80

# Stop conflicting service

sudo systemctl stop apache2  \# if Apache is running

```

## Security Best Practices

1. **Change default admin password** immediately after first login
2. **Enable SSL/HTTPS** for production
3. **Restrict SSH access** to your IP only
4. **Enable AWS CloudWatch** for monitoring
5. **Set up automated backups** using AWS Backup or cron jobs
6. **Use AWS RDS** instead of container database for production
7. **Set up CloudFront** for CDN and DDoS protection

## Cost Estimation

**Monthly AWS Costs (Approximate):**
- t3.medium EC2 instance: $30-35
- 30 GB EBS storage: $3
- Data transfer: $5-10
- **Total: ~$40-50/month**

## Auto-Start on Reboot

```


# Create systemd service

sudo nano /etc/systemd/system/tao.service

```

Add:

```

[Unit]
Description=TAO Testing Platform
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu/taoTestingPlatform/example
ExecStart=/usr/local/bin/docker-compose -f docker-compose-dev.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose-dev.yml down
User=ubuntu

[Install]
WantedBy=multi-user.target

```

Enable the service:

```

sudo systemctl enable tao.service
sudo systemctl start tao.service

```

## Support

For issues or questions:
- GitHub Issues: https://github.com/mayankAgg06/taoTestingPlatform/issues
- TAO Documentation: https://www.taotesting.com/resources/documentation/

---

**Deployed by:** Sharda University
**Last Updated:** November 2025
