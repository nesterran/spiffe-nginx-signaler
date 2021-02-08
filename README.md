# spiffe-nginx-signaler
This repository contains a bash script, which is expected to be used as a command for spiffe-helper, to signal nginx to reload.

The script waits for a `SIGUSR1` signal, which is provided by spiffe-helper on certs rotation, and signals NGINX master process with a SIGHUP to reload the rotated certificates.

This is an example of the `helper.conf`:

```bash
agentAddress = "/run/spire/sockets/agent.sock"
cmd = "config/signaler.sh"
certDir = "certs/"
renewSignal = "SIGUSR1"
svidFileName = "svid.pem"
svidKeyFileName = "svid_key.pem"
svidBundleFileName = "svid_bundle.pem
```
