# Seashell

Seashell is a library for coding modularized shell(bash/zsh) script. Also, it has some useful module to help us to program shell script as a project. For purpose, I only want to manage my game script because i played steam games(dota2) in the linux container(docker/lxd). But I found I already have had too many script to organize.

So, the target of seashell:

- modular programming
- projectized script
- some useful module
- ... ...
- manger the script of game in the container (my original intention)

### Installation

1. Clone the repository

   ```shell
   cd $somewhere
   git clone https://github.com/chongwish/seashell $name_you_want
   ```

2. Define a global variable of the absolute path of seashell

   ```shell
   echo 'export SEASHELL_HOME=$somewhere/$name_you_want' > ~/.profile # profile or bashrc or zshrc
   ```

3. Source it in your entry file

   ```shell
   source $SEASHELL_HOME/seashell.sh
   ```

### Usage

##### Structure

```shell
Seashell
├── drop         # test
├── pearl        # core
├── swim         # target script
└── water        # system module
    ├── Module1
    └── Module2

Project-Demo
├── script_name  # user target script 
├── Module1      # user module
└── Module3      # user module
```

##### Define module

Nothing need to do. We just organize the module by directory.  If we write a function in a module:

```shell
# File: Module1
function fn1() {
	fn2
}
function fn2() {
	echo "haha"
}
function fn3() {
	echo "hahaha"
}
```

That is all we define a module which name "Module1", we call the function normally in the same module.

##### Include module

Using a module have been defined, we can do like this:

```shell
# File: script_name
include Module1
```

Functions in the module will be imported to the current script, and it will not make the current namespace mess. Because these imported function will be with their namespace:

```shell
Module1.fn1 # haha
Module2.fn2 # haha
```

##### Import function

Sometimes, we don't like write the imported function with their tedious namespace everytime. We could use the import function:

```shell
# File: script_name
import Module1
```

Then, we can call these imported function just like they had been defined in the current namespace:

```shell
fn1 # haha
fn2 # haha
```

Maybe the module "Module1" had defined a function name as same as the current namespace, a conflict will be appear:

```shell
# File: script_name
function fn1() {
	echo "What the fuck now?"
}
```

It has a easy way to resolve it -- only import the function we need:

```shell
# File: script_name
import Module1[fn2 fn3]
fn1 # What the fuck now?
fn2 # haha
```

##### Object

Shell script  don't support object originally. It is a good experience if we can new a module as a object. It will not cause a function conflect here. I use a dirty way to do it:

```shell
# File: script_name
`new v1=Module1`
${v1[fn1]} # haha
```

##### Exit

When a wrong happen, I wish the script can exit no matter where is it,  in subprocess or in pipe.

```shell
panic "Something wrong happen!"
panic ERROR_TYPE "Something wrong happend"
```

##### Lambda

Shell allow us pass a string as a name of function to call. But when I add namespace for function, I found it is difficult for me. So I must force to use 'lambda' as a function markup if it is a normal string.

```shell
# File: script_name
import Collection.Array

function show() {
	echo $1
}
declare -a abc=("hello" "how are you")

$(for_each abc `lambda show`) # or, `for_each abc $(lambda show)`
```

##### Standalone script

Most often, I write a script using seashell as I can do a modular programming. But, we don't like put this script I has written to a remote server and then run it with many framework files. So there is a function for archiving a standalone script:

```shell
# File: script_name
archive $another_module_script_file > 1.sh # 1.sh file will include all modules it need
bash 1.sh
```

### Restraint

##### Shell Version Requirement

- bash >= 4.2
- zsh >= 5.0

##### Namespace

I am so gloomy to decide to use a ugly namespace because of the limitation of zsh and bash. If we want to use these namespace module, We need use "include" function  or "import" function to load it first.

##### Higher Order Function

If you are accustomed to functional programming, you have known higher order function coding is a pleasant experience. But here, we must let the seashell know that it is higher order function. For example: there is a function which name is 'fn', it regard its first parameter as a function:

```shell
function fn() {
	$1 "haha"
}
function say() {
	echo $1
}
```

Now, we need to pass a function like that:

```shell
fn `lambda say`  # Or: fn $(lambda say)
```

##### Function Name

It is not a strict rule. We had better define a function name like other programing language(start with alphabet or "\_", the other char can be alphabet or "\_" or digit).

```shell
find::something # fault
find.something # fault
find_something # ok
```

##### Gloomy quit

I found many  ways to exit gracefully, but failed! It's a strange way that we can exit a script anywhere but in pipe or in subprocess. Pipe and subprocess are so usual that we can not only write a script without it. I try bash-oo-framework and think it is a good idea, and i don't use 'read' just like it because i want to exit anywhere if i really decide to exit.

##### Todo

There are a lot of things need to extend...

### Sample

There are few examples in 'drop' and 'swim' directories to show how seashell work.

- test_archive.sh

  ```shell
  local> bash test_archive.sh test_lxd_intel_archlinux.sh > create_archlinux_lxd.sh
  # sftp create_archlinux_lxd.sh to remote server
  remote> bash create_archlinux_lxd.sh
  ```

- test_lxd_intel_archlinux.sh

  Using archlinux image to create a lxd container with X and intel video driver.

- test_lxd_nvidia_steam.sh

  Using ubuntu image to create a lxd container with X and nvidia video driver and steam.

- emacs.sh

  Run emacs in the container if we had created a container with X.

- steam.sh

  Run steam in the container if we had created a container with X.

- firefox.sh

  Run firefox in the container if we had created a container with X.

- ... ...