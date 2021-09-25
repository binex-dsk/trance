A dead-simple, self-hostable file-upload service, written in C using [Mongoose](https://cesanta.com).

This project is largely based off of my [pacebin](https://git.swurl.xyz/swirl/pacebin), itself based off of my [clink](https://git.swurl.xyz/swirl/clink) project. The code is nearly identical to that found on pacebin, as they're pretty much the exact same thing.

Please access this project on my [Gitea](https://git.swurl.xyz/swirl/trance) instance, NOT GitHub.

# Features
- Tiny executable size (~80kb)
- No dependencies, just libc
- Extremely simple to use--basic POST and GET
- No bloated webapp, just a simple reverse proxy
- Super light on resources
- Basic and easy file deletion
- No duplicate filenames
- Fast!
- Basic filesystem storage--easy to manage without external programs/libraries

# Self-Hosting
You can host this yourself.

Note: all commands here are done as root.

## Building & Installing
To build this project, you'll need a libc implementation (only tested with glibc), optionally a separate libcrypt implementation, and Git. Most Linux distributions should have all of these by default, but in case yours doesn't:
- `pacman -S glibc libxcrypt git`
- `emerge --ask sys-libs/glibc dev-vcs/git`
- `apt install glibc git`

1. Clone this repository:

```bash
git clone https://git.swurl.xyz/swirl/trance && cd trance
```

2. Now, you need to compile. When compiling, you can easily change the maximum size of uploaded files. Simply specify the variable `MAX_SIZE`; i.e. for a 100MB limit: `make MAX_SIZE=104857600`. This defaults to 50MB.
```bash
make
```

3. Now, you need to install. NGINX and systemd files are provided in this project; you may choose not to install them.

For all install commands, you may optionally provide `prefix` and `DESTDIR` options. This is useful for packagers; i.e. for a PKGBUILD: `make prefix=/usr DESTDIR=${pkgdir} install`.

Available install commands are as follows:
- `make install` installs the executable, NGINX, and systemd files.
- `make install-bin` installs the executable file.
- `make install-systemd` installs the systemd file, as well as its environment file.
- `make install-nginx` installs the NGINX file.

For example, on a non-systemd system using NGINX, you would run `make install-bin install-nginx`.

4. If using systemd, change the environment file to reflect your desired options:
```bash
vim /etc/trance.conf
```

5. You can now enable and start the service:
```bash
systemctl enable --now trance
```

The server should now be running on localhost at port 8082.

## NGINX Reverse Proxy
An NGINX file is provided with this project. Sorry, no support for Apache or lighttpd or anything else; should've chosen a better HTTP server.

For this, you'll need [NGINX](https://nginx.org/en/download.html) (obviously), certbot, and its NGINX plugin. Most Linux distributions should have these in their repositories, i.e.:
- `pacman -S nginx certbot-nginx`
- `emerge --ask www-servers/nginx app-crypt/certbot-nginx`
- `apt install nginx python-certbot-nginx`

This section assumes you've already followed the last.

1. Change the domain in the NGINX file:
```bash
sed -i 's/your.doma.in/[DOMAIN HERE]' /etc/nginx/sites-available/trance
```

2. Enable the site:
```bash
ln -s /etc/nginx/sites-{available,enabled}/trance
```

3. Enable HTTPS for the site:
```bash
certbot --nginx -d [DOMAIN HERE]
```

4. Enable and start NGINX:
```bash
systemctl enable --now nginx
```

If it's already running, reload:
```bash
systemctl reload nginx
```

Your site should be running at https://your.doma.in. Test it by going there, and trying the examples. If they don't work, open an issue.

# Contributions
Contributions are always welcome.

# FAQ
## A user has made a file containing bad content! What do I do?
Clean it up, janny!

Deleting a file can be done simply by running:
```bash
rm /srv/trance/*/SHORTIDHERE
```

The short ID is the random hexadecimal string BEFORE the filename. You can usually find it through NGINX logs or something.

Replace `/srv/trance` with whatever your data directory is.

## Can I blacklist certain words from being used in files and filenames?
No. While it might be possible through some NGINX stuff, **this is not supported nor it is encouraged.**

## Is this an IP grabber?
No. If access logs are turned on, then the server administrator can see your IP, but management of access logs is up to them.

## Can I use this without a reverse proxy?
Probably, I don't know. Won't have HTTPS though, so either way, I heavily recommend you use a reverse proxy.

## What's the seed for?
The seed is used for generating deletion keys. Do not share it whatsoever.

## What operating systems are supported?
I've only tested it on my Arch Linux server, but it should work perfectly fine on all Linux distributions. Probably doesn't work on Windows.

## Can I run this in a subdirectory of my site?
Yes. Simply put the `proxy_pass` directive in a subdirectory, i.e.:
```
location /paste {
    proxy_pass http://localhost:8082;
}
```

## Why'd you make this?
Every file upload service sucks. Simple as. All of the self-hostable options I could find had problems, including:
- Loads of unnecessary dependencies
- Huge executable size (Go lol)
- Used some bloated webapp with no basic API
- Feature bloat; i.e. encryption, auto-expiration, etc.
- Written in Ruby, NodeJS, PHP, or some other bad language
- No direct reverse-proxy support
- Reliance on statically serving the index files
- Reliance on static configuration like the host
- Reliance on other services (i.e. link shorteners)

This project is intended to be a file upload service that is **as simple as possible**. Literally just upload, download, and delete files. That's it.

Also, there were surprisingly none written in C.
