require 'spec_helper'

describe KOSServer::VERSION do
  describe '#to_a' do
    it 'gives version as array of parts' do
      expect(described_class.to_a).to contain_exactly(an_instance_of(String),
                                                      an_instance_of(String),
                                                      an_instance_of(String))
    end
  end

  describe '#to_s' do
    it 'gives version as string' do
      expect(described_class.to_s).to match /[0-9]+\.[0-9]+\.[0-9]+/
    end
  end
end
