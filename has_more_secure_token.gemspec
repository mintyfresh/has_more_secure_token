# frozen_string_literal: true

require_relative 'lib/has_more_secure_token/version'

Gem::Specification.new do |spec|
  spec.name = 'has_more_secure_token'
  spec.version = HasMoreSecureToken::VERSION
  spec.authors = ['Minty Fresh']
  spec.email = ['7896757+mintyfresh@users.noreply.github.com']

  spec.summary     = "Time-safe finders for ActiveRecord's has_secure_token."
  spec.description = spec.summary
  spec.homepage    = 'https://github.com/mintyfresh/has_more_secure_token'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['allowed_push_host']     = 'https://rubygems.org'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ spec/ features/ .git Gemfile])
    end
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord'

  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rspec'
end
