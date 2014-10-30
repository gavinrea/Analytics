class voter_forms_report.rb < template_report.rb

	def countData(rows, accum)

		rows.each do |row|
			if accum.has_key?(row.form) 
				accum[row.form] += 1
			else 
				accum[row.form] = 0   
			end
		end
	end
end