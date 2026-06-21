require 'json'
require 'yaml'

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
