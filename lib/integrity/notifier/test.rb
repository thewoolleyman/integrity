require File.dirname(__FILE__) + "/../../integrity"

require "integrity/notifier/test/hpricot_matcher"
require "integrity/notifier/test/fixtures"

module Integrity
  class Notifier
    module Test
      def setup_database
        DataMapper.setup(:default, "sqlite3::memory:")
        DataMapper.auto_migrate!
      end

      def notifier_class
        Integrity::Notifier.const_get(notifier)
      end

      def notification(commit)
        notifier_class.new(commit).full_message
      end

      def notification_successful
        notification(Integrity::Commit.gen(:successful))
      end

      def notification_failed
        notification(Integrity::Commit.gen(:failed))
      end

      def assert_form_have_option(option, value=nil)
        selector = "input##{notifier.downcase}_notifier_#{option}"
        selector << "[@name='notifiers[#{notifier}][#{option}]']"
        selector << "[@value='#{value}']" if value

        assert_form_have_tag(selector, option => value)
      end

      def assert_form_have_options(*options)
        options.each { |option| assert_form_have_option(option) }
      end

      def assert_form_have_tag(selector, options={})
        content = options.delete(:content)
        assert_have_tag(form(options), selector, content)
      end

      def assert_have_tag(html, selector, content=nil)
        matcher = HpricotMatcher.new(html)
        assert_equal content, matcher.tag(selector) if content
        assert matcher.tag(selector)
      end

      def form(config={})
        Haml::Engine.new(notifier_class.to_haml).
          render(OpenStruct.new(:config => config))
      end
    end
  end
end
