module KOSServer
  module VERSION
    FILE = File.expand_path('../../../VERSION', __FILE__)

    MAJOR, MINOR, TINY = File.read(FILE).chomp.split('.')

    ##
    # @return [String]
    def self.to_a() [MAJOR, MINOR, TINY] end

    STRING = self.to_a.compact.join('.').freeze

    ##
    # @return [String]
    def self.to_s() STRING end

    ##
    # @return [String]
    def self.to_str() STRING end
  end
end
