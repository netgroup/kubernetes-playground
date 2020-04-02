# ext directory for projects using kubernetes playgound

External projects can create their own directory here.
The files and directory under `ext` are not synced with this git
repository.

Taking an example external project called kites, this is the recommended
directory structure:

| Directory   | Usage |
| `ext/kites` | Use a separated directory for your project |
| `ext/kites/scripts` | Use sub directory for different script types |
| `ext/kites/scripts/linux` | Linux scripts |
