# MLFlow Test

Test of the [mlflow project](https://github.com/databricks/mlflow)

# How to run the test

Start the mlflow server:
```
make server
```

Run the training script:
```
make train
```

Or, with params for the model:
```
make train TRAIN_ARGS="<alpha> <l1 ratio>"
```

E.g.:
```
make train TRAIN_ARGS="0.5 0.5"
```

Then, go to localhost:5000 (or whatever port you specified in the Makefile) to view the experiment results.

Note: This test is built to run on Windows and will not work on any other operating system without modifying
the Makefile.
