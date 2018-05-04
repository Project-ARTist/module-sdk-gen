# ARTist-SDK
The ARTist let's you build modules for ARTist without needing to download and set up AOSP. The SDK contains everything that's needed to build a module from your source code.

## Fetching from AOSP
This repo uses the `src/fetch.sh` bash script to pull out the needed files from an AOSP build server. To use the bash script we need to create a config file `~/.artist-sdk/ssh-config`.
It looks like this:
```
ssh_identity="identity"
aosp_root_path="~/aosp_root_dir/"
```
The `ssh-identity` refers to your `.ssh/config` file and `aosp_root_path` to your AOSP directory on your build server.
If you need to setup your `.ssh/config` file look into the [man pages](https://linux.die.net/man/5/ssh_config).

## Build sdk.zip
1. `make zip`

## Build Debian package (.deb)
1. `sudo apt-get install build-essential debhelper`
2. `make deb`
3. `sudo dpkg -i releases/artist-sdk_w.x.y-z_amd64.deb` (install sdk [optional])

## Build Fedora/CentOS package (.rpm)
1. `sudo dnf install rpm-build`
2. `make rpm`
3. `sudo dnf install releases/artist-sdk-w.x.y-z.fcxx.x86_64.rpm` (install sdk [optional])
