class Arpwarp_results
  def contents (project, crystal)
    contents = File.open("build/#{project}_#{crystal}_free_warp_solvent.pdb")
    return contents
  end

  def r_final (project, crystal)
    arp_r_line = [*contents][22]
    arp_r = arp_r_line.scan(/\d+\D\d+/).last.first
  end

  def rfree_final (project, crystal)
    arp_freer_line = [*arp_contents][23]
    arp_free = arp_freer_line.scan(/\d+\D\d+/).last.first
  end

  def spacegroup (project, crystal)
    contents.scan(/CRYST1(.*)\n/).join.split(" ")[6..-1]
  end
end
