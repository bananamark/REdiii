class File_prep_build

  def molecular_replacement_check
    system 'pwd'
    if File.exist?("balbes")
      return "balbes"

    elsif File.exist?("phenix")
      return "automr" 

    else
      raise "Could not find input files for building"
    end
  end

  def file_move
    system 'mkdir molecular_replacement'

    case molecular_replacement_check
    when "automr"
      Dir.chdir('phenix')
      dir_count = Dir[File.join('.', 'AutoMR*')].count { |file| File.directory?(file) }
      system "cp AutoMR_run_#{dir_count}_/MR.1.pdb ../molecular_replacement"
      system "cp AutoMR_run_#{dir_count}_/MR.1.mtz ../molecular_replacement"
      Dir.chdir('../')

    when "balbes"
      system "cp balbes/results/refmac_final_result.pdb molecular_replacement/"
      system "mv molecular_replacement/refmac_final_result.pdb molecular_replacement/MR.1.pdb"
      system "cp balbes/results/refmac_final_result.mtz molecular_replacement/"
      system "mv molecular_replacement/refmac_final_result.mtz molecular_replacement/MR.1.mtz"
    end

  end

end
