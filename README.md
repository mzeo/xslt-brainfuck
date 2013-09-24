xslt-brainfuck
==============

Brainfuck interpreter in xslt.

Some one said it would be stupid, so I couldn't resist. It allows you to
embed brainfuck code in xhtml. It uses XSLT to evaluate the brainfuck code.

This implementation uses 8bit two's complement memory. The amount of
memory have been set to fixed 128bytes (Hey, it was enough for Atari VCS). It
would be simple increase it, but it would be nice to have something
dynamic.

EOF is default marked as "no change". It can be configured to something else.

Example
-------

```xml
<p class="code">
	<!-- This will get replaces with the output of the program -->
	<bf:brainfuck xmlns:bf="https://github.com/mzeo/xslt-brainfuck">
		<!-- Optional input -->
		<bf:input>Hello world</bf:input>
		<!-- Optional EOF marker. Without it will be "no change" -->
		<bf:eof>0</bf:eof>
		<!-- Required program to run -->
		<bf:main>
			,[.,]
		</bf:main>
	</bf:brainfuck>
</p>
```

Implementation
--------------
It was mostly straight forward to implement. The real trick was how to
get around the recursion limits in XSLT.

It gets around recursion limits by using <em>fibonacci recursion</em> (fib-step).
<em>Fibonacci recursion</em> was invented here. There is no reason
for the recursion pattern to resemble recursive fibonnaci code. It only
needs to something exponential, but I though it was fun.

What it does is that it recures in a "tree" type of recursion by sending
the complete state around. The "tree" is recursed a bit deeper each fib-step.
In fib-step one and two it will take one actual step. In fib-step three it will
take two steps, and then three, and then five, and then eight, ...

For a proper explanation please look at the code. I've already spent too much
time on this already.

Typos
-----
There is probably lots of them. I was tired writing this.

