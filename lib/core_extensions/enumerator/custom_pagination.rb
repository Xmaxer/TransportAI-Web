module CoreExtensions
  module Enumerator
    module CustomPagination
      def paginate(data, options = {})
        Rails.logger.debug(data.count)
        page = if options[:page].nil? then 1 else options[:page] end
          per_page = if options[:per_page].nil? then 10 else options[:per_page] end
            hash = {}
            data_to_skip = (page.to_i - 1) * per_page.to_i
            enum = data.each

            # while data_to_skip > 0 do
            #   begin
            #     enum.next
            #     data_to_skip = data_to_skip - 1
            #   rescue
            #   end
            # end
            enum.each do |d|
              if data_to_skip > 0
                data_to_skip = data_to_skip - 1
                next
              end
              break if per_page == 0
              hash[d.document_id] = d.data
              per_page = per_page - 1
            end
            return hash
          end
        end
      end
    end
