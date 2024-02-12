Here is a list of bad example of error messages found in code


----------------

```
    private JSONWriter append(String string) throws JSONException {
        if (string == null) {
            throw new Exception("Null pointer");
        }
        . . . more code
       }
```

The exception just says "Null Pointer".  If you are watching a program run, and what appears is "Null Pointer" you have not enough information to go on.  What pointer was it?  That is kind of important to knowing what to do.  What context was this null pointer found?  Again, critical information needed to solve the problem.   This is just as bad as the Java language exception NullPointerException which tells you nothing about what was going on.

This method is expected to append something, and if it fails to do so, it should explain that.  the message should be something like which explains that append failed, and includes some detail about what it was not able to do:

```
    "Unable to append to JSONWriter.  Null value is not allowed"
```


-----------------------------

