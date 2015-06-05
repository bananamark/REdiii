class File_prep_MR

  def index_check
    if File.exist?("output.sca")
      return "hkl3000"

    elsif File.exist?("hkl2000")
      return "hkl2000"
    
    elsif File.exist?("imosflm")
      return "imosflm"
    
    elsif File.exist?("xia2")
      return "xia2"

    else
      puts "You need to supply some data, you moron!"
      exit
    end
  end

  def file_move (project, crystal)
    system 'mkdir processing'

    case index_check
    when "imosflm"
      system "mv imosflm/ctruncate* processing/"
      system "mv processing/ctruncate* processing/#{project}_#{crystal}_mos.mtz"
      system  "uniqueify processing/#{project}_#{crystal}_mos.mtz"
      system "mv #{project}_#{crystal}_mos-unique.mtz processing/#{project}_#{crystal}_free.mtz"
    

     when "xia2"
#if File.readlines("xia2/xia2.error").grep(/Acentric/)
#        Dir.chdir("xia2/#{crystal}/scale")
        #system "scalepack2mtz HKLIN #{project}_#{crystal}_unmerged.sca \
        #      HKLOUT scaled.mtz <<eof
#Wavelength 1.54
#end
#eof"
      #system "end"
      #system "ctruncate -mtzin scaled.mtz -mtzout truncate_scaled.mtz -colin '/*/*/[IMEAN,SIGIMEAN]'"
      #system "uniqueify #{project}_#{crystal}_scaled.mtz"
      #system "mv #{project}_#{crystal}_scaled-unique.mtz #{project}_#{crystal}_free.mtz"
      #system "mkdir ../../DataFiles"
      #system "mv #{project}_#{crystal}_free.mtz ../../DataFiles/"
      #Dir.chdir('../../../')
  #else
      system "mv xia2/DataFiles/#{project}_#{crystal}_free.mtz processing/#{project}_#{crystal}_free.mtz"
         
  

    when "hkl3000"
      system "mv output.sca processing/"
      Dir.chdir('processing')
      system "scalepack2mtz HKLIN output.sca \
              HKLOUT scaled.mtz <<eof
Wavelength 1.54
end
eof"
      system "end"
      system "ctruncate -mtzin scaled.mtz -mtzout truncate_scaled.mtz -colin '/*/*/[IMEAN,SIGIMEAN]'"
      system "uniqueify truncate_scaled.mtz"
      system "mv truncate_scaled-unique.mtz #{project}_#{crystal}_free.mtz"
      Dir.chdir('../')


    when "hkl2000"
    system "mv hkl2000/proc/output.sca processing/"
    Dir.chdir('processing')
    system "scalepack2mtz HKLIN output.sca \
              HKLOUT scaled.mtz <<eof
Wavelength 1.54
end
eof"
    system "end"
    system "ctruncate -mtzin scaled.mtz -mtzout truncate_scaled.mtz -colin '/*/*/[IMEAN,SIGIMEAN]'"
    system "uniqueify truncate_scaled.mtz"
    system "mv truncate_scaled-unique.mtz #{project}_#{crystal}_free.mtz"
    Dir.chdir('../')
    end
  end
end
