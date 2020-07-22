# On or just after the first of the month, move all files in 'daily' directories to a temporary archive & move files create on 1st of month to 'monthly' dir. Then clear out the daily dir.

# First, clear out archive directories of everything except first-of-month files
cd /aact-files/static_db_copies/archive ; find . ! -name '*01_*' -type f -exec rm -f {} +
cd /aact-files/exported_files/archive ; find . ! -name '*01_*' -type f -exec rm -f {} +

# In 'daily' directories: copy all files to archive directory, move first-of-month file to monthly dir, then remove all daily files except first-of-month
cd /aact-files/static_db_copies/daily ; cp * ../archive ; mv *01_* ../monthly ; find . ! -name '*01_*' -type f -exec rm -f {} +
cd /aact-files/exported_files/daily ; cp * ../archive ; mv *01_* ../monthly ; find . ! -name '*01_*' -type f -exec rm -f {} +
