# frozen_string_literal: true

RSpec.describe 'tooling artifacts' do
  it 'commits codegen metadata' do
    expect(File).to exist(File.expand_path('../CODEGEN_VERSION', __dir__))
    expect(File.read(File.expand_path('../package.json', __dir__))).to include('"generate"')
    expect(File.read(File.expand_path('../scripts/verify-generated.ts',
                                      __dir__))).to include('Generated artifact is stale')
  end
end
