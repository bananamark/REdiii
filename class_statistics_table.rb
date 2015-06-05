class Statistics_table

	def resolution
		contents = File.open("xia2/xia2.txt") { |f| f.read }
		contents.scan(/High resolution limit(.*)\n/).join.split("\t")[1]
	end

	def completeness
		contents = File.open("xia2/xia2.txt") { |f| f.read }
		contents.scan(/Completeness(.*)\n/).join.split("\t")[1]
	end

	def cell_a
		contents = File.open("output_files/overall_best_final_refine_001.pdb") { |f| f.read }
		contents.scan(/CRYST1(.*)\n/).join.split(" ")[0]
	end

	def cell_b
		contents = File.open("output_files/overall_best_final_refine_001.pdb") { |f| f.read }
		contents.scan(/CRYST1(.*)\n/).join.split(" ")[1]
	end

	def cell_c
		contents = File.open("output_files/overall_best_final_refine_001.pdb") { |f| f.read }
		contents.scan(/CRYST1(.*)\n/).join.split(" ")[2]
	end

	def cell_alpha
		contents = File.open("output_files/overall_best_final_refine_001.pdb") { |f| f.read }
		contents.scan(/CRYST1(.*)\n/).join.split(" ")[3]
	end

	def cell_beta
		contents = File.open("output_files/overall_best_final_refine_001.pdb") { |f| f.read }
		contents.scan(/CRYST1(.*)\n/).join.split(" ")[4]
	end

	def cell_gamma
		contents = File.open("output_files/overall_best_final_refine_001.pdb") { |f| f.read }
		contents.scan(/CRYST1(.*)\n/).join.split(" ")[5]
	end

	def total_reflections
		contents = File.open("xia2/xia2.txt") { |f| f.read }
		contents.scan(/Total observations(.*)\n/).join.split("\t")[1]
	end
	
	def unique_reflections
		contents = File.open("xia2/xia2.txt") { |f| f.read }
		contents.scan(/Total unique(.*)\n/).join.split("\t")[1]
	end

	def i_o_sigma
		contents = File.open("xia2/xia2.txt") { |f| f.read }
		contents.scan(/I\/sigma(.*)\n/).join.split("\t")[1]
	end

	def av_redundancy
		contents = File.open("xia2/xia2.txt") { |f| f.read }
		contents.scan(/Multiplicity(.*)\n/).join.split("\t")[1]
	end

	def rmerge
		contents = File.open("xia2/xia2.txt") { |f| f.read }
		contents.scan(/Rmerge(.*)\n/).join.split("\t")[1]
	end

	def rmeas
		contents = File.open("xia2/xia2.txt") { |f| f.read }
		contents.scan(/Rmeas\(I\)(.*)\n/).join.split("\t")[1]
	end

	def rpim
		contents = File.open("xia2/xia2.txt") { |f| f.read }
		contents.scan(/Rpim\(I\)(.*)\n/).join.split("\t")[1]
	end

	def cc_star (project, crystal)
		contents = File.open("xia2/LogFiles/#{project}_#{crystal}_XSCALE.log") { |f| f.read } 
		contents.match(/AS FUNCTION OF RESOLUTION(.*) ========== /m)[1].strip.scan(/(\d+(?:\.\d+)?)/)[-4].map(&:to_f)
	end

	def rmsd_bonds
		contents = File.open("output_files/overall_best_final_refine_001.pdb") { |f| f.read }
		contents.scan(/REMARK Final:(.*)\n/).join.split(" ")[8]
	end

	def rmsd_angles
		contents = File.open("output_files/overall_best_final_refine_001.pdb") { |f| f.read }
		contents.scan(/REMARK Final:(.*)\n/).join.split(" ")[11]
	end

	def r_final
		contents = File.open("output_files/overall_best_final_refine_001.pdb") { |f| f.read }
		contents.scan(/REMARK Final:(.*)\n/).join.split(" ")[2]
	end

	def rfree_final
		contents = File.open("output_files/overall_best_final_refine_001.pdb") { |f| f.read }
		contents.scan(/REMARK Final:(.*)\n/).join.split(" ")[5]
	end

	def generate_table (project, crystal, resolution, temperature, spacegroup, cell_a, cell_b, cell_c, cell_alpha, cell_beta, cell_gamma, number, completeness, total_refs, unique_refs, i_o_sigma, av_red, rmerge, rmeas, rpim, cc_star, rmsd_bonds, rmsd_angles, r_final, rfree_final) 
		File.open('output_files/statistics.csv', 'w') { |f| f.write(" ,#{project}_#{crystal}\n")}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "resolution,#{resolution} \xC3\x85\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "temperature,#{temperature}\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "spacegroup,#{spacegroup}\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "cell dimensions,\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "a,#{cell_a} \xC3\x85\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "b,#{cell_b} \xC3\x85\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "c,#{cell_c} \xC3\x85\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "\xCE\xB1,#{cell_alpha}\xC2\xB0\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "\xCE\xB2,#{cell_beta}\xC2\xB0\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "\xCE\xB3,#{cell_gamma}\xC2\xB0\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "molecules in AU,#{number}\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "completeness,#{completeness}\x25\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "total reflections,#{total_refs}\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "unique reflections,#{unique_refs}\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "I/sigma,#{i_o_sigma}\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "av redundancy,#{av_red}\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "rmerge,#{rmerge}\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "rmeas,#{rmeas}\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "rpim,#{rpim}\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "CC\x2A,#{cc_star}\x25\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "rmsd in:,\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "bonds,#{rmsd_bonds} \xC3\x85\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "angles,#{rmsd_angles}\xC2\xB0\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "Rfactor,#{r_final}\n"}
		File.open('output_files/statistics.csv', 'a') { |f| f.puts "Rfree,#{rfree_final}\n"}
	end
end
