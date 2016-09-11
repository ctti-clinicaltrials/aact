Contributing to the Project
###########################

The AACT project uses a fork and pull-request contribution model.  Developers
wishing to use github to contribute to the project should fork the
['official' repo](https://github.com/ctti-clinicaltrials/aact) into your
personal github account.  You should then set up a 'development' branch, if it does
not already exist.  You can (and should) delete the 'production' branch if it
exists, as we will never allow pull requests into production from forked repos.
Also, you should set your default branch in your github repo to 'development' if it
is set to 'master' or something else, and delete master if it exists (we will not
use master).

You should then clone your personal fork into your workstation, and use it
to develop changes. You can create as many branches in your local, or
forked repo, but these should never be pushed to official unless there is a
very good reason for doing so.

Once you are ready to submit your changes to the official repo, merge them into
your 'development' branch, and then submit a pull request from your 'development' to
the official 'development' branch **MAKE SURE NOT TO CREATE A PR TO PRODUCTION**

Add the official repo for fetches
---
Once you have cloned your fork into your working directory, it is useful to
perform the following commands, using the git commandline:
```
git remote add official git@github.com:ctti-clinicaltrials/aact.git
git remote set-url --push official donotpush
```

This allows you to fetch from official and merge those changes into your branches,
but does not allow you to accidentally push anything to official.

There are ways to configure gui clients this way too, but this is beyond the scope
of this document.

Converting existing clones of official
---
For developers that have been working directly off of the official repo,
and want to convert their existing clones to work this way, run the following:
```
git remote remove origin
git remote add origin ${PERSONAL_GIT_REPO_URL}
```
