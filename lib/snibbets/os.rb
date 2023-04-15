# frozen_string_literal: true

module Snibbets
  module OS
    class << self
      ##
      ## Platform-agnostic copy command
      ##
      ## @param      text  The text to copy
      ##
      def copy(text)
        os = RbConfig::CONFIG['target_os']
        case os
        when /darwin.*/i
          `echo #{Shellwords.escape(text)} | pbcopy`
        else
          if TTY::Which.exist?('xclip')
            `echo #{Shellwords.escape(text)} | xclip -sel c`
          elsif TTY::Which.exist('xsel')
            `echo #{Shellwords.escape(text)} | xsel -ib`
          else
            puts 'Copy not supported on this system, please install xclip or xsel.'
          end
        end
      end

      ##
      ## Platform-agnostic paste command
      ##
      def paste
        os = RbConfig::CONFIG['target_os']
        case os
        when /darwin.*/i
          `pbpaste -pboard general -Prefer txt`
        else
          if TTY::Which.exist?('xclip')
            `xclip -o -sel c`
          elsif TTY::Which.exist('xsel')
            `xsel -ob`
          else
            puts 'Paste not supported on this system, please install xclip or xsel.'
          end
        end
      end

      ##
      ## Platform-agnostic open command
      ##
      ## @param      file  [String] The file to open
      ##
      def open(file, app: nil)
        os = RbConfig::CONFIG['target_os']
        case os
        when /darwin.*/i
          darwin_open(file, app: app)
        when /mingw|mswin/i
          win_open(file)
        else
          linux_open(file)
        end
      end

      ##
      ## macOS open command
      ##
      ## @param      file  The file
      ## @param      app   The application
      ##
      def darwin_open(file, app: nil)
        if app
          `open -a "#{app}" #{Shellwords.escape(file)}`
        else
          `open #{Shellwords.escape(file)}`
        end
      end

      ##
      ## Windows open command
      ##
      ## @param      file  The file
      ##
      def win_open(file)
        `start #{Shellwords.escape(file)}`
      end

      ##
      ## Linux open command
      ##
      ## @param      file  The file
      ##
      def linux_open(file)
        if TTY::Which.exist?('xdg-open')
          `xdg-open #{Shellwords.escape(file)}`
        else
          notify('{r}Unable to determine executable for `xdg-open`.')
        end
      end
    end
  end
end
