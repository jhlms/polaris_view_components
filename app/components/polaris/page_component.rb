# frozen_string_literal: true

module Polaris
  class PageComponent < Polaris::Component
    renders_one :title_metadata
    renders_one :thumbnail, Polaris::ThumbnailComponent
    renders_one :primary_action, ->(primary: true, **system_arguments) do
      Polaris::ButtonComponent.new(primary: primary, **system_arguments)
    end
    renders_one :custom_primary_action
    renders_one :action_group, "ActionGroupComponent"

    def initialize(
      title: nil,
      subtitle: nil,
      compact_title: false,
      back_url: nil,
      prev_url: nil,
      next_url: nil,
      narrow_width: false,
      full_width: false,
      divider: false,
      secondary_actions: [],
      **system_arguments
    )
      @title = title
      @subtitle = subtitle
      @compact_title = compact_title
      @back_url = back_url
      @prev_url = prev_url
      @next_url = next_url
      @narrow_width = narrow_width
      @full_width = full_width
      @divider = divider
      @secondary_actions = secondary_actions
      @system_arguments = system_arguments
    end

    def header_arguments
      {
        tag: "div",
        classes: class_names(
          "Polaris-Page-Header",
          "Polaris-Page-Header--mobileView",
          "Polaris-Page-Header--mediumTitle",
          "Polaris-Page-Header--hasNavigation": @back_url.present?,
          "Polaris-Page-Header--noBreadcrumbs": @back_url.blank?
        )
      }
    end

    def subtitle_arguments
      {
        tag: "div",
        classes: class_names(
          "Polaris-Header-Title__SubTitle",
          "Polaris-Header-Title__SubtitleCompact": @compact_title
        )
      }
    end

    def content_arguments
      {
        tag: "div",
        classes: class_names(
          "Polaris-Page__Content",
          "Polaris-Page--divider": @divider
        )
      }
    end

    def system_arguments
      @system_arguments.tap do |opts|
        opts[:tag] = "div"
        opts[:classes] = class_names(
          opts[:classes],
          "Polaris-Page",
          "Polaris-Page--narrowWidth": @narrow_width,
          "Polaris-Page--fullWidth": @full_width
        )
      end
    end

    def render_header?
      @title.present? || @subtitle.present? || @back_url.present? || render_primary_action?
    end

    def render_primary_action?
      primary_action.present? || custom_primary_action.present?
    end

    def has_pagination?
      @next_url.present? || @prev_url.present?
    end

    class ActionGroupComponent < Polaris::Component
      attr_reader :title
      attr_reader :actions

      def initialize(title:, actions: [])
        @title = title
        @actions = actions
      end

      def call
        render(Polaris::PopoverComponent.new(position: :below)) do |popover|
          popover.button(disclosure: true) { @title }

          polaris_action_list do |list|
            @actions.each do |action|
              list.item(**action) { action[:content] }
            end
          end
        end
      end
    end
  end
end
