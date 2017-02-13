# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
UseCase.create! :status => 'public', :title=> 'SAS analysis of secondary outcome outliers', :submitter_name => 'Karen Chiswell', :email => 'karen.chiswell@duke.edu', :brief_summary => 'Analyze secondary outcome outliers'
UseCase.create! :status => 'public', :title=> 'EEG-related Studies', :submitter_name => 'Sheri Tibbs', :email => 'sheri.tibbs@gmail.com', :brief_summary => 'Visually display the geographic distribution of EEG-related clinical trials - reveal where they are being conducted, the distribution of these studies by sponsor type, and the investigators responsible for this research.', :url => 'http://eeg-studies.herokuapp.com/index.html'
UseCase.create! :status => 'public', :title=> 'Clinwiki', :submitter_name => 'Willy Hoos', :email => 'william.hoos@gmail.com', :brief_summary => 'A public platform that allows domain experts to review, rank, annotate and tag clinical trials.', :url => 'http://clinwiki.herokuapp.com/'

