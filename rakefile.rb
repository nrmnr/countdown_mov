#!/usr/bin/env ruby
# coding: utf-8

# Create count down timer movie
# using ImageMagick, ffmpeg

$size = '960x720'
$font = 'Tahoma'
$fontsize = 256
$sec_max = 120

directory '1_png'
directory '2_mov'
directory '3_counter'

task :png => '1_png' do
  (0..$sec_max).each do |sec|
    m = sec / 60
    s = sec % 60
    countstr = "%02d:%02d" % [m, s]
    filename = File.join '1_png', ("%04d.png" % sec)
    rm filename if File.exist? filename
    sh "convert -size #{$size} -gravity center -font #{$font} -fill black -background white -pointsize #{$fontsize} label:\"#{countstr}\" #{filename}"
  end
end

task :mov => '2_mov' do
  (0..$sec_max).each do |sec|
    base = '%04d' % sec
    src = File.join '1_png', "#{base}.png"
    dest = File.join '2_mov', "#{base}.mp4"
    sh "ffmpeg -r 1 -i #{src} #{dest}"
  end
end

[1,2].each do |minutes|
  base = 'm%02d' % minutes
  txt = File.join '2_mov', "#{base}.txt"
  dest = File.join '2_mov', "#{base}.mp4"
  file dest do
    sec = minutes * 60
    movs = (0..sec).to_a.reverse.map { |s|
      path = '%04d.mp4' % s
      "file #{path}"
    }
    open(txt, 'w') do |f|
      f.puts movs
    end
    sh "ffmpeg -f concat -i #{txt} -c copy #{dest}"
  end
  desc "create counter mov #{minutes} minutes"
  task base => dest
end
