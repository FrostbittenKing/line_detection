module UI

    MIN_CANNY_TRACKBAR_NAME = "min canny threshold"
    MAX_CANNY_TRACKBAR_NAME = "max canny threshold"
    MIN_HL_VOTES = "min hl votes"
    MIN_LENGTH = "min length line"

    class VisualizerHelper

        def self.draw_lines(imageMat, linedata, color = CvScalar.new(0,0,255))
            linedata.each { |line| imageMat.line! line[:start_point], line[:end_point], :thickness => 2, :line_type => 8, :color => color
            }
            return imageMat
        end

        def self.find_horizon(linedata)
            linedata.each do |line|
                start_point = line[:start_point]
                end_point = line[:end_point]

                x_distance = (start_point.x - end_point.x).abs
                y_distance = (start_point.y - end_point.y).abs

                angle = y_distance.to_f != 0 ? Math.atan(x_distance.to_f/y_distance.to_f) * 180 / Math::PI : 0

                if (angle >= 0 && angle <= 2)
                    return line
                end
            end
        end

        def self.mark_horizon(imageMat, linedata)
            if (horizon = find_horizon(linedata))

                return draw_lines imageMat, [horizon], CvScalar.new(255,255,0)
            end
        end

    end

    class ImageModeLines
        require 'find'
        require 'line_saver'
        include HoughTransform

        attr_accessor :image, :window_name, :window, :algorithm, :canny_threshold1,
        :canny_threshold2, :bw_image, :canny_image, :hl_votes, :min_length, :image_file_name,
        :horizon_picture,
        :img_file_name #this is a little stupid, this is the variable for the lines
        # @args:
        # window_name: name of the displayed opencv window
        # @type OpenCV::CvMat image: image to display
        def initialize(window_name, image_file_name,mode = :detector_mode)
            @window_name = window_name
            @window = GUI::Window.new(@window_name)
            @image_file_name = image_file_name

            if(mode == :detector_mode)
                detector_mode_init image_file_name
            else
                restore_mode_init image_file_name
            end
        end

        def restore_mode_init(lines_file_name)
            lines_data = LineSaver.instance.restore_lines(lines_file_name)
            self.img_file_name = lines_file_name.slice(/.*\.jpg/)

            complete_image_path = ""
            Find.find('./') do |path|
                if path =~ Regexp.new(img_file_name + "$")
                    complete_image_path = path
                end
            end

            @image = CvMat::load complete_image_path, CV_LOAD_IMAGE_COLOR
            drawn_lines = VisualizerHelper.draw_lines(@image,lines_data)
            VisualizerHelper.find_horizon(lines_data)
            #drawn_lines = image_push_lines(@image, lines_data)

            self.horizon_picture = VisualizerHelper.mark_horizon(@image,lines_data)
            #if not nil, horizon was found
            if (horizon_picture)
                @window.show horizon_picture
            else
                #show without horizon
                @window.show drawn_lines
            end
            #TODO:
            # read original image(find recursively, since we don't extract the exact path from the file)
            # paint lines in original image
            # show image
        end

        def save_horizon_image
            output_name = File.basename(img_file_name,File.extname(img_file_name)) + "_horizon" + File.extname(img_file_name)
            if horizon_picture
                horizon_picture.save(output_name)
            else
                draw_lines.save(output_name)
            end
        end

        def detector_mode_init(image_file_name)
            @image = CvMat::load image_file_name, CV_LOAD_IMAGE_COLOR
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
        end

        def output_canny_image_detection_mode
            canny_image.save(File.basename(image_file_name, File.extname(image_file_name)) + Time.now.to_s + File.extname(image_file_name))
        end

        def save_image_detection_mode
            p image_file_name
            LineSaver.instance.store_lines(File.basename(image_file_name), @lines_array)
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
                   # self.canny_image =
                    #make canny
                    self.canny_image = bw_image.canny(canny_threshold1,canny_threshold2)
                    #detect lines with hough transform
                    hough_transform @hough_mode, 1, CV_PI/180, hl_votes, canny_image
                    #make colorful
                    self.canny_image = self.canny_image.GRAY2BGR
                    #draw lines in image
                    self.canny_image = VisualizerHelper.draw_lines canny_image, @lines_array
                    #color_image.line! pt1, pt2, :thickness => 2, :line_type => 8, :color => CvScalar.new(0,0,255)
                else
                    self.canny_image = hough_transform @hough_mode, 1, CV_PI/180, hl_votes ,min_length ,10, bw_image.canny(canny_threshold1, canny_threshold2)
                end
                window.show canny_image
 #               LineSaver.instance.store_lines("foo", @lines_array)
            }
        end

        def probabilistic_trackbar_action

            proc { |v|
                min_length = v
                self.canny_image = hough_transform CV_HOUGH_PROBABILISTIC, 1, CV_PI/180, hl_votes, min_length, 10, bw_image.canny(canny_threshold1, canny_threshold2)
                window.show canny_image
            }
        end

        private :min_trackbar_action, :max_trackbar_action, :hough_trackbar_action, :probabilistic_trackbar_action
    end

    class ImageModeCircles < ImageModeLines
        require 'bulls_eye'

        def show_bullseye_vector
            BullsEye.instance.bulls_eye_by_lines canny_image, @lines_array
        end

        def show_bullseye_circles

            circles = BullsEye.instance.find_bulls_eye_circle image
            circles.each { |circle|
                self.image.circle! circle.center, circle.radius, :color => CvColor::Blue, :thickness => 3}
            window.show image
        end
    end

end
