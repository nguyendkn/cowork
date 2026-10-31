---
title: Network
description: Record the HTTP and HTTPS requests that leave this machine, like Fiddler or Charles.
---

# Network

Choose **Network** on the [launcher](./getting-started.md#launcher) for a request inspector. It runs a local proxy on `127.0.0.1:8888` and lists every request that passes through it: method, host, URL, status, size and time. Click a row to see its headers and body (gzip and deflate are unpacked).

## Capturing

- **Start** opens the proxy; **Stop** closes it. Closing the tab also stops it.
- **System proxy** (on by default) points the Windows proxy setting at the inspector while it runs, so Edge, Chrome and most apps go through it. The previous setting is put back on Stop, on closing the tab, and at the next start if Cowork was killed in between.
- **Clear** empties the list.
- Only apps that honour the Windows proxy setting are seen. Apps that ignore it are not captured.

## HTTPS

Without **Decrypt HTTPS**, an HTTPS connection is one `CONNECT` row showing the host and the bytes sent and received.

With it on, Cowork presents a certificate for each host, signed by its own root certificate, and records the decrypted requests. The client must trust that root, or its connection fails (the row says so). The root is created on first use as `cowork-root-ca.pem` in the `network` folder of the [configuration folder](./configuration-files.md). Cowork never installs it for you: import it into the trust store of the app you want to inspect. Anyone holding the matching `.key` file can impersonate sites to a machine that trusts the root, so keep the folder private and remove the root from the trust store when you are done.

## Limits

- WebSocket connections are forwarded, but their frames are not captured.
- HTTP/1.1 only; HTTP/2 is negotiated down.
- Bodies are kept up to 4 MB per message.
- Captured traffic is not saved between runs.
