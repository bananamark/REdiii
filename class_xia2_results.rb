class Xia2_results
  attr_accessor :project, :crystal
  def contents (project, crystal)
    if File.exist?("xia2/LogFiles/#{project}_#{crystal}_XSCALE.log")
      File.open("xia2/LogFiles/#{project}_#{crystal}_XSCALE.log") { |f| f.read }
    elsif
       File.readlines("xia2/xia2.error").grep(/Acentric/)
        Dir.chdir("xia2/#{crystal}/scale")
        system "scalepack2mtz HKLIN #{project}_#{crystal}_scaled.sca \
              HKLOUT scaled.mtz <<eof
Wavelength 1.54
end
eof"
      system "end"
      system "ctruncate -mtzin scaled.mtz -mtzout truncate_scaled.mtz -colin '/*/*/[IMEAN,SIGIMEAN]'"
      system "uniqueify truncate_scaled.mtz"
      system "mv truncate_scaled-unique.mtz #{project}_#{crystal}_free.mtz"
      system "mkdir ../../DataFiles"
      system "mv #{project}_#{crystal}_free.mtz ../../DataFiles/"
      Dir.chdir('../../')
  end
end

  def statistics (project, crystal)
    mycontents = contents(project, crystal)
    mycontents.match(/AS FUNCTION OF RESOLUTION(.*) ========== /m)[1].strip #extracting the final statistics table
  end

  def completeness (project, crystal)
    mystatistics = statistics(project, crystal)
    prefilter = mystatistics.scan(/(\d+(?:\.\d+)?)/)
    return prefilter[-10].join.to_f
  end

  def resolution (project, crystal)
    mystatistics = statistics(project, crystal)
    prefilter = mystatistics.scan(/(\d+(?:\.\d+)?)/)
    return prefilter[-27].join.to_f
  end

  def rmeas (project, crystal)
    mystatistics = statistics(project, crystal)
    prefilter = mystatistics.scan(/(\d+(?:\.\d+)?)/)
    return prefilter[-18].join.to_f
  end

  def overall_rmeas (project, crystal)
    mystatistics = statistics(project, crystal)
    prefilter = mystatistics.scan(/(\d+(?:\.\d+)?)/)
    return prefilter[-5].join.to_f
  end

  def dimensions (project, crystal)
    mycontents = contents(project, crystal)
    dimensions = contents.match(/UNIT_CELL_CONSTANTS= (.*)/n )[1].strip
  end
end

