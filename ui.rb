module UI

    MIN_CANNY_TRACKBAR_NAME = "min canny threshold"
    MAX_CANNY_TRACKBAR_NAME = "max canny threshold"
    MIN_HL_VOTES = "min hl votes"
    MIN_LENGTH = "min length line"
    class ImageModeLines
        require 'line_saver'
        include HoughTransform

        attr_accessor :image, :window_name, :window, :algorithm, :canny_threshold1,
        :canny_threshold2, :bw_image, :canny_image, :hl_votes, :min_length, :image_file_name
        # @args:
        # window_name: name of the displayed opencv window
        # @type OpenCV::CvMat image: image to display
        def initialize(window_name, image_file_name,mode)
            @window_name = window_name
            @image = CvMat::load image_file_name, CV_LOAD_IMAGE_COLOR
            @image_file_name
            @window = GUI::Window.new(@window_name)
            @bw_image = @image.BGR2GRAY
           # GUI::wait_key
            #initialize variables
            @canny_threshold1 = 170
            @canny_threshold2 = 300

            #init min threshold trackbar
            @window.set_trackbar(MIN_CANNY_TRACKBAR_NAME, 1000,1000,&min_trackbar_action)
            #init max threshold trackbar
            @window.set_trackbar(MAX_CANNY_TRACKBAR_NAME, 1000,1000,&max_trackbar_action)
            @canny_image = @bw_image.canny 170,300

            # SET HOUGH ALGORITHM
            @hough_mode = CV_HOUGH_STANDARD

            window.set_trackbar(MIN_HL_VOTES, 800, hl_votes, &hough_trackbar_action)

            #probabilistic
            if @hough_mode == CV_HOUGH_PROBABILISTIC
                @min_length = 300
                window.set_trackbar(MIN_LENGTH_LINE, 900 ,min_length, &probabilistic_trackbar_action)
            end

            window.show @canny_image


            while key = GUI::wait_key
                case key.chr
                when "s"
                    LineSaver.instance.store_lines(File.basename(image_file_name, File.extname(image_file_name)), @lines_array)
                when "o"
                    @canny_image.save(File.basename(image_file_name, File.extname(image_file_name)) + Time.now.to_s + File.extname(image_file_name))
                end
            end
        end

        def max_trackbar_action
            proc { |v|
                self.canny_threshold2 = v
                window.show bw_image.canny(canny_threshold1, v.to_f)
#                print "threshold1: #{canny_threshold1}\n"
#                print "threshold2: #{canny_threshold2}\n"
            }
        end

        def min_trackbar_action
            proc { |v|
                self.canny_threshold1 = v
                window.show bw_image.canny(v.to_f, canny_threshold2)
#                print "threshold1: #{canny_threshold1}\n"
#                print "threshold2: #{canny_threshold2}\n"
            }
        end

        def hough_trackbar_action
            #
            proc { |v|
                self.hl_votes = v
                if @hough_mode == CV_HOUGH_STANDARD
                    canny_edges = hough_transform @hough_mode, 1, CV_PI/180, hl_votes, bw_image.canny(canny_threshold1, canny_threshold2)
                else
                    canny_edges = hough_transform @hough_mode, 1, CV_PI/180, hl_votes ,min_length ,10, bw_image.canny(canny_threshold1, canny_threshold2)
                end
                window.show canny_edges
 #               LineSaver.instance.store_lines("foo", @lines_array)
            }
        end

        def probabilistic_trackbar_action

            proc { |v|
                min_length = v
                canny_edges = hough_transform CV_HOUGH_PROBABILISTIC, 1, CV_PI/180, hl_votes, min_length, 10, bw_image.canny(canny_threshold1, canny_threshold2)
                window.show canny_edges
            }
        end

        private :min_trackbar_action, :max_trackbar_action, :hough_trackbar_action, :probabilistic_trackbar_action
    end
end
