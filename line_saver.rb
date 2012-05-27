class LineSaver
    require 'singleton'
    include Singleton

    @@extension = ".lines"

    def self.extension
        @@extension
    end

    def store_lines(image_name, lines)
        lines_file = File.new(image_name + LineSaver.extension, "w")
        lines.each { |line|
            lines_file.puts ({ :start_point =>
                { :x => line[:start_point].x, :y => line[:start_point].y},
                :end_point =>
                { :x => line[:end_point].x, :y => line[:end_point].y}
            }.to_json + "\n")
        }
        lines_file.close
    end

    # restore lines data from file
    # returns array of CvPoint hashes containing a start and end_point
    def restore_lines(image_name)
        return_data = []
        File.open("./" + image_name) do |f|
            f.each do |read_line|
                JSON.parse(read_line)
                parsed_line = JSON.parse(read_line)
                # recreate array of CvPoint hashes :start_point points to Pt1, :end_point points to Pt2
                return_data << ({ :start_point =>  CvPoint.new(parsed_line[:start_point.to_s][:x.to_s], parsed_line[:start_point.to_s][:y.to_s]),
                     :end_point => CvPoint.new(parsed_line[:end_point.to_s][:x.to_s], parsed_line[:end_point.to_s][:y.to_s])})
            end
        end
        return_data
    end
end
