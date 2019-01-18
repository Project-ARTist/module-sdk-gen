# ARTist-SDK
The ARTist let's you build modules for ARTist without needing to download and set up AOSP. The SDK contains everything that's needed to build a module from your source code. 

## Fetching from AOSP
This repo uses the `src/fetch.sh` bash script to pull out the needed files from an AOSP build server. We assume you have a fully built version of AOSP available to pull the files from. 

To use the bash script we need to create a config file `~/.artist-sdk/ssh-config`.
It looks like this:
```
ssh_identity="identity"
aosp_root_path="~/aosp_root_dir/"
```
The `ssh-identity` refers to your `.ssh/config` file and `aosp_root_path` to your AOSP directory on your build server.
If you need to setup your `.ssh/config` file look into the [man pages](https://linux.die.net/man/5/ssh_config).

We recommend to use the corresponding make target:
```
make fetch
```

## Building the SDK

The SDK is a collection of all the files pulled from AOSP via `make fetch`. We currently support three output formats: .deb and .rpm packages that can be installed on the corresponding linux systems and a zip file that, when extracted, contains an install script that takes care of moving the SDK to the correct location.

### Build sdk.zip
1. `make zip`

### Build Debian package (.deb)
1. `sudo apt-get install build-essential debhelper`
2. `make deb`
3. `sudo dpkg -i releases/artist-sdk_w.x.y-z_amd64.deb` (install sdk [optional])

### Build Fedora/CentOS package (.rpm)
1. `sudo dnf install rpm-build`
2. `make rpm`
3. `sudo dnf install releases/artist-sdk-w.x.y-z.fcxx.x86_64.rpm` (install sdk [optional])
