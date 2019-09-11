
# DNS over HTTPS proxy

This is a packaged version of Frank Denis's Rust based [`doh-proxy`](https://github.com/jedisct1/rust-doh) project. It's configurable with environment variables:

* `LISTEN`: IP + port to listen for requests, defaults to `0.0.0.0:8080`
* `RESOLVER`: IP + port of upstream DNS resolver, defaults to `9.9.9.9:53`


# Deploy it globally on Fly

The image is optimized to run on [fly.io](https://fly.io/docs/future/). You'll need the `flyctl` command line utility, plus a fly.io account to make this article work for you.

If you're on a Mac, you can install the CLI with Homebrew:

~~~
brew install superfly/tap/flyctl
~~~

For other systems, use the install script:

~~~
curl https://get.fly.io/flyctl.sh | sh
~~~

[Create a Fly account](https://fly.io/app/sign-up) if you haven't already signed up. Then login with `flyctl auth login`:

~~~bash
➜  flyctl auth login
~~~
~~~
Email: flydev@fly.local
Password: **************
One Time Password (if any): ******
~~~

### 1. Create a Fly app

Pick a name for your new DNS over HTTPS service. Then create a Fly app:

~~~bash
➜  flyctl apps create
~~~
~~~
? App Name (leave blank to use an auto-generated name)
> [your-app-name]

✔ New app created
  Name    = [your-app-name]
  Owner   = fly
  Version = v0
  Status  =

Created fly.toml
~~~

### 2. Deploy `flyio/doh-proxy` from Docker Hub

~~~bash
➜  flyctl deploy -i flyio/doh-proxy:0.1.19
~~~
~~~
--> done
  Version     = v0
  Reason      = Deploy image
  Description =
  User        = flydev@fly.local
~~~

### 3. Use it

Your new Fly app includes dedicated IP addresses and a `[your-app-name].fly.dev` hostname with a valid certificate. You can see these by running `flyctl info`:

~~~bash
➜  flyctl info
~~~
~~~
App
  Name     = doh-proxy
  Owner    = fly
  Version  = 10
  Status   = pending
  Hostname = https://[your-app-name].fly.dev

Services
  TASK   PROTOCOL   PORT   INTERNAL PORT   HANDLERS
  app    tcp        80     8080            http
  app    tcp        443    8080            tls http

IP Addresses
  ADDRESS                                TYPE
  77.83.140.25                           v4
  2a09:8280:1:68a1:90f6:e320:d275:70f7   v6
~~~

The URL for DNS queries is: `https://[your-app-name].fly.dev/dns-query`, you can use it in any app that supports DNS over HTTPS.

You can also try it out with `curl`:

~~~bash
➜  curl -D - -sS "https://doh-proxy.fly.dev/dns-query?ct&dns=q80BAAABAAAAAAAAB2V4YW1wbGUDY29tAAABAAE" | strings
~~~
~~~
HTTP/2 200
content-length: 56
content-type: application/dns-message
x-padding: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
cache-control: max-age=43200
date: Wed, 11 Sep 2019 15:08:54 GMT
server: Fly/a04ef97 (Wed, 11 Sep 2019 11:18:30 +0000)
example
~~~
