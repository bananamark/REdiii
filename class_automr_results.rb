class AutoMR_results

  def contents
    Dir.chdir('phenix')
    dir_count = Dir[File.join('.', 'AutoMR*')].count { |file| File.directory?(file) }
    Dir.chdir('../')
    contents=File.open("phenix/AutoMR_run_#{dir_count}_/MR.log") { |f| f.read }
  end

  def rfz
    contents.match(/annotation \(history\)\:\n   SOLU SET  RFZ=(.*)\n   SOLU SPAC/m)[1].strip.scan(/(\d+(?:\.\d+)?)/m)[0].map(&:to_f)   
  end

  def tfz
    contents.match(/annotation \(history\)\:\n   SOLU SET  RFZ=(.*)\n   SOLU SPAC/m)[1].strip.scan(/(\d+(?:\.\d+)?)/m)[1].map(&:to_f)
  end

end
