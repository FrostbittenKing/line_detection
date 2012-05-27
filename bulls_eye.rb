class BullsEye
    require 'singleton'
    include Singleton

    def bulls_eye_by_lines(image, lines)
        l2start = 1
        l2pos = 1
        lines.each_with_index do |l1,index|
            l2pos = l2start
            for l2pos in l2start..lines.size - 1
                print "#{index} #{l2pos} \n"
                if (intersection = intersectSegments(l1[:start_point], l1[:end_point], lines[l2pos][:start_point], lines[l2pos][:end_point]))
                   # p intersection
                end
            end
            l2start +=1
        end
    end

    def find_bulls_eye_circle(image)
        gray = image.BGR2GRAY
        result = image.clone
        p "find bullseye"
        return gray.hough_circles(CV_HOUGH_GRADIENT, 1.0, 90, 400,200)
    end

    def intersectSegments(p1,p2,p3,p4)
        x1,y1 = *p1
        x2,y2 = *p2
        x3,y3 = *p3
        x4,y4 = *p4

        return nil if ((d = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1)) == 0 )
        ua = ((x4 - x3) * (y1 - y3) - (y4 - y3)* (x1 - x3)) / d
        ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1-x3)) / d

        return nil if (ua < 0 || ua > 1 || ub < 0 || ub > 1)

        p CvPoint.new(x3 + (x4 - x3)*ua, y1 + (y2 -y1)*ua)
    end
end
