# frozen_string_literal: true

module Util
  # generate a relationship diagram for the tables in the database
  # this process uses the graphivz package
  class DbImageGenerator
    def schema_image(filename)
      graph = <<-DOT_CODE
        digraph {
          graph [layout=twopi, splines=true, overlap=false];
          node [shape=plain]
          #{generate_nodes}
          #{generate_edges}
        }
      DOT_CODE

      File.write('tmp/schema.dot', graph)
      `dot -Tpng tmp/schema.dot -o #{filename}`
    end

    def generate_edges
      study_edges = StudyRelationship.study_models.map { |k| "#{k.name.tableize.pluralize}" }.join("\n")
      extra_edges = Util::DbManager.foreign_key_constraints.map do |k|
        "#{k[:child_table].tableize.pluralize} -> #{k[:parent_table].tableize.pluralize}"
      end.join("\n")
      "#{study_edges}\n#{extra_edges}"
    end

    def generate_nodes
      StudyRelationship.study_models.map { |k| table(k) }.join("\n\n")
    end

    # generate graphiz code for a model
    def table(model)
      attributes = model.columns_hash.map { |k, v| "<tr><td>#{k}</td><td>#{v.type}</td></tr>" }.join("\n")
      <<-DOT_CODE
        #{model.name.tableize.pluralize} [label=<
        <table border="0" cellborder="1" cellspacing="0">
          <tr><td colspan="2"><b>#{model.name.tableize.pluralize}</b></td></tr>
          #{attributes}
        </table>>];
      DOT_CODE
    end
  end
end
