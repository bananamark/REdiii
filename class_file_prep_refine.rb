class File_prep_refine

  def build_check
    if File.exist?('phenix')
      return "autobuild"
    elsif File.exist?('arp_solv')
      return "arpwarp"
    else
      puts "Whatever you're planning on doing, it doesn't make sense..."
      return true
    end
  end

  def file_move (project, crystal)
    system 'mkdir build'

    case build_check 
    when "autobuild"
      Dir.chdir('phenix')
      dir_count = Dir[File.join('.', 'AutoBuild*')].count { |file| File.directory?(file) }
      system "cp AutoBuild_run_#{dir_count}_/overall_best_final_refine_001.pdb ../build"
      system "cp AutoBuild_run_#{dir_count}_/overall_best_final_refine_001.mtz ../build"
      system "cp AutoBuild_run_#{dir_count}_/overall_best_final_refine_001.log ../build"
      system "cp AutoBuild_run_#{dir_count}_/overall_best_final_refine_001.pdb ../output_files"
      system "cp AutoBuild_run_#{dir_count}_/overall_best_final_refine_001.mtz ../output_files"
      system "cp AutoBuild_run_#{dir_count}_/overall_best_final_refine_001.log ../output_files"
      Dir.chdir('../')

    when "arpwarp"
      Dir.chdir('arp_solv')
      system "cp #{project}_#{crystal}_free_warp_solvent.pdb ../build"
      system "cp #{project}_#{crystal}_free_warp_solvent.pdb ../output_files"
      Dir.chdir('../')
    end
  end
end
