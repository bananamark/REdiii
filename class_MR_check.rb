class MR_check

  def output_files (choice)
    case choice
    when "automr"
      Dir.chdir('phenix')
      dir_count = Dir[File.join('.', 'AutoMR*')].count { |file| File.directory?(file) } #finds latest AutoBuild directory
      Dir.chdir('../')
        return File.exist?("phenix/AutoMR_run_#{dir_count}_/MR.log")
      when "balbes"
        return File.exist?("balbes/results/refmac_final_result.pdb")
      when "false"
        return true
      end
  end

end
