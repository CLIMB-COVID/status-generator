# status-generator

## Set up git push

### With SSH

Add a Host to your ssh config

    Host git-as-username
        HostName github.com
        User git
        PubKeyAuthentication yes
        IdentityFile /path/to/key

Clone the repo

    git clone git@git-as-username:CLIMB-COVID/status.git

### With PAT

Generate a `repo` scope token: https://github.com/settings/tokens

Clone the repo:

    git clone https://git-user:TOKEN@github.com/CLIMB-COVID/status.git
