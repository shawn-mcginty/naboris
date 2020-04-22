---
title: Security Best Practices
---

## Security Best Practices
Best practices for enhanced performance.

- [SSL/TLS](#ssl-tls)
- [Session Configuration](#session-configuration)
- [Follow HTTP Best Practices](#follow-http-best-practices)

#### <a name="ssl-tls" href="#ssl-tls">#</a> SSL/TLS
For any public traffic it's important to use SSL/TLS encryption. You may notice reading the docs that there is no SSL/TLS configuration options for naboris. That is because naboris communicates exclusively over unsecured http. Encryption is still possible, and highly recommended, by using a [reverse proxy](https://en.wikipedia.org/wiki/Reverse_proxy).

Here is an example configuration for an [nginx server](https://www.nginx.com/) using SSL/TLS and forwarding traffic to a local naboris server listening on port 8000. You can [find more information here](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/).

```nginx
server {
  listen 443 ssl;
  listen [::]:443 ssl;

  server_name ssltest.shawnmcginty.com www.ssltest.shawnmcginty.com;

  location / {
    proxy_pass http://localhost:8000;
  }

  ssl_certificate /fake/path/to/fullchain.pem;
  ssl_certificate_key /fake/path/to/privkey.pem;
}
```

#### <a name="session-configuration" href="#session-configuration">#</a> Session Configuration
If your server makes use of sessions it is important to change the default session id key. This makes many automated attacks much more difficult. [`ServerConfig.setSessionConfig`](http://localhost:3999/odocs/naboris/Naboris/ServerConfig/index.html#val-setSessionConfig) takes an optional parameter `~sidKey` making it very easy to change the default session id key.


#### <a name="follow-http-best-practices" href="#follow-http-best-practices">#</a> Follow HTTP Best Practices
There are many guidelines and best practices to follow when securing an HTTP server.

* [Use Security Related HTTP Headers](https://owasp.org/www-project-secure-headers/)
* Use a Reverse Proxy Server
* Run naboris With Minimum Privileges