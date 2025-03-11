# pyshim-build-tools
To get Build Tools for Visual Studio 2017 and 2019 (idea)

To operate pyenv-win like *nix, compiling python (without installer) sometimes needed.
For example, if someone need Python 3.6.9 or 3.6.10 there is no way to get binary in official site.
Also, official installer does not allow older python version installation.

From this idea, required tools to build CPython to get nupkg from source. some steps are recorded with example script.

TL;DR
* install via local layouted buildtools v16 (Visual Studio 2019)
* install vial Windows SDK 10.0.15063.x from buildtools v15 

and build
