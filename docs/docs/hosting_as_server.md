---
layout: default
title: Hosting as a Server
nav_order: 8
permalink: docs/hosting-as-server
---

# Hosting as a Server

This application requires a large amount of computational power (CPU), on-hand memory (RAM), and possibly the storage of large amounts of mass-spec data (Storage), so make sure your server has enough resources. We recommend using a desktop computer as a server, as opposed to hosting on a cloud server.

### Internal (Organizational) Usage

If you wish to host a server for internal usage, i.e., within an organizational intranet, you can change the host IP to "0.0.0.0" instead of "127.0.0.1", which exposes the server outside of the machine itself.

### Public Access

It is not recommended to upload this application to the [shinyapps.io](http://www.shinyapps.io/) host as this program requires a lot of bandwidth and it may quickly overrun the quotas of the free account.

This server can instead be run locally on a powerful desktop machine, and then made available publicly using a reverse-proxy, such as [ngrok](https://ngrok.com/) or [frp](https://github.com/fatedier/frp). This solution requires a web server to set up the forwarding.