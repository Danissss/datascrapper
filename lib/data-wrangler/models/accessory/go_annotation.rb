# -*- coding: utf-8 -*- 
 module DataWrangler
  module Model
    class GoAnnotation
      attr_accessor :go_id, :type, :description

      def initialize(id,type,description)
        @go_id = id
        @type = type
        @description = description
      end

      def eql?(go_annotation)
        self.go_id == go_annotation.go_id
      end

      def ==(go_annotation)
        self.eql?(go_annotation)
      end
    end
  end
end
