#Hough transformation module can use the standard and probabilistic algorithm
module HoughTransform
    require 'json'

    @lines_array = []

    def hough_transform(algorithm, rho, theta, threshold, *args, image )
        @lines_array = []
        color_image = image.GRAY2BGR
        if (algorithm == CV_HOUGH_PROBABILISTIC)
            min_line_length,max_line_gap = *args
            lines_output = image.hough_lines algorithm, rho, theta, threshold, min_line_length, max_line_gap

            lines_output.each_with_index { |current_line,index| color_image.line! current_line[0],current_line[1],
                :thickness => 2, :line_type => 8, :color => CvScalar.new(0,0,255)
               # print "draw line nr: #{index + 1}\n"
            }
        elsif (algorithm == CV_HOUGH_STANDARD)
            lines_output = image.hough_lines algorithm, rho, theta, threshold
            lines_output.each_with_index { |current_line,index|
                current_rho = current_line[0]
                current_theta = current_line[1]
                a = Math.cos(current_theta)
                b = Math.sin(current_theta)
                x0 = a*current_rho
                y0 = b*current_rho
                pt1 = CvPoint.new((x0 + 2000*(-b)).round, (y0 + 2000*(a)).round)
                pt2 = CvPoint.new((x0 - 2000*(-b)).round, (y0 - 2000*(a)).round)

                # store points

                @lines_array << { :start_point => pt1, :end_point => pt2 }

                color_image.line! pt1, pt2, :thickness => 2, :line_type => 8, :color => CvScalar.new(0,0,255)
             #   print "draw line nr: #{index + 1}\n"
            }
        end

        return color_image
    end
end
