require 'json'
require 'yaml'
require 'net/http'
require 'rexml/document'
require 'time'

# Sync recent photo albums into _data/photos.yaml, which the homepage reads to
# render the Photographs section.
#
# Source (PHOTOS_JSON) accepts either shape, so one implementation serves both:
#   * local   — the sibling repo's full export (albums each with a `photos` array)
#   * CI       — a compact summary pushed by the photos repo (albums each with `count`)
PHOTOS_JSON = ENV['PHOTOS_JSON'] ||
              File.expand_path('../photos.joneisen.me/src/data/photos.json', __dir__)
OUT         = File.expand_path('_data/photos.yaml', __dir__)
MIN_PHOTOS  = 18   # skip small / one-off albums
MAX_ALBUMS  = 8    # homepage shows the first 4; keep a few spare in the data

# --- Podcast (Running with Problems) ---
# `rake podcast` parses the Buzzsprout RSS into _data/podcast.yaml, which the
# homepage reads to render the Podcast section. Stdlib-only, like `rake photos`.
PODCAST_FEED  = ENV['PODCAST_FEED'] || 'https://rss.buzzsprout.com/2437656.rss'
PODCAST_OUT   = File.expand_path('_data/podcast.yaml', __dir__)
PODCAST_ID    = '2437656'            # numeric segment of the feed URL
PODCAST_SITE  = 'https://www.runningwithproblems.run'
MAX_EPISODES  = 6                    # homepage shows 3; keep a few spare

desc 'Sync recent photo albums into _data/photos.yaml (set PHOTOS_JSON to override the source)'
task :photos do
  unless File.exist?(PHOTOS_JSON)
    abort "Cannot find #{PHOTOS_JSON}\n" \
          "Clone photos.joneisen.me as a sibling directory and run its `npm run build:photos`,\n" \
          "or set PHOTOS_JSON to a summary export."
  end

  data   = JSON.parse(File.read(PHOTOS_JSON))
  albums = (data['albums'] || [])
           .map do |a|
             {
               'id'    => a['id'],
               'name'  => a['name'],
               'count' => a['count'] || (a['photos'] || []).length,
               'cover' => a['cover']
             }
           end
           .select { |a| a['count'] >= MIN_PHOTOS }
           .first(MAX_ALBUMS)

  File.write(OUT, { 'albums' => albums }.to_yaml)
  puts "Wrote #{albums.length} albums to _data/photos.yaml:"
  albums.each_with_index { |a, i| puts format('  %d. %-30s %3d photos', i + 1, a['name'], a['count']) }
end

# Turn an episode title into Buzzsprout's URL slug.
def podcast_slug(title)
  title.downcase.gsub("'", '').gsub(/[^a-z0-9]+/, '-').gsub(/\A-|-\z/, '')
end

# Build the custom-domain episode-page URL from the item's guid + title.
def podcast_episode_link(guid, title)
  id = guid.to_s.sub(/\ABuzzsprout-/, '')
  "#{PODCAST_SITE}/#{PODCAST_ID}/episodes/#{id}-#{podcast_slug(title)}"
end

desc 'Sync recent podcast episodes into _data/podcast.yaml (set PODCAST_FEED to override)'
task :podcast do
  xml  = Net::HTTP.get(URI(PODCAST_FEED))
  doc  = REXML::Document.new(xml)
  chan = doc.elements['rss/channel']

  cover = chan.elements['itunes:image']&.attributes&.[]('href') ||
          chan.elements['image/url']&.text

  # atom:link elements have no text node; detect the plain RSS <link> by text presence
  channel_link = chan.get_elements('link').detect { |el| el.text.to_s.strip != '' }&.text

  episodes = chan.get_elements('item').first(MAX_EPISODES).map do |item|
    title = item.elements['title'].text.to_s.strip
    {
      'title'   => title,
      'season'  => item.elements['itunes:season']&.text&.to_i,
      'episode' => item.elements['itunes:episode']&.text&.to_i,
      'date'    => Time.parse(item.elements['pubDate'].text).strftime('%Y-%m-%d'),
      'minutes' => (item.elements['itunes:duration'].text.to_i / 60.0).round,
      'link'    => podcast_episode_link(item.elements['guid'].text, title)
    }
  end

  data = {
    'title'    => chan.elements['title'].text,
    'tagline'  => chan.elements['description'].text.to_s.gsub(/<[^>]+>/, '').strip,
    'link'     => channel_link,
    'cover'    => cover,
    'episodes' => episodes
  }

  File.write(PODCAST_OUT, data.to_yaml)
  puts "Wrote #{episodes.length} episodes to _data/podcast.yaml:"
  episodes.each_with_index do |e, i|
    puts format('  %d. S%s·E%-2s %s', i + 1, e['season'], e['episode'], e['title'])
  end
end
