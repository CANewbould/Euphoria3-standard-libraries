# Euphoria3-standard-libraries

This repository holds equivalents of the OE4 standard library for use with the RDS Euphoria Interpreter.

A discontinuity was created between the various Rapid Deployment Software (RDS) versions of Euphoria and those from the Open Euphoria (OE) project as a result of the decision made by the latter's developers to use "standard" libraries as repositories for the additional functionality beyond the core language bound into the Interpreter.

In the RDS repository the modules sat in the *include* folder, whereas the OE ones are stored in a *std* sub-folder. Moreover, even where the latter correspond to the former the code within is not always, or even often, backwards-compatible.

Consequently users of the RDS version of Euphoria cannot readily use software written in OE, even if there is no technical reason to stop it. Adaptation, as a minimum, involves significant re-coding. This repository offers a set of "standard" modules which correspond to those in the OE library extension modules, both in name and functionality, thus enabling RDS users to exploit calls to "standard" libraries in a totally equivalent way, and access parallel functionality to OE users.

Note, however, that the OE Core (embedded in the Interpreter) is significantly larger than the RDS Core, so this project cannot ever offer a complete solution to those users wedded to their RDS Interpreter.

The repository contains library modules with the same names as those in the OE distribution, each containing parallel routine names and value names.

These modules are an incomplete substitute for the OE equivalents and always, to varying extents, will remain so. Part of the project's development, however, is to continue to close the gap as much as possible.

To show the progression of ideas the repository contains not one but four folders, each showing a stage in the development process:

* euphoria311
* euphoria312
* euphoria320
* euphoria321

The folder *euphoria311* contains the minimal RDS Euphoria.

The folder *euphoria312* contains the additional functionality RDS added through its own included modules, but re-cast so that each element (routine, type or value) is re-positioned in a file carrying the exact same name as is used in the OE versions. In short, each library module in *euphoria312/include/std* is a cut-down version of its OE equivalent, but using only the contents of the RDS Interpreter to define the "equivalence".

The folder *euphoria320* contains content which is largely the same as in *euphoria312* but with the defining code, where possible, modified to reflect the way the corresponding code is written in the OE equivalent. (It is really a technical exercise - to show the nature of the transition - and shouldn't really be used operationally.)

The folder *euphoria321* extends the modules in *euphoria312* to add, wherever possible, the additional values and routines provided in OE. So, for most practical purposes, this folder is the one that should be **used** by RDS users attempting to run code devised for OE versions.

Note that all versions of the RDS Interpreter, and most of the OE versions are 32-bit. No guarantees can be given if a 64-bit version of the OE Interpeter is used with these library modules!

Each folder contains a small "readme" file, explaining the contents of the folder.

Examples of using each version are included in a *demos* folder under each staged version. As well as including the original demo files supplied with the RDS distribution, suitably positioned between the versions, there is a set of examples where, instead of incorporating illustrative examples into the embedded documentation of each standard library module, these examples are played out in a "demo". So, for example, the file *demos/math.ex* contains within it all the illustrative examples shown in the Open Euphoria documentation for the *std/math.e* module.

Additionally, to make running these examples easier, a batch file *eu3.bat* is provided in each *demos* folder to set the relevant parameters and call the appropriate interpreter. (These act a little like the Open Euphoria *eu.cfg* files.)
