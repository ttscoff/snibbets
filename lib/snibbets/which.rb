# frozen_string_literal: true

module TTY
  # Additional app-bundle-specific routines for TTY::Which
  module Which
    def app_bundle(cmd)
      app = cmd.sub(/(\.app)?$/, '.app')
      command = cmd.dup
      command.sub!(/\.app$/, '')
      app_dirs = %w[/Applications /Applications/Setapp ~/Applications]
      return command if ::File.exist?(app)

      return command if app_dirs.any? { |dir| ::File.exist?(::File.join(dir, app)) }

      false
    end
    module_function :app_bundle

    def bundle_id?(cmd)
      cmd =~ /^\w+(\.\w+){2,}/
    end
    module_function :bundle_id?

    def app?(cmd)
      if file_with_path?(cmd)
        return cmd if app_bundle(cmd)
      else
        app = app_bundle(cmd)
        return app if app
      end

      false
    end
    module_function :app?
  end
end
