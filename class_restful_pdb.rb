class Restful_PDB

  def file_prep
    File.open('search_model.fasta','r+') do |file|

        first_line = true
    while line = file.gets
      line.chomp!
        if line =~ /^>/
        puts unless first_line
        output = line[1..-20]
        else
        output <<  line
        end
    end
       output << "\n"
     first_line = false
    return output
  end
  end


  def pdb_query (sequence)

url = URI.parse('http://www.rcsb.org/pdb/rest/search')
request = Net::HTTP::Post.new(url.path)
request.body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>  
<orgPdbCompositeQuery version=\"1.0\">
    <resultCount>12</resultCount>
    <queryId>3498F2A8</queryId>
 <queryRefinement>
  <queryRefinementLevel>0</queryRefinementLevel>
  <orgPdbQuery>
    <version>head</version>
    <queryType>org.pdb.query.simple.SequenceQuery</queryType>
    <resultCount>10</resultCount>
    <sequence>#{sequence}</sequence>
    <searchTool>blast</searchTool>
    <maskLowComplexity>yes</maskLowComplexity>
    <eCutOff>0.01</eCutOff>
  </orgPdbQuery>
 </queryRefinement>
 <queryRefinement>
  <queryRefinementLevel>1</queryRefinementLevel>
  <conjunctionType>and</conjunctionType>
  <orgPdbQuery>
    <version>head</version>
    <queryType>org.pdb.query.simple.ExpTypeQuery</queryType>
    <description>Experimental Method is X-RAY</description>
    <mvStructure.expMethod.value>X-RAY</mvStructure.expMethod.value>
    <mvStructure.expMethod.exclusive>y</mvStructure.expMethod.exclusive>
  </orgPdbQuery>
 </queryRefinement>
</orgPdbCompositeQuery>"

response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}.body.split(" ")

  return response

  end
end

#sequence = "ELFEPWNNLPKYYILLHIMLGEILRHSMDPPTFTFNFNNEPWVRGRHETYLCYEVERMHNDTWVLLNQRRGFLCNQAPHKHGFLEGRHAELCFLDVIPFWKLDLDQDYRVTCFTSWSPCFSCAQEMAKFISKNKHVSLCIFTARIYDDQGRCQEGLRTLAEAGAKISIMTYSEFKHCWDTFVDHQGCPFQPWDGLDEHSQDLSGRLRAILQNQEN"
#query = Restful_PDB.new

#sequence = query.file_prep
#answer = query.pdb_query(sequence)

#puts answer
#puts answer.length
