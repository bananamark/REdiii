# Developer : Markus-Frederik Bohn (markusf.bohn@umassmed.edu)
# 
# All code (c)2012 all rights reserved

require 'rubygems'
require 'optparse'
require 'ai4r'
require 'ai4r/classifiers/multilayer_perceptron'
require 'highline/import'
require 'fileutils'
require 'socket'
require 'net/http'
require 'mkmf'

my_path = File.expand_path(File.dirname(__FILE__))
puts my_path

require "#{my_path}/class_autobuild_results.rb"
require "#{my_path}/class_logfile.rb"
require "#{my_path}/class_xia2_results.rb"
require "#{my_path}/class_index.rb"
require "#{my_path}/class_build.rb"
require "#{my_path}/class_file_prep_mr.rb"
require "#{my_path}/class_molecular_replacement.rb"
require "#{my_path}/class_MR_check.rb"
require "#{my_path}/class_balbes_result.rb"
require "#{my_path}/class_automr_results.rb"
require "#{my_path}/class_file_prep_build.rb"
require "#{my_path}/class_file_prep_refine.rb"
require "#{my_path}/class_arpwarp_results.rb"
require "#{my_path}/class_statistics_table.rb"
require "#{my_path}/class_statistics_table_imosflm.rb"
require "#{my_path}/class_perceptron.rb"
require "#{my_path}/class_ligand_dock.rb"
require "#{my_path}/class_ligand_dock_results.rb"
require "#{my_path}/class_restful_pdb.rb"

phenix_path = find_executable 'phenix'
pymol_path = find_executable 'pymol'
hkl2000_path = find_executable 'hkl2000'
imosflm_path = find_executable 'imosflm'
xia2_path = find_executable 'xia2'
balbes_path = find_executable 'balbes'
database_path = "#{my_path}/database.db"

options = {}

OptionParser.new do |opts|

opts.banner = "Usage: REdiii [options]"

   opts.on('-c','--crystal NAME', 'Mandatory. Crystal name (e.g. crystal1)' ) do |name|
     options[:crystal] = '-crystal '+name
     options[:crystalP]= name
   end

   opts.on('-s', '--spacegroup NAME',String, 'Mandatory. Spacegroup (e.g. P21)' ) do |name|
     options[:spacegroup] = '-spacegroup '+name
   end

   opts.on('--project NAME', 'Mandatory. Project name (e.g. project1)' ) do |name|
     options[:project] = '-project '+name
     options[:projectP]= name
   end

   opts.on('-n', '--number INTEGER', 'Mandatory. Number of copies to search (e.g. 2)' ) do |name|
     options[:number] = name
   end

   opts.on('-m', '--mass INTEGER', 'Mandatory. MW in dalton (e.g. 23000)' ) do |name|
     options[:mass] = name
   end

options[:rms] = '1'
   opts.on('-r', '--rms INTEGER', 'Mandatory. RMS in Angstrom (default: 1)' ) do |name|
     options[:rms] = name
   end

   opts.on('-p', '--pdb CODE',String, 'Mandatory. PDB code of search model or local file (e.g. 3v4k or MyModel.pdb)' ) do |name|
     options[:pdb] = name
   end

options[:cdb] = 'chain A'
   opts.on( '--cdb NAME', 'Optional. Chain you want to use in search model (default: chain A)' ) do |name|
     options[:cdb] = name
   end

   opts.on('-r', '--resolution FLOAT', 'Optional. Resolution limit used for scaling (e.g. 2.8)' ) do |name|
     options[:resolution] = name
   end

   opts.on('-o', '--completeness FLOAT',Float, 'Optional. Desired completeness in percent (e.g. 90)' ) do |name|
     options[:completeness] = name
   end  

   opts.on('--rmeas FLOAT',Float, 'Optional. Desired maximum rmeas in highest resolution shell (e.g. 40)' ) do |name|
     options[:rmeas] = name
   end      

   opts.on( '--index TYPE', 'Mandatory. Set xia2, imosflm, hkl2000, hkl3000 or false (e.g. xia2)') do |name|
     options[:indexing] = name
   end 
 
    opts.on( '--mr TYPE', 'Mandatory. Set automr, balbes or false (e.g. automr)') do |name|
     options[:mr] = name
   end  
  
   opts.on( '--build TYPE', 'Mandatory. Set autobuild, arpwarp or false (e.g. autobuild)') do |name|
     options[:build] = name
   end 

