# frozen_string_literal: true

module Util
  class Compare
		# 1. get all the loadable tables
		# 2. get all the columns from the loadable tables
		# 3. generate the query
		# 4. run the query on each table
		# 5. export csv files per query
		def run(tables=Util::DbManager.loadable_tables)
			stats = []
			`rm -rf public/static/comparisons`
			tables = tables - ['result_agreements']
			tables.each do |table_name|
				ActiveRecord::Base.logger = nil
				stime = Time.now
				print "#{table_name}: "
				begin
					diff_count = compare(table_name)
				rescue NameError
					print "not found\n"
					stats << [
						table_name,
						'NA',
						'NA',
						'NA',
						'no rails model'
					]
					next
				end
      	time = Time.now - stime
				print "#{diff_count} differences time: #{htime(time)}\n"
				stats << [
					table_name, 
					row_count(table_name), 
					row_count(table_name, 'ctgov_beta'),
					diff_count
				]
			end

			dir = 'public/static/comparisons'
			FileUtils.mkdir_p(dir)
      file = File.open("#{dir}/stats.csv", 'w')
			file << CSV.generate_line(['table','row count', 'beta row count', 'differences','message'])
			stats.each do |stat|
				file << CSV.generate_line(stat)
			end
			file.close
		end

		def row_count(table_name, schema='ctgov')
			result = execute("SELECT COUNT(*) FROM #{schema}.#{table_name}")
			return result.first['count']
		end

		def compare(table_name)
			dir = 'public/static/comparisons'
			sql = comparison_sql(table_name)
			rows = execute(sql)
			return 0 if rows.count == 0

			FileUtils.mkdir_p(dir)
      file = File.open("#{dir}/#{table_name}.csv", 'w')
			headers = rows.first.keys
			file << CSV.generate_line(headers)
			rows.each do |row|
				file << CSV.generate_line(headers.map{|k| row[k] })
			end
			file.close

			return rows.count
		end

		def design_group_interventions_sql
			"SELECT
			* 
			FROM
			(SELECT DGI.nct_id,DG.title
			FROM ctgov.design_group_interventions DGI
			JOIN ctgov.design_groups DG ON DGI.design_group_id = DG.id
			JOIN ctgov.interventions I ON DGI.intervention_id = I.id) AS A
			LEFT JOIN (
			SELECT DGI.nct_id, DG.title
			FROM ctgov_beta.design_group_interventions DGI
			JOIN ctgov_beta.design_groups DG ON DGI.design_group_id = DG.id
			JOIN ctgov_beta.interventions I ON DGI.intervention_id = I.id ) AS B
			ON A.nct_id = B.nct_id AND A.title = B.title
			WHERE B.nct_id IS NULL"
		end

		def intervention_other_names_sql
			"SELECT
			* 
			FROM
			(SELECT DGI.nct_id, DGI.name, I.name AS intervention_name
			FROM ctgov.intervention_other_names DGI
			JOIN ctgov.interventions I ON DGI.intervention_id = I.id) AS A
			LEFT JOIN (
			SELECT DGI.nct_id, DGI.name, I.name AS intervention_name
			FROM ctgov_beta.intervention_other_names DGI
			JOIN ctgov_beta.interventions I ON DGI.intervention_id = I.id ) AS B
			ON A.nct_id = B.nct_id AND A.name = B.name AND A.intervention_name = B.intervention_name
			WHERE B.nct_id IS NULL"
		end

		def comparison_sql(table_name)
			return design_group_interventions_sql if table_name == 'design_group_interventions'
			return intervention_other_names_sql if table_name == 'intervention_other_names'

			model = table_name.singularize.camelcase.constantize
			columns = model.columns_hash
			columns.delete("id")
			columns.delete("updated_at")
			columns.delete("created_at")
			columns.delete('nlm_download_date_description')
			columns.delete('nlm_download_date')
			columns.delete('ctgov_group_code')

			columns.delete('facility_id') if table_name == 'facility_contacts'

			# things to look at later
			columns.delete('agency_class')
			columns.delete('result_group_id')
			columns.delete('outcome_id')

			# reported events has a lot of columns that don't match these are the ones that currently match
			if table_name == 'reported_events'
				to_delete = columns.keys - ['nct_id', 'time_frame', 'event_type', 'subjects_affected', 'subjects_at_risk']
				to_delete.each do |key|
					columns.delete(key)
				end
			end

			# titles changed
			# i.e. before: "Age" now: "Age, Continuous"
			if table_name == 'baseline_measurements'
				columns.delete('title')
			end


			columns = columns.values
			sql = "SELECT\n"

			# add columns to output
			sql += columns.map do |col|
				"NF.#{col.name}, BF.#{col.name} AS beta_#{col.name}"
				# col.type == :string ? "NF.#{col.name} = COALESCE(BF.#{col.name},'')" : "NF.#{col.name} = BF.#{col.name}"
			end.join(",\n") + "\n"

			sql += "FROM ctgov.#{table_name} NF LEFT JOIN ctgov_beta.#{table_name} BF ON\n"

			# add columns to join
			sql += columns.map do |col|
				# "NF.#{column} = BF.#{column}"
				if col.name == 'mesh_type'
					"COALESCE(NF.#{col.name},'mesh-list') = BF.#{col.name}"
				elsif col.name == 'scope' && table_name == 'baseline_counts'
					"LOWER(NF.scope) = BF.scope"
					"(#{comp} OR (NF.#{col.name} IS NULL AND BF.#{col.name} IS NULL))"	
				elsif col.name == 'removed' 
					"COALESCE(NF.#{col.name},false) = BF.#{col.name}"
				elsif col.type == :text && table_name == 'eligibilities'
					comp = "REGEXP_REPLACE(COALESCE(NF.#{col.name},''),'[^a-z]','','gi') = REGEXP_REPLACE(COALESCE(BF.#{col.name},''),'[^a-z]','','gi')"
					"(#{comp} OR (NF.#{col.name} IS NULL AND BF.#{col.name} IS NULL))"
				elsif col.type == :text && table_name == 'detailed_descriptions'
					comp = "REGEXP_REPLACE(COALESCE(NF.#{col.name},''),'[^a-z]','','gi') = REGEXP_REPLACE(COALESCE(BF.#{col.name},''),'[^a-z]','','gi')"
					"(#{comp} OR (NF.#{col.name} IS NULL AND BF.#{col.name} IS NULL))"
				elsif col.type == :text && table_name == 'brief_summaries'
					comp = "REGEXP_REPLACE(COALESCE(NF.#{col.name},''),'[^a-z]','','gi') = REGEXP_REPLACE(COALESCE(BF.#{col.name},''),'[^a-z]','','gi')"
					"(#{comp} OR (NF.#{col.name} IS NULL AND BF.#{col.name} IS NULL))"
				elsif col.name == 'phase' && table_name == 'studies'
					comp = "COALESCE(NF.#{col.name},'') = REGEXP_REPLACE(COALESCE(BF.#{col.name},''), 'Not Applicable','N/A','g')"
					"(#{comp} OR (NF.#{col.name} IS NULL AND BF.#{col.name} IS NULL))"
				elsif col.name == 'reference_type' && table_name == 'study_references'
					comp = "COALESCE(NF.#{col.name},'') = REGEXP_REPLACE(REGEXP_REPLACE(COALESCE(BF.#{col.name},''), 'result','results_reference','g'), 'background', 'reference','g')"
					"(#{comp} OR (NF.#{col.name} IS NULL AND BF.#{col.name} IS NULL))"
				elsif col.type == :string
					"COALESCE(NF.#{col.name},'') = COALESCE(BF.#{col.name},'')"
				elsif col.type == :text
					# comp = "TRIM(BOTH FROM REGEXP_REPLACE(COALESCE(NF.#{col.name},''), '\\s+',' ','g')) = TRIM(BOTH FROM REGEXP_REPLACE(COALESCE(BF.#{col.name},''), '\\s+',' ','g'))"
					comp = "REGEXP_REPLACE(COALESCE(NF.#{col.name},''),'[^a-z]','','gi') = REGEXP_REPLACE(COALESCE(BF.#{col.name},''),'[^a-z]','','gi')"
					"(#{comp} OR (NF.#{col.name} IS NULL AND BF.#{col.name} IS NULL))"
				else
					comp = "NF.#{col.name} = BF.#{col.name}"
					"(#{comp} OR (NF.#{col.name} IS NULL AND BF.#{col.name} IS NULL))"
				end
			end.join(" AND\n") + "\n"

			sql += "WHERE BF.nct_id IS NULL LIMIT 100000"

			return sql
		end


		def execute(sql)
			Study.connection.execute(sql)
		end

		def htime(seconds)
      seconds = seconds.to_i
      hours = seconds / 3600
      seconds -= hours * 3600
      minutes = seconds / 60
      seconds -= minutes * 60
      "#{hours}:#{'%02i' % minutes}:#{'%02i' % seconds}"
    end

		# These are modifications to the data to make comparisons easier
		# These modifications should not change the data the main one right now is
		# removing leading and trailing whitespace
		def remove_table_whitespace(table_name)
			model = table_name.singularize.camelcase.constantize
			columns = model.columns_hash
			columns.delete("id")
			columns.delete("updated_at")
			columns.delete("created_at")
			columns.delete('nlm_download_date_description')
			columns = columns.values
			sql = "UPDATE ctgov.#{table_name} SET\n"
			sql += columns.map do |col|
				if col.type == :text
					"#{col.name} = REGEXP_REPLACE(REGEXP_REPLACE(#{col.name}, '\\s+$',''), '^\\s+', '')"
				end
			end.compact.join(",\n") + "\n"
			execute(sql)
		end

		def replace_table_text(table_name, pattern, final)
			model = table_name.singularize.camelcase.constantize
			columns = model.columns_hash
			columns.delete("id")
			columns.delete("updated_at")
			columns.delete("created_at")
			columns.delete('nlm_download_date_description')
			columns = columns.values
			sql = "UPDATE ctgov.#{table_name} SET\n"
			sql += columns.map do |col|
				if col.type == :text
					"#{col.name} = REGEXP_REPLACE(#{col.name},#{pattern},#{final},'g')"
				end
			end.compact.join(",\n") + "\n"
			execute(sql)
		end

		def normalize_text(table_name)
			replace_table_text(table_name, "'\\r\\n     '", "''")
			replace_table_text(table_name, "'\\r\\n     -  '", "'\\n\\n'")
		end

		def compare_value(table_name, column, nct_id)
			normal = execute("SELECT #{column} FROM ctgov.#{table_name} WHERE nct_id = '#{nct_id}'").to_a.first[column]
			beta = execute("SELECT #{column} FROM ctgov_beta.#{table_name} WHERE nct_id = '#{nct_id}'").to_a.first[column]
			return normal, beta
		end
  end
end
