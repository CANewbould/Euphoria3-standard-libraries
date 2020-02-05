# Euphoria3-standard-libraries
OE4 standard library equivalents for RDS Euphoria

A distinction was made between the various Rapid Deployment Software (RDS) versions of Euphoria and those from the Open Euphoria (OE) project as a result of the decision to use "standard" libraries as repositories for the additional functionality beyond the core language bound into the Interpreter.

In the RDS repository the modules sat in the **include** folder, whereas the OE ones are stored in a **std** sub-folder. Moreover, even where the latter correspond to the former they code within is not always, or even often, backwards-compatible.

Consequently users of the RDS version of Euphoria cannot readily use software written in OE, even if there is no technical reason to stop it, without, as a minimum, significant re-coding. This repository offers a set of "standard" modules which correspond to those in the OE library extension modules, both in name and functionality, thus enabling RDS users to exploit calls to libraries in a **std** sub-folder and access parallel functionality to OE users.

Note, however, that the OE Core (embedded in the Interpreter) is significantly larger than the RDS Core, so this project cannot ever offer a complete solution to those users wedded to their RDS Interpreter.

The repository contains, in the **std** sub-folder of **include** modules with the same names as those in the OE distribution, and containing parallel routine names and value names.

These modules are an incomplete substitute for the OE equivalents and always, to varying extents, will this remain so. Part of the project's development, however, is to continue to close the gap as much as possible.

To show the progression of ideas the repository contains not one but four folders, each showing a stage in the development process:

* euphoria311
* euphoria312
* euphoria320
* euphoria321

The folder **euphoria311** contains the minimal RDS Euphoria.

The folder **euphoria312** contains the additional functionality RDS added through its included modules, but re-cast so that each element (routine, type or value) is re-positioned in a file carrying the exact same name as is used in the OE versions. In short, each library module in **euphoria312/include/std** is a cut-down version of its OE equivalent, but using only the contents of the RDS Interpreter to define the "equivalence".
