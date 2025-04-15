# Need help making packages

The problem I'm having is making packages the way I would like.

In `horizon-platoform-template/default.nix` compare `buildExe` with `oneTarget` 

When using `buildExe` I get the result I want, but not by using native nix, which is what I am trying to do with `oneTarget`

when using `oneTarget` this is what happens:

```
nix build .#example
error:
       … in the left operand of the update (//) operator
         at /nix/store/0d3h8gi2q46fb4l563h6pginjw2a90r4-source/pkgs/development/haskell-modules/lib/compose.nix:48:5:
           47|     ))
           48|     // {
             |     ^
           49|       overrideScope = scope: overrideCabal f (drv.overrideScope scope);

       … while calling a functor (an attribute set with a '__functor' attribute)
         at /nix/store/0d3h8gi2q46fb4l563h6pginjw2a90r4-source/pkgs/development/haskell-modules/lib/compose.nix:41:6:
           40|     f: drv:
           41|     (drv.override (
             |      ^
           42|       args:

       (stack trace truncated; use '--show-trace' to show the full, detailed trace)

       error: function 'anonymous lambda' called with unexpected argument 'disallowGhcReference'
       at /nix/store/m9s94alic7s2r6v47p7lwfj58ibc076a-source/pkgs/development/haskell-modules/generic-builder.nix:13:1:
           12|
           13| { pname
             | ^
           14| # Note that ghc.isGhcjs != stdenv.hostPlatform.isGhcjs.

```

I'm not sure what to do about `disallowGhcReference`. Also, I'm trying to develop nix troubleshooting skills,
so showing methods of troubleshooting this type of problem is valued over getting a succint solution.
