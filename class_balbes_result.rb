class Balbes_results

  def contents
    system 'pwd'
    File.open("balbes/results/Process_information.txt") { |f| f.read }
  end

  def qfactor
    contents.match(/The best Q after all model calculations is (.*)\n\nSOLUTION SUMMARY/m)[1].strip
  end

  def probability
    contents.match(/a solution is (\d+(?:\.\d+)?)%/m)[1].strip
  end

  def r_final
    r_final_pre = contents.scan(/(\d+(?:\.\d+)?)\/(\d+(?:\.\d+)?)/m)
        r_loc = r_final_pre.length
        r_final = r_final_pre[r_loc-2]
        return r_final.map(&:to_f)
  end

  def rfree_final
    r_final_pre = contents.scan(/(\d+(?:\.\d+)?)\/(\d+(?:\.\d+)?)/m)
    r_loc = r_final_pre.length
        rfree_final = r_final_pre[r_loc-1]
        return rfree_final.map(&:to_f)
  end

  def molecules_in_AU
    prefilter = contents.match(/Monomers found    \|        (\d)/)[1].strip
    return prefilter.to_f
  end
end
