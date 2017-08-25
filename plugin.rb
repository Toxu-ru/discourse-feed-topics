# name: discourse-feed_topics
# about: Adds feed to topics
# version: 0.1
# author: Joe Buhlig -> Evg 
# url: https://github.com/Toxu-ru/discourse-feed-topics

enabled_site_setting :feed_topics_enabled

Discourse.top_menu_items.push(:feed)
Discourse.anonymous_top_menu_items.push(:feed)
Discourse.filters.push(:feed)
Discourse.anonymous_filters.push(:feed)

after_initialize do
    if SiteSetting.feed_topics_enabled



		require_dependency 'topic_query'
		class ::TopicQuery
			SORTABLE_MAPPING["feed"] = "custom_fields.upvote_feed"

		  def list_feed
		  	topics = create_list(:feed, {order: "feed"})
		  end

		end

	
    TopicList.preloaded_custom_fields << "upvote_feed" if TopicList.respond_to? :preloaded_custom_fields

	end
	
end
