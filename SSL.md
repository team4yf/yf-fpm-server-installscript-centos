# Use a free ssl

- 1) get a certbot shell client
  ```bash
  wget https://dl.eff.org/certbot-auto
  chmod a+x certbot-auto
  ```
- 2) stop the nginx
  ```bash
  service stop nginx
  ```

- 3) generate a ssl cert
  ```bash
  ./certbot-auto certonly --standalone --email `你的邮箱地址` -d `你的域名1` -d `你的域名2`
  ```

- 4) list the certs
  ```bash
  ls -l /etc/letsencrypt/live/
  ```

- 5) modify the nginx.conf ssl config

- 6) restart nginx server
  ```bash
  service nginx start
  ```

- 7) You have to renew the cert each 3M
  ```bash
  ./certbot-auto renew 
  ```

- 8) Make a corn job to run it auto
  ```bash
  # at the 00:00 first day of every month
  crontab -e
  0 0 1 * * certbot renew
  ```

## The ngix ssl conf example
```bash
server{
  listen 80;
  server_name api.yunplus.io;
  listen 443 ssl;
  location / {
    proxy_pass http://127.0.0.1:9991;
  }
  ssl on;
  ssl_certificate /etc/letsencrypt/live/yunplus.io/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/yunplus.io/privkey.pem;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2; #按照这个协议配置
  ssl_ciphers HIGH:!aNULL:!MD5;
  ssl_prefer_server_ciphers on;
}
```