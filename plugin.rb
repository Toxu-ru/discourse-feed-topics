# name: discourse-feed_topics
# about: Adds feed to topics
# version: 0.1
# author: Joe Buhlig -> Evg toxu.ru
# url: https://github.com/Toxu-ru/discourse-feed-topics

enabled_site_setting :feed_topics_enabled

Discourse.top_menu_items.push(:feed)
Discourse.anonymous_top_menu_items.push(:feed)
Discourse.filters.push(:feed)
Discourse.anonymous_filters.push(:feed)

after_initialize do
	if SiteSetting.feed_topics_enabled

		require_dependency 'topic'
	    class ::Topic

			def feed_time
				((Time.now - self.created_at) / 1.hour)
			end

			def feed_rating_custom
				self.custom_fields['upvote_feed']
			end

	    end

		require_dependency 'topic_view_serializer'
		class ::TopicViewSerializer
			attributes :feed_time

			def feed_time
				object.topic.feed_time
			end

			def feed_rating_custom
				object.topic.custom_fields['upvote_feed']
			end

		end

		add_to_serializer(:topic_list_item, :feed_time) { object.feed_time }
		add_to_serializer(:topic_list_item, :feed_rating_custom) { object.feed_rating_custom }

		require_dependency 'topic_query'
		class ::TopicQuery
			SORTABLE_MAPPING["feed"] = "custom_fields.upvote_feed"

		  def list_feed
		  	topics = create_list(:feed, {order: "feed"})
		  end

		end

		module ::Jobs

      class HotRating < Jobs::Scheduled
        def execute(args)
          Topic.where(closed: false, archetype: 'regular').find_each do |topic|
            topic.custom_fields['upvote_feed'] = (topic.feed_time * 1).to_i
            topic.save
          end
        end
      end

    end

    TopicList.preloaded_custom_fields << "upvote_feed" if TopicList.respond_to? :preloaded_custom_fields

	end
	
end
