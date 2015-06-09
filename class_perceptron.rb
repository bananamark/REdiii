#this is an example to evaluate the most powerful machine learning sequence for APOBEC structure solution
#Parameters we change actively for now are
#number/mass
#search_model
#(spacegroup)


class Perceptron

  def spacegroup_learned (protein, number, mypath)

    data_set = []
    CSV.foreach(File.open("#{my_path}/database.db", 'r')) do |row|
     data_set << row[0..2]
    end

    data_labels = data_set.shift

    data_set = Ai4r::Data::DataSet.new(:data_items=>data_set, :data_labels=>data_labels)


    classifier = Ai4r::Classifiers::MultilayerPerceptron.new.build(data_set)


    classifier.get_rules

    protein = protein
    number = number
    spacegroup = nil

    return classifier.eval([protein, number])

    end
end
