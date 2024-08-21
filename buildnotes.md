template: gem, git, gli, project, sublime
sublime_project: snibbets
executable: na
readme: src/\_README.md
changelog: CHANGELOG.md
project: snibbets

# Snibbets

A plain text snippet manager

## Develop

@run(subl .)

## Dummy

@run(bundle exec bin/snibbets $@)

## Deploy

You no longer need to manually bump the version, it will be incremented when this task runs.

```run Update Changelog
#!/bin/bash

changelog -u
```

@include(project:Update GitHub README)

```run Update README
#!/bin/bash

changelog | git commit -a -F -
git pull
git push
```

@include(gem:Release Gem) Release Gem
@include(project:Update Blog Project) Update Blog Project
@run(rake bump[patch]) Bump Version

@run(git commit -am 'Version bump')

@after
Don't forget to publish the website!
@end
