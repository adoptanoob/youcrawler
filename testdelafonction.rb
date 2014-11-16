blacklisted_videos = []
playlists_titles_queries = []
search_list = []
selected_playlist = []

response = firebase.get("params")

response.body.each do |e|
  if e[0] == "blacklisted_videos"

    e[1]["items"].each do |ee|
    blacklisted_videos << ee[1]["value"]
  end
  
  elsif e[0] == "search_list"

    e[1]["items"].each do |ee|
    search_list << ee[1]["value"]
  end
  
  elsif e[0] == "selected_playlist"

    e[1]["items"].each do |ee|
    selected_playlist << ee[1]["value"]
  end

  elsif e[0] == "selected_themes"

    if e[1]["items"]
      e[1]["items"].each do |ee|
      playlists_titles_queries << ee[1]["value"]
    end
  end
end




Filter = lambda do |array, &block|
 array.select(&block)
end

def populate(array)
  array << self.
end