options[:ligandfit] = 'none'
    opts.on( '--ligand NAME', 'Mandatory. Name of ligand .pdb file (default: none)') do |name|
     options[:ligandfit] = name
   end

   opts.on( '-h', '--help', 'Display this screen' ) do
     puts opts
     exit
   end


end.parse!

#check access to desired web services

log = Logfile.new
log.create

if options[:pdb] =~ /\A\S\S\S\S\z/ then
   ping_count = 2
   server = "www.rcsb.org"
   result = `ping -q -c #{ping_count} #{server}`
      if ($?.exitstatus == 0) then
         puts "Linked to PDB"
         File.open('script.py', 'w') { |file| file.write("
import pymol
cmd.fetch(\"#{options[:pdb]}\")
cmd.select(\"ChA\", \"#{options[:cdb]}\")
cmd.extract(None,\"ChA\", zoom=0)
cmd.remove(\"(solvent and (obj01))\")
cmd.delete(\"het\")
cmd.save(\'\'\'search_model.pdb\'\'\',\'\'\'obj01\'\'\',quiet=0)
cmd.save(\'\'\'search_model.fasta\'\'\',\'\'\'obj01\'\'\',quiet=0)
") }
       system "#{pymol_path} -q -c script.py"
       options[:zdb] = 'search_model.pdb'
      else
         puts "Can't connect to PDB. Check internet connection or get a .pdb file."
         exit
      end
end
  
  search_model_code = options[:pdb]

unless options[:pdb] =~ /\A\S\S\S\S\z/
   options[:zdb] = options[:pdb]
  else
   options[:zdb] = 'search_model.pdb'
end


#decision for xia2 or imosflm or hkl2000

case options[:indexing]
when "xia2"
  xia2 = Index.new

  if options[:resolution].nil?

    xia2.run(options[:projectP], options[:crystalP], options[:spacegroup], xia2_path)

  else

    xia2.run_res(options[:projectP], options[:crystalP], options[:spacegroup], options[:resolution], xia2_path)

  end

  if !options[:completeness].nil?
    
    xia2.completeness(options[:projectP], options[:crystalP], options[:spacegroup], options[:completeness], xia2_path)

  end

  if !options[:rmeas].nil?
    
    xia2.rmeas(options[:projectP], options[:crystalP], options[:spacegroup], options[:rmeas], xia2_path)

  end

when "imosflm"

  system 'mkdir imosflm'
  Dir.chdir 'imosflm'


  proceed = "no"
    until proceed == "yes"
    system "#{imosflm_path}"

    mos_question = ask("Shall we continue, retry or leave?  ") { |theID| theID.default = "continue" }
    case mos_question

    when "leave"
      puts "No hard feelings" 
      exit

    when "retry"
    #nothing happens

    when "continue"
      puts "Let me see what you did there"
      proceed = "yes"

    end

    Dir.chdir '../'

  end

when "hkl2000"

  system 'mkdir hkl2000'
  Dir.chdir 'hkl2000'
  system 'mkdir proc'


  proceed = "no"
    until proceed == "yes"

        system "#{hkl2000_path}"


    hkl_question = ask("Shall we continue, retry or leave?  ") { |theID| theID.default = "continue" }
    case hkl_question

    when "leave"
      puts "No hard feelings" 
      exit

    when "retry"
    #nothing happens

    when "continue"
      puts "Let me see what you did there"
      proceed = "yes"

    end

    Dir.chdir '../'

  end

when "false"

  puts "Skipping indexing"

end

#Interaction with user
system "mkdir output_files"

if options[:indexing] == "xia2"
  if File.exist?("xia2/LogFiles/#{options[:projectP]}_#{options[:crystalP]}_XSCALE.log")
  xia2_results = Xia2_results.new
  xia2_statistics = xia2_results.statistics(options[:projectP], options[:crystalP])
  puts xia2_statistics
  xia2_completeness = xia2_results.completeness(options[:projectP], options[:crystalP])
  xia2_resolution = xia2_results.resolution(options[:projectP], options[:crystalP])
  xia2_rmeas = xia2_results.overall_rmeas(options[:projectP], options[:crystalP])

  log.append("You chose to run Xia2 \n\n At #{xia2_resolution} A, your completeness is #{xia2_completeness}% with an overall rmeas of #{xia2_rmeas}. \n\n\n")
  log.append("#{xia2_statistics} \n\n\n")
  end  
end


#File preparation for MR

if File.exist?("processing/#{options[:projectP]}_#{options[:crystalP]}_free.mtz")
  puts "A free.mtz file already exists for this project. I will use that one."
  log.append("A free.mtz file already exists for this project. I will use that one.\n\n\n")
else
  mr_preparation = File_prep_MR.new

  processing_file_mover = mr_preparation.file_move(options[:projectP], options[:crystalP])
end

system "cp processing/#{options[:projectP]}_#{options[:crystalP]}_free.mtz output_files/"

  if File.exist?("output_files/#{options[:projectP]}_#{options[:crystalP]}_free.mtz") == false
    perceptron = Perceptron.new

    new_spacegroup = perceptron.spacegroup_learned(options[:projectP], options[:number], my_path)
    puts new_spacegroup
    new_spacegroup = "-spacegroup #{new_spacegroup}"
    xia2.run(options[:projectP], options[:crystalP], new_spacegroup, xia2_path)
    puts "Tried to determine spacegroup from our previous results."
    if File.exist?("xia2/LogFiles/#{options[:projectP]}_#{options[:crystalP]}_XSCALE.log")
      xia2_results = Xia2_results.new
      xia2_statistics = xia2_results.statistics(options[:projectP], options[:crystalP])
      puts xia2_statistics
      xia2_completeness = xia2_results.completeness(options[:projectP], options[:crystalP])
      xia2_resolution = xia2_results.resolution(options[:projectP], options[:crystalP])
      xia2_rmeas = xia2_results.overall_rmeas(options[:projectP], options[:crystalP])

      log.append("You chose to run Xia2\n\n At #{xia2_resolution} A, your completeness is #{xia2_completeness}% with an overall rmeas of #{xia2_rmeas}. \n\n\n")
      log.append("#{xia2_statistics} \n\n\n")
      processing_file_mover = mr_preparation.file_move(options[:projectP], options[:crystalP])
    else   
      log.append("Processing seems to have failed. \n\n\n")
    end

end

#Conducting MR

molrep = MolecularReplacement.new
molrep.decision(options[:mr], options[:projectP], options[:crystalP], options[:zdb], options[:rms], options[:mass], options[:number], phenix_path, balbes_path)

#Checking if MR was successful

mr_check = MR_check.new
if mr_check.output_files(options[:mr]) == false

  puts "Seems molecular replacement failed. Trying to determine composition of asymmetric unit."
  log.append("Seems molecular replacement failed. Trying to determine composition of asymmetric unit using balbes.\n\n\n")

  get_composition_run = MolecularReplacement.new
  get_composition_run.decision("balbes", options[:projectP], options[:crystalP], options[:zdb], options[:rms], options[:mass], options[:number])

  get_composition_results = Balbes_results.new
  options[:number] = get_composition_results.molecules_in_AU

  auto_molrep = MolecularReplacement.new
  auto_molrep.decision("automr", options[:projectP], options[:crystalP], options[:zdb], options[:rms], options[:mass], options[:number])
  auto_mr_check = MR_check.new

  if auto_mr_check.output_files(options[:mr]) == false
    puts "Could not find a molecular replacement solution. Even after trying BALBES. Will look for a better search model"
    log.append("Could not find a molecular replacement solution. Even after trying BALBES. Will look for a better search model.\n\n\n")
    
    query = Restful_PDB.new

    sequence = query.file_prep
    answer = query.pdb_query(sequence)
    pdb_loop_counter = 0

    if answer.length > 10 
      number_of_trials = 10
    else
      number_of_trials = answer.length
    end

    while auto_mr_check.output_files(options[:mr]) == false

      puts "Trying to perform molecular replacement with #{answer[pdb_loop_counter]}"
      log.append("Trying to perform molecular replacement with #{answer[pdb_loop_counter]}\n\n\n")
      auto_molrep = MolecularReplacement.new
      auto_molrep.decision("automr", options[:projectP], options[:crystalP], answer[pdb_loop_counter], options[:rms], options[:mass], options[:number])
      auto_mr_check = MR_check.new
      pdb_loop_counter += 1

       if pdb_loop_counter == number_of_trials
          puts "No better search model could be generated from matching #{number_of_trials} sequences from the pdb."
          log.append("No better search model could be generated from matching #{number_of_trials} sequences from the pdb.\n\n\n")
        break
      end

    end

  end
end

#File preparation for tracing

if File.exist?("molecular_replacement/MR.1.pdb")
  puts "A pdb file already exists for this project. I will use that one."
  log.append("A pdb file already exists for this project. I will use that one.\n\n\n")
  file_prep_build = File_prep_build.new
else
  file_prep_build = File_prep_build.new

  molecular_replacement_file_mover = file_prep_build.file_move
end

#Interaction with user


case file_prep_build.molecular_replacement_check
  when "automr"
    automr_results = AutoMR_results.new
    rfz = automr_results.rfz
    tfz = automr_results.tfz
    log.append("You chose Phenix AutoMR\n\n The top scoring solution has RFZ=#{rfz} and TFZ=#{tfz} \n\n\n")
  when "balbes"
    balbes = Balbes_results.new
    qfactor = balbes.qfactor
    molecules_in_AU = balbes.molecules_in_AU
    probability = balbes.probability
    rfree_final = balbes.rfree_final[1]
    r_final = balbes.r_final[1]
    log.append("You chose BALBES\n\n Your Q-factor is #{qfactor} with #{molecules_in_AU} molecules in the asymmetric unit. \nThe likelihood of this being a solution is #{probability}%.\nFinal R-factor is #{r_final}, final R-free is #{rfree_final} \n\n\n")
end


system "cp molecular_replacement/MR.1.mtz output_files/"
system "cp molecular_replacement/MR.1.pdb output_files/"

#Conducting trace

build = Build.new
build.decision(options[:build], options[:projectP], options[:crystalP], phenix_path, pymol_path)

#Finalizing trace

file_prep_refine = File_prep_refine.new

file_prep_refine.file_move(options[:projectP], options[:crystalP])

case file_prep_refine.build_check
when "autobuild"
  autobuild_results = AutoBuild_results.new
  r_start = autobuild_results.r_start
  rfree_start = autobuild_results.rfree_start
  r_final = autobuild_results.r_final
  rfree_final = autobuild_results.rfree_final
  spacegroup = autobuild_results.spacegroup(options[:projectP], options[:crystalP])
  log.append("You chose Phenix AutoBuild\n\n Your solution has R=#{r_final} R-free=#{rfree_final}")
when "arpwarp"
  arpwarp_results = Arpwarp_results.new
  r_final = arpwarp_results.r_final(options[:projectP], options[:crystalP])
  rfree_final = arpwarp_results.rfree_final(options[:projectP], options[:crystalP])
  spacegroup = arpwarp_results.spacegroup(options[:projectP], options[:crystalP])
  log.append("You chose ARP/wARP\n\n You solution has: R=#{r_final} R-free=#{rfree_final}")
end


data = "#{options[:projectP]},#{options[:number]},#{spacegroup},#{search_model_code},"
File.open(database_path, 'a') { |f| f.puts data}

if options[:indexing] == "xia2"
table = Statistics_table.new
table.generate_table(options[:projectP], options[:crystalP], table.resolution, "cryogenic(-180 \xC2\xB0C)", spacegroup, table.cell_a, table.cell_b, table.cell_c, table.cell_alpha, table.cell_beta, table.cell_gamma, options[:number], table.completeness, table.total_reflections, table.unique_reflections, table.i_o_sigma, table.av_redundancy, table.rmerge, table.rmeas, table.rpim, table.cc_star(options[:projectP], options[:crystalP]), table.rmsd_bonds, table.rmsd_angles, table.r_final, table.rfree_final)
log.append("Statistics table written")
end

if options[:indexing] == "imosflm"
table = Statistics_table_imosflm.new
table.generate_table(options[:projectP], options[:crystalP], table.resolution, "cryogenic(-180 \xC2\xB0C)", spacegroup, table.cell_a, table.cell_b, table.cell_c, table.cell_alpha, table.cell_beta, table.cell_gamma, options[:number], table.completeness, table.total_reflections, table.unique_reflections, table.i_o_sigma, table.av_redundancy, table.rmerge, table.rmeas, table.rpim, table.cc_half, table.rmsd_bonds, table.rmsd_angles, table.r_final, table.rfree_final)
log.append("Statistics table written")
end

unless options[:ligandfit] == "none"
  ligandfit = Ligand_Dock.new
  ligandfit.ligand_find(options[:ligandfit], options[:projectP], options[:crystalP], phenix_path, pymol_path)
  ligand_dock_results = Ligand_Dock_Results.new
  r_final = ligand_dock_results.r_final
  rfree_final = ligand_dock_results.rfree_final

  log.append("You performed LigandFit\n\n You solution has: R=#{r_final} R-free=#{rfree_final}\n\n")
end

