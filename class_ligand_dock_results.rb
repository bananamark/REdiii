class Ligand_Dock_Results
  def contents
    File.open("output_files/liganded_pdb_refine_001.log") { |f| f.read }
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
end
