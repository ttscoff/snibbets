# frozen_string_literal: true

module Snibbets
  class Config
    attr_accessor :options

    DEFAULT_OPTIONS = {
      all: false,
      copy: false,
      editor: nil,
      extension: 'md',
      highlight: false,
      interactive: true,
      launchbar: false,
      menus: nil,
      name_only: false,
      output: 'raw',
      source: File.expand_path('~/Dropbox/Snippets')
    }.freeze

    def initialize
      custom_config = read_config
      @options = DEFAULT_OPTIONS.merge(custom_config)
      @options[:editor] ||= best_editor
      @options[:menus] ||= best_menu

      write_config unless @options.equal?(custom_config)
    end

    def best_menu
      return 'fzf' if TTY::Which.exist?('fzf')
      return 'gum' if TTY::Which.exist?('gum')
      'console'
    end

    def best_editor
      if ENV['EDITOR']
        ENV['EDITOR']
      elsif ENV['GIT_EDITOR']
        ENV['GIT_EDITOR']
      else
        return TTY::Which.which('code') if TTY::Which.exist?('code')

        return TTY::Which.which('subl') if TTY::Which.exist?('subl')

        return TTY::Which.which('bbedit') if TTY::Which.exist?('bbedit')

        return TTY::Which.which('nano') if TTY::Which.exist?('nano')

        return TTY::Which.which('vim') if TTY::Which.exist?('vim')

        'TextEdit'
      end
    end

    def config_dir
      File.expand_path('~/.config/snibbets')
    end

    def config_file
      File.join(config_dir, 'snibbets.yml')
    end

    def read_config
      if File.exist?(config_file)
        YAML.safe_load(IO.read(config_file)).symbolize_keys
      else
        {}
      end
    end

    def write_config
      raise 'Error creating config directory, file exists' if File.exist?(config_dir) && !File.directory?(config_dir)

      FileUtils.mkdir_p(config_dir) unless File.directory?(config_dir)
      File.open(config_file, 'w') { |f| f.puts(YAML.dump(@options.stringify_keys)) }
    end
  end
end
