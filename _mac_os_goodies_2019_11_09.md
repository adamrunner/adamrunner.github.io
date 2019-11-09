## MacOS Goodies

Just a collection of nice to have things that I've collected over the years to make using MacOS "better" (subjectively). 

### Eliminate the delay for showing the dock

```sh
defaults write com.apple.Dock autohide-delay -float 0 && killall Dock
```

