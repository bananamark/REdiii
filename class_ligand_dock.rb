class Ligand_Dock

	def ligand_find (ligand, project, crystal, phenix_path, pymol_path)
		system "mkdir ligandfit"
        Dir.chdir 'ligandfit'
		system "#{phenix_path}.elbow ../#{ligand}"
        if File.exist?("corrected.pdb")
		  system "#{phenix_path}.ligandfit ../output_files/overall_best_final_refine_001.mtz model=../output_files/overall_best_final_refine_001.pdb ligand=corrected.pdb nproc=4"
		elsif File.exist?("elbow.Ligand_pdb.001.pdb")
          system "#{phenix_path}ligandfit ../output_files/overall_best_final_refine_001.mtz model=../output_files/overall_best_final_refine_001.pdb ligand=elbow.Ligand_pdb.001.pdb nproc=4"
        else
          system "#{phenix_path}.ligandfit ../output_files/overall_best_final_refine_001.mtz model=../output_files/overall_best_final_refine_001.pdb ligand=../#{ligand} nproc=4"
        end
        dir_count = Dir[File.join('.', 'LigandFit_run_*')].count { |file| File.directory?(file) }
		File.open('script2.py', 'w') { |file| file.write("
import pymol
cmd.load(\"ligandfit/LigandFit_run_#{dir_count}_/ligand_fit_1_1.pdb\")
cmd.load(\"ligandfit/LigandFit_run_#{dir_count}_/EDITED_overall_best_final_refine_001.pdb\")
cmd.save(\'\'\'ligandfit/liganded_pdb.pdb\'\'\',\'\'\'((ligand_fit_1_1) or (EDITED_overall_best_final_refine_001))\'\'\',quiet=0)
") }
        
        system "#{pymol_path} -q -c ligandfit/script2.py"
    	system "#{phenix_path}.refine ../output_files/#{project}_#{crystal}_free.mtz liganded_pdb.pdb nproc=2 refinement.input.xray_data.labels=IMEAN,SIGIMEAN ordered_solvent=true"
        system "cp liganded_pdb.updated_refine_001.pdb ../output_files"
        system "cp liganded_pdb.updated_refine_001.mtz ../output_files"
        system "cp liganded_pdb.updated_refine_001.log ../output_files"

        Dir.chdir '../'
    end

end
