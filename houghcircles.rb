#!/usr/bin/ruby

$LOAD_PATH.unshift File.dirname(__FILE__)

CV_PI = 3.1415926535897932384626433832795

require "opencv"
require 'rubygems'
require 'filemagic'
require 'hough_transform'
require 'ui'
include OpenCV

def usage
    print "ruby houghcircles.rb <image file name> \n"
    print "p: show bullseye by line intersection\n"
    print "b: show bullseye by circle center\n"
    print "s: save image after showing bullseye by intersection and circlecenter\n"
    exit 0
end

if (ARGV.size != 1)
    usage
end

if File.exists?(ARGV[0])
    #detect file type
    fm = FileMagic.new
    type = fm.file(ARGV[0])
    if (type.start_with?("JPEG") || type.start_with?("PNG"))
#        image = CvMat::load ARGV[0],CV_LOAD_IMAGE_COLOR

        #instantiate viewer/save mode
        window = UI::ImageModeCircles.new("viewer output", ARGV[0])

        while key = GUI::wait_key
            case key.chr
            when "p"
                window.show_bullseye_vector

            when "b"
                window.show_bullseye_circles

            when "s"
                window.save_bullseye_circles
            end
        end
    end
else
     print "File or directory not found\n"
    exit 0
end
