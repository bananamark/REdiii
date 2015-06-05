class Logfile

  def create
    File.open('REdiii.log', 'w') { |f| f.write("####################################################################################################
#                                                                                                  #
#                         The details of your REdiii run are the following                         #
#                                                                                                  #
####################################################################################################  \n\n")}
  end

  def append (data)
    File.open('REdiii.log', 'a') { |f| f.puts data}
  end

end
