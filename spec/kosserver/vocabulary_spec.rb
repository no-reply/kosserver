require 'spec_helper'

describe KOSServer::KOP do
  let(:term) { described_class.first }

  it 'has a `kop:` prefix' do
    expect(term.pname).to start_with 'kop:'
  end
end
