module Integrity
  class Notifier
    class Markdown < Notifier::Base
      def self.to_haml
        <<-haml
%p.normal
  %label{ :for => "markdown_notifier_file" } File
  %input.text#markdown_notifier_file{ :name => "notifiers[Markdown][file]", :type => "text", :value => config["file"] }
        haml
      end

      def initialize(build, config={})
        super
        debugger
        @file = @config["file"]
      end

      def deliver!
        File.open(@file, "a") do |f|
          f.puts "#{short_message}"
          f.puts "================"
          f.puts full_message
        end
      end
    end
  end
end
