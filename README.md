# Pushover
Pushover is a **programming language which compiles into a pushdown automaton.**
It's essentially an experiment as to how Turing-complete a language can _feel_
while actually compiling into a non-Turing-complete construct, in this case a
non-deterministic pushdown stack automaton.

Pushover is a stack-based programming language. If you've ever used Forth or
BibTeX's BST language, then this is extremely similar. Output is a GraphViz
DOT file for your automaton.

Output automata will behave so that, given an input string, 
the program result is at the top of the stack, and the automaton and will finish
on an accepting state to show success. In the case of something invalid occuring,
the stack should be ignored, and that string will be rejected.

A somewhat interesting side effect of this is that, if converted to a grammar,
your program's automaton yields the language of inputs which will make the
program execute successfully.

Arithmetic is performed by hardcoded transition tables of numbers up to `2^n - 1`
for Pushover running in `n`-bit arithmetic mode. The automaton's Σ is
`{0, 1, 2, ..., 2^n - 1, T, F, U}`.

So far, there's no actual syntax, but it will look like this when implemented 
for a program which reads two input numbers and adds them:

```
take take + accept
```

Conditionals will work with the additional `T` and `F` symbols in Σ. For
example, suppose we wanted to detect overflow in that program and reject it:

```
take take +c? jump(carried) accept
[carried: reject] 
```