require 'nokogiri'
require 'open-uri'
require 'firebase'

##########################COPIE COLLE FIREBASE###################
# base_uri =  To configure

firebase = Firebase::Client.new(base_uri)


blacklisted_videos = []
playlists_titles_queries = ""
search_list = []
selected_playlist = []

response = firebase.get("params")

response.body.each do |e|
  if e[0] == "blacklisted_videos"

  e[1]["items"].each do |ee|
   blacklisted_videos << ee[1]["value"]
  end
  elsif e[0] == "selected_themes"
    playlists_titles_queries = e[1]["value"]
  elsif e[0] == "search_list"

    e[1]["items"].each do |ee|
    search_list << ee[1]["value"]
  end
  elsif e[0] == "selected_playlist"

    e[1]["items"].each do |ee|
    selected_playlist << ee[1]["value"]
  end
end
puts e
  p '---------------------'

p 'displaying playlists_titles_queries'
puts playlists_titles_queries

p 'displaying blacklisted_videos'
puts blacklisted_videos 

p 'displaying search_list'
puts search_list

p 'displaying selected_playlist'
puts selected_playlist
end




############FIN#######################


playlists_urls = []

playlists_titles_regexp = Regexp.new(playlists_titles_queries) 
search_list.each do |search_term|

  #list_url = "http://www.youtube.com/watch?v=m10xcPcuBeg"
  list_url = "https://www.youtube.com/user/#{search_term}/playlists"

  page = Nokogiri::HTML(open (list_url))

  p '-------------------------------------------------------------------------'
  p "finding videos for #{search_term}"
  div_elements = page.css('h3.yt-lockup-title a')

  div_elements.each do |d|
    watch_code = d.attributes['href'].value
    playlist_name = d.attributes['title'].value
    booleen_query_regexp = !playlist_name.match(playlists_titles_regexp).nil? && !playlists_titles_queries.empty?
    playlists_urls << "http://www.youtube.com" + watch_code if watch_code.include?('playlist?') && selected_playlist.include?(playlist_name) || booleen_query_regexp
   end

end

p 'the links are'
p playlists_urls
p 'total videos found'
p playlists_urls.count


system("touch video/downloaded_video.txt")

blacklisted_videos.each do |blacklisted_video|

  system("echo youtube #{blacklisted_video} >> video/downloaded_video.txt")
end


p '---------------download start -----------------------------------------------'

playlists_urls.each do |link_to_video|

  system("youtube-dl --download-archive video/downloaded_video.txt -o 'video/%(uploader)s/%(playlist)s/%(playlist_index)s-%(title)s.flv' #{link_to_video}")
end

p '---------------download completed-------------------------------------------'
p '---------------Now wiping the download archive------------------------------'
system("rm -rf video/downloaded_video.txt")
p '--------------Archive successfully wiped------------------------------------'

