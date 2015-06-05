class Build

  attr_accessor :choice, :project, :crystal

  def decision (choice, project, crystal, phenix_path)
    case choice
    when "autobuild"
      return autobuild(project, crystal, phenix_path)
    when "arpwarp"
      return arpwarp(project,crystal)
    when "buccaneer"
      return buccaneer(project, crystal, phenix_path)
    when "false"
      puts "No chain tracing and solvent in this round."
      return true
    end
  end

  def autobuild (project, crystal, phenix_path)
    system  "mkdir phenix"
    Dir.chdir("phenix")
    system "#{phenix_path}.autobuild  ../molecular_replacement/MR.1.pdb ../processing/#{project}_#{crystal}_free.mtz build_type=RESOLVE nproc=5"
    Dir.chdir("../")
  end

  def arpwarp (project, crystal)
    system  "mkdir arpwarp"
    pathName1 = File.expand_path(File.dirname('arpwarp'))
    Dir.chdir("arpwarp")
    File.open('arp1.py', 'w') { |file| file.write("
import pymol
cmd.load(\"#{pathName1}/molecular_replacement/MR.1.pdb\")
cmd.select(\"ChA\", \"chain A\")
cmd.extract(None,\"ChA\", zoom=0)
cmd.remove(\"(solvent and (obj01))\")
cmd.save(\'\'\'arp_input.pdb\'\'\',\'\'\'obj01\'\'\',quiet=0)
cmd.save(\'\'\'arp_input.fasta\'\'\',\'\'\'obj01\'\'\',quiet=0)
") }

    system "#{pymol_path} -q -c arp1.py"    
    File.open('arp_input.fasta','r+') do |file|
    first_line = true
    output = File.open('arp_input.pir','w')
    while line = file.gets
      line.chomp!
        if line =~ /^>/
        puts unless first_line
        output << line[1..-20]
        output <<  ">P1;arp_input\n\n"
        else
        output <<  line
        end
    end
       output << "\n"
     first_line = false
    output.close
    #end
    Dir.chdir('../')
      system  "$warpbin/auto_tracing.sh ncsrestraints {0} ncsextension {0} seqin {#{pathName1}/arpwarp/arp_input.pir} datafile {#{pathName1}/processing/#{project}_#{crystal}_free.mtz} workdir {#{pathName1}/arpwarp/} fp {F} sigfp {SIGF} modelin {#{pathName1}/arpwarp/arp_input.pdb} freelabin {FreeR_flag}"
      system 'mv arpwarp/201* arp_trace'
      Dir.chdir('arpwarp')
      File.open('arp2.py', 'w') { |file| file.write("
import pymol
cmd.load(\"#{pathName1}/arp_trace/#{project}_#{crystal}_free_warpNtrace.pdb\")
cmd.select(\"ChZ\", \"chain Z\")
cmd.remove(\"ChZ\");cmd.delete(\"ChZ\")
cmd.save(\'\'\'arp_solv_input.pdb\'\'\',\'\'\'#{project}_#{crystal}_free_warpNtrace\'\'\',quiet=0)
") }
    system "#{pymol_path} -q -c arp2.py"
      Dir.chdir '../'
      system  "$warpbin/auto_solvent.sh datafile {#{pathName1}/processing/#{project}_#{crystal}_free.mtz} workdir {#{pathName1}/arpwarp/} fp {F} sigfp {SIGF} protein {#{pathName1}/arpwarp/arp_solv_input.pdb} freer {FreeR_flag}"
      system 'mv arpwarp/201* arp_solv'
      #FileUtils.cp("arp_solv/#{project}_#{crystal}_free_warp_solvent.pdb", "../../output_files")
  end
end 

  def buccaneer (project, crystal)
    system  "mkdir phenix"
    Dir.chdir("phenix")
    system "#{phenix_path}.autobuild  ../molecular_replacement/MR.1.pdb ../processing/#{project}_#{options[crystal]}_free.mtz build_type=RESOLVE RESOLVE_AND_BUCCANEER nproc=5"
    Dir.chdir('../')
  end 
end
