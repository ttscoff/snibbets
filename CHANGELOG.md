### 2.0.23

2023-04-16 10:33

#### IMPROVED

- Use Readline for entering info with `--paste`, allows for better editing experience
- Allow `--edit` with `--paste` to open the new snippet in your editor immediately

#### FIXED

- Code indentation with `--paste`

### 2.0.22

2023-04-16 09:33

#### IMPROVED

- Use Readline for entering info with `--paste`, allows for better editing experience

#### FIXED

- Code indentation with `--paste`

### 2.0.21

2023-04-16 09:04

#### IMPROVED

- Use leading and trailing hashes to make snippet titles more obvious when outputting All Snippets

### 2.0.20

2023-04-16 08:31

#### FIXED

- Fail to include skylighting themes in gem bundle
- Failure to recognize fenced code blocks with language specifiers containing hyphens

### 2.0.19

2023-04-16 08:05

#### FIXED

- A fenced code block following a line containing only 4+ spaces or tabs would get parsed as an indented code block
- Last fenced code block in a snippet might not be recognized

### 2.0.18

2023-04-16 06:57

#### FIXED

- If an invalid language (without a lexer) is supplied when using `--paste`, just use the input as the extension and tag

### 2.0.17

2023-04-16 06:31

#### NEW

- Languages specified in the opening fence of a code block are passed to the syntax highlighter (only affects Skylighting)

#### IMPROVED

- Add all available themes for Skylighting
- Allow a custom theme path to be provided for Skylighting by including a path in `highlight_theme` config
- Handle syntax highlighter errors, returning plain code if command fails

#### FIXED

- Disable syntax highlighting when command is being piped or redirected
- Don't syntax highlight clipboard code when using `--copy`

### 2.0.16

2023-04-15 22:15

#### FIXED

- Remove debugging output

### 2.0.15

2023-04-15 22:11

#### NEW

- Additional themes for skylighting: nord, monokai, solarized-light/dark

#### FIXED

- Bad path to highlighter themes for skylighting

### 2.0.14

2023-04-15 21:21

#### IMPROVED

- Better default themes for highlighters

#### FIXED

- Error with lexers_db when using higlighting

### 2.0.13

2023-04-15 19:57

#### NEW

- Option to include blockquotes (>) in output

### 2.0.12

2023-04-15 19:28

#### FIXED

- Lowered minimum ruby version to allow Ruby 2.6
- Failure to recognize snippet if title is on first line of file
- Errantly discarding first snippet in file with multiple snippets

### 2.0.11

2023-04-15 19:06

#### FIXED

- Overactive stripping of newlines within code blocks
- Syntax definition determination when adding new snippets

### 2.0.10

2023-04-15 16:28

#### FIXED

- Update dependencies for security
- Incorporate fixes from @robjwells addressing #3 and #4
- Incorporate fixes from @robjwells addressing #3 and #4
- Best menu CLI determination missing modules

### 2.0.9

2023-04-15 15:44

#### IMPROVED

- Allow setting `menus` config key to force Snibbets to use fzf, gum, or console menus
- Allow setting `menus` config key to force Snibbets to use fzf, gum, or console menus

#### FIXED

- If a header section contains no code blocks, don't display it in menu
- Remove leading and trailing newlines without affecting indentation

### 2.0.8

2023-04-15 15:41

#### IMPROVED

- Allow setting `menus` config key to force Snibbets to use fzf, gum, or console menus
- Allow setting `menus` config key to force Snibbets to use fzf, gum, or console menus

#### FIXED

- If a header section contains no code blocks, don't display it in menu
- Remove leading and trailing newlines without affecting indentation

### 2.0.6

2023-04-15 11:55

#### IMPROVED

- Refactor script as modules and classes

### 2.0.2

Initial release as a gem
