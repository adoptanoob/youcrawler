require 'nokogiri'
require 'open-uri'
require 'firebase'
##########################COPIE COLLE FIREBASE###################

#base_uri = PASTE Firebase URL (.com/)
firebase = Firebase::Client.new(base_uri)


blacklisted_videos = []
playlists_titles_queries = []
search_list = []
selected_playlist = []

response = firebase.get("youcrawler/params")
response_content = response.body

def filter(array, block)
  array.each(&block)
end


my_first_big_block = lambda do |e|
  if e[0] == "blacklisted_videos" &&  e[1]["items"]

    e[1]["items"].each do |ee|
    blacklisted_videos << ee[1]["value"]
  end
  
  elsif e[0] == "search_list" &&  e[1]["items"]

    e[1]["items"].each do |ee|
    search_list << ee[1]["value"]
  end
  
  elsif e[0] == "selected_playlist" && e[1]["items"]

    e[1]["items"].each do |ee|
    selected_playlist << ee[1]["value"]
  end

  elsif e[0] == "selected_themes" &&  e[1]["items"]

    
      e[1]["items"].each do |ee|
      playlists_titles_queries << ee[1]["value"]
      end
  end
end

#Call our method to set the content of our arrays
filter(response_content, my_first_big_block)


#declaring the variable which will hold the links of all the videos we want to download
videos_urls = []

#takes every element of the array playlists_titles_queries, 
#duplicate it and return a new array of all the duplicated elements 
#transformed into regex which we will then loop over to establish a match in order to implement 
#the functionality of searching the videos in playlists mentioning the search query in their titles
playlists_titles_regexp = playlists_titles_queries.dup.map! {|query| Regexp.new(query)}


search_list.each do |search_term|

  # liste tous les liens de playlists qui correspondent à l'utilisateur youtube entré
  list_url = "https://www.youtube.com/user/#{search_term}/playlists"

  page = Nokogiri::HTML(open (list_url))

  p '-------------------------------------------------------------------------'
  p "finding videos for #{search_term}"
  #storing all links of the page which have the css selector corresponding to a video
  div_elements = page.css('h3.yt-lockup-title a')

  #initializing a boolean variable used to store the result of boolean operation useful in the following block   
  booleen_query_regexp = false

  div_elements.each do |d|
    watch_code = d.attributes['href'].value
    playlist_name = d.attributes['title'].value
    #here we construct a boolean which will trigger the append in videos_urls of all the playlists whose names match the user's input
    playlists_titles_regexp.each do |playlist_title_regexp|
      
      booleen_query_regexp = playlists_titles_queries if booleen_query_regexp || !playlist_name.match(playlist_title_regexp).nil? && !playlists_titles_queries.empty?
    end
    #here we create an array (list) of all the videos' URLs we want to download
    videos_urls << "http://www.youtube.com" + watch_code if watch_code.include?('playlist?') && selected_playlist.include?(playlist_name) || booleen_query_regexp
   end

end

p 'the links are'
p videos_urls
p 'total videos found'
p videos_urls.count


system("touch video/downloaded_video.txt")

#Here we implement a way to blacklist videos via the edition of the file video/downloaded_video.txt
blacklisted_videos.each do |blacklisted_video|

  system("echo youtube #{blacklisted_video} >> video/downloaded_video.txt")
end


p '---------------download start -----------------------------------------------'

videos_urls.each do |link_to_video|

  system("youtube-dl --download-archive video/downloaded_video.txt -o 'video/%(uploader)s/%(playlist)s/%(playlist_index)s-%(title)s.flv' #{link_to_video}")
end

p '---------------download completed-------------------------------------------'
p '---------------Now wiping the download archive------------------------------'
#Here we delete the file which contain our blacklist of videos
system("rm -rf video/downloaded_video.txt")
p '--------------Archive successfully wiped------------------------------------'



