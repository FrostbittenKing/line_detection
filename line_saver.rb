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
        File.open(image_name + LineSaver.extension) do |f|
            f.each do |read_line|
                parsed_line = JSON.parse(read_line)
                # recreate array of CvPoint hashes :start_point points to Pt1, :end_point points to Pt2
                return_data << { :start_point =>  CvPoint.new(parsed_line[:start_point][:x], parsed_line[:start_point][:y]),
                    :end_point => CvPoint.new(parsed_line[:end_point][:x], parsed_line[:end_point][y])}
            end
        end
    end
end
