class AutoBuild_results
  def contents
    dir_count = Dir[File.join('.', 'AutoBuild*')].count { |file| File.directory?(file) } #finds latest AutoBuild directory
    File.open("build/overall_best_final_refine_001.log") { |f| f.read }
  end

  def statistics
    prefilter = contents.match(/phenix.refine: finished ===========================(.*)/m)[1].strip #extracting the final statistics table
    statistics = prefilter.scan(/(\d+(?:\.\d+)?)/) #converting table to array
  end

  def r_start
    return statistics[-3].map(&:to_f)
  end

  def r_final
    return statistics[-2].map(&:to_f)
  end

  def rfree_start
    return statistics[-3].map(&:to_f)
  end

  def rfree_final
    return statistics[-1].map(&:to_f)
  end
  
  def spacegroup (project, crystal)
    contents = File.open("build/overall_best_final_refine_001.pdb") { |f| f.read }
    contents.scan(/CRYST1(.*)\n/).join.split(" ")[6..-1].join
  end
end
