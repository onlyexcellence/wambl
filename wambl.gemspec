
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "wambl/version"

Gem::Specification.new do |spec|

  spec.name          = "wambl"
  spec.version       = Wambl::VERSION
  spec.authors       = ["onlyexcellence"]
  spec.email         = ["will@wambl.com"]

  spec.summary       = %q{Wambl Tools}
  spec.description   = %q{Wambl tools}
  spec.homepage      = "https://github.com/onlyexcellence/wambl"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "https://github.com/onlyexcellence/wambl.git"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "activesupport"
  spec.add_dependency "colorize"

  spec.files = %w{
    lib/wambl.rb
    lib/wambl/tools/threader.rb
  }

end
