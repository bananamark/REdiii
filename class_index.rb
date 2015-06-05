class Index 

	attr_accessor :project, :crystal, :spacegroup, :resolution

	def run (project, crystal, spacegroup, xia2_path)
        system "mkdir xia2"
		Dir.chdir('xia2')
		system "#{xia2_path} -project #{project} -crystal #{crystal} #{spacegroup} -3daii ../"
		Dir.chdir('../')
	end

	def run_res (project, crystal, spacegroup, resolution, xia2_path)
        system "mkdir xia2"
		Dir.chdir('xia2')
		system "#{xia2_path} -project #{project} -crystal #{crystal} #{spacegroup} -resolution #{resolution} -3daii ../"
		Dir.chdir('../')
	end

	def completeness (project, crystal, spacegroup, goal_completeness, xia2_path)

		start = Xia2_results.new
		resolution = start.resolution(project, crystal)
		completeness = start.completeness(project, crystal)

		while completeness < goal_completeness      	
		resolution = resolution+0.1
         	run_res(project, crystal, spacegroup, resolution, xia2_path)
         	check = Xia2_results.new
         	completeness = check.completeness(project, crystal)
         	resolution = check.resolution(project, crystal)
         	if resolution > 4
         		raise "Can't reach completeness target below 4 A resolution. Data quality too low."
         		exit
         	end
    	end
  	end

  	def rmeas (project, crystal, spacegroup, goal_rmeas, xia2_path)

		start = Xia2_results.new
		resolution = start.resolution(project, crystal)
		rmeas = start.rmeas(project, crystal)

		while rmeas > goal_rmeas
         	resolution = resolution+0.1
         	run_res(project, crystal, spacegroup, resolution, xia2_path)
         	check = Xia2_results.new
         	rmeas = check.rmeas(project, crystal)         	
         	resolution = check.resolution(project, crystal)
         	if resolution > 4
         		raise "Can't reach completeness target below 4 A resolution. Data quality too low."
         		exit
         	end
         end
     end
end

