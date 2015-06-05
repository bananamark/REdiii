class MolecularReplacement

  attr_accessor :project, :crystal, :pdb, :rms, :mass, :number

  def decision (choice, project, crystal, pdb, rms, mass, number, phenix_path, balbes_path)
    case choice
    when "automr"
      return AutoMR(project, crystal, pdb, rms, mass, number, phenix_path)
    when "balbes"
      return Balbes(project, crystal, pdb, balbes_path)
    when "false"
      puts "No molecular replacement in this round"
      return true
    end
  end

  def AutoMR (project, crystal, pdb, rms, mass, number, phenix_path)
    system  "mkdir phenix"
    Dir.chdir("phenix")
    system  "#{phenix_path}.automr ../processing/#{project}_#{crystal}_free.mtz ../#{pdb} RMS=#{rms} mass=#{mass} copies=#{number} nproc=5 build=False"
    Dir.chdir("../")
  end

  def Balbes (project, crystal, pdb, balbes_path)
    pathName1 = File.expand_path(File.dirname('processing'))
    system  "#{balbes_path} -o balbes -f #{pathName1}/processing/#{project}_#{crystal}_free.mtz -m #{pathName1}/#{pdb}"  
  end

end
