# horizon-platform-template

This is a minimal template using the
[horizon-platform](https://gitlab.horizon-haskell.net/package-sets/horizon-platform) package set.

It contains the following packages:

* [horizon-platform-template](./horizon-platform-template) - Library code and application.

To rename this template, you can do the following in bash:

```
export NEW_NAME=my-haskell-package
export OLD_NAME=horizon-platform-template
find . -type f -exec sed -i "s/$OLD_NAME/$NEW_NAME/g" {} \;
mv $OLD_NAME $NEW_NAME
mv $NEW_NAME/$OLD_NAME.cabal $NEW_NAME/$NEW_NAME.cabal
```

## Development

```
nix develop
cabal build all
cabal run horizon-platform-template
```

## Building

```
nix run
```
