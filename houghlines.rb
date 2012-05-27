$LOAD_PATH.unshift File.dirname(__FILE__)

require "opencv"
require 'rubygems'
require 'filemagic'
require 'hough_transform'
require 'ui'
include OpenCV

CV_PI = 3.1415926535897932384626433832795

def usage
    print "ruby houghlines.rb <image file name | stored lines file> <hough algorithm: [0 = standard | 1 = probabilistic] >\n"
    print "If jpg loaded available buttons:\n"
    print "s: store found lines in file\n"
    print "o: to save image with lines\n"

    print "If lines file loaded:\n"
    print "s: store image with marked lines and marked horizon if horizon can be found\n"
    exit 0
end
if (ARGV.size != 2)
    usage
end




canny_threshold1 = 1000
canny_threshold2 = 1000
hl_votes = 100
min_length = 100
max_line_gap = 10


#load file
if File.exists?(ARGV[0])
    #detect file type
    fm = FileMagic.new
    type = fm.file(ARGV[0])
    if (type.start_with?("JPEG") || type.start_with?("PNG"))
#        image = CvMat::load ARGV[0],CV_LOAD_IMAGE_COLOR

        #instantiate viewer/save mode
        window = UI::ImageModeLines.new("viewer output", ARGV[0])
    else
        #todo assume text file
        UI::ImageModeLines.new("viewer output", ARGV[0], :restore_mode)
    end
else
     print "File or directory not found\n"
    exit 0
end
