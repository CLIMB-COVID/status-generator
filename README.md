# status-generator

### Set up git push

Add a Host to your ssh config

    Host git-as-username
        HostName github.com
        User git
        PubKeyAuthentication yes
        IdentityFile /path/to/key

Clone the repo

    git clone git@git-as-username:CLIMB-COVID/status.git

