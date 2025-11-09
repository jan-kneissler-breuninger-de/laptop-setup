## Setup new Macbook Instructions

## Chrome

Download from https://www.google.com/intl/de/chrome/ 
see also [downloaded](downloaded).

## brew 

See https://brew.sh/

 ```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> /Users/jakneissler/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/jakneissler/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## git

```
brew install git
ssh-keygen
```

Go to https://gitlab.breuni.de/-/user_settings/ssh_keys and register ssh key.

## Clone instructions (this repo)

```
git clone git@gitlab.breuni.de:jan-kneissler/laptop-setup.git
```


