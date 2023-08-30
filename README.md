# README
```
>
>   ____ _   _ _____ _______  __  ___ ___ 
>  / ___| | | | ____|__  /  \/  |/ _ \_ _|
> | |   | |_| |  _|   / /| |\/| | | | | | 
> | |___|  _  | |___ / /_| |  | | |_| | | 
>  \____|_| |_|_____/____|_|  |_|\___/___|
>
```

> This is *inkfin*'s messy dotfiles repository

Visit the [user guide in chezmoi.io](https://www.chezmoi.io/user-guide/command-overview/) for documents.

### Machine Specific Settings

> [documents](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/)

Config current profiles in `$HOME/.config/chezmoi/chezmoi.toml`.

```toml
# personal
[data]
    email = "inkfinite@qq.com"
    name = "inkfin"
    profile = "personal"
[git]
    autoCommit = false
    autoPush = false
[diff]
    command = "nvim"
    args = ["-d", "{{ .Destination }}", "{{ .Target }}"]
[merge]
    command = "nvim"
    args = ["-d", "{{ .Destination }}", "{{ .Source }}"]

# work
[data]
    email = ""
    name = "Ziyue Zhang"
    profile = "work"
```


