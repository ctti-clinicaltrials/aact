# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
UseCase.create! :status => 'public', :title=> 'Karens SAS Analysis', :submitter_name => 'Karen Chiswell', :email => 'karen.chiswell@duke.edu', :brief_summary => 'SAS analysis of snapshot data'
UseCase.create! :status => 'public', :title=> 'EEG-related Studies', :submitter_name => 'Sheri Tibbs', :email => 'sheri.tibbs@gmail.com', :brief_summary => 'Identify where EEG-related clinical trials are being conducted, the distribution of these studies by sponsor type, and the investigators responsible for this research. Present findings via visualizations.', :url => 'http://clinwiki.herokuapp.com/'
UseCase.create! :status => 'public', :title=> 'Clinwiki', :submitter_name => 'Willy Hoos', :email => 'william.hoos@gmail.com', :brief_summary => 'A public platform that allows domain experts to review, rank and annotate clinical trials. The system also provides a way to tag trials', :url => 'http://clinwiki.herokuapp.com/'

