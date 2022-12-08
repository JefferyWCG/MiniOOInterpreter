


# print an expression
arithmatic_test1="printf(1+(2+3)*2);"


# compute the sum from 1 to 15
seq_test1="var x; var y; var z;
  {z=proc a:while x<a then {x=x+1;y=y+x} end ;
   {x=0; {y=0;z(15)}}}; "



# compute the sum from 1 to 15 using recursion (tail recursive)
seq_test2="
var x;
var y;
var z;
  {z = proc a:
    if a==0 then skip
    else {x=x+a;z(a-1)}
  end;
  {x=0;
  {y=0;
  z(15)
  }}}; "



# print 1 to 10 then print 10 to 1 using recursion
seq_test3="
var x;
  {x = proc a:
    if a==11 then skip
    else
      {printf(a);
      {x(a+1);
      printf(a)}}
  end;
  x(1)
  }; "



#create objects  x,y,z and compute the sum of x."FOO"+ y."FOO", then store it to z."FOO"
field_test1="
var x; var y; var z; var f;
     {malloc(x);
     {malloc(y);
     {malloc(z);
     {f = FOO;
     {x.f=10;
     {y.f=20;
     {z.f=x.f+y.f;
     printf((z.f))
     }}}}}}}; "



#create 3 objects and doing nested field assignment
field_test2="
var x; var y; var z; var f;
     {malloc(x);
     {malloc(y);
     {malloc(z);
     {f = FOO;
     {x.f=y;
     {x.f.f=QUX;
     {z.((x.f).f)=QUIZ;
     {printf(y);printf(z)

     }}}}}}}}; "



# create two interleaving control flow of race condition on variable x
# the result print(x) is non-deterministic
paralell_test1="
var x; var y; var z; var a; var b;
     {x = 1;
     {a = 10;
     {b = 10;
     {y = proc n: while 0<a then {a=a-1;x=x+1} end;
     {z = proc n: while 0<b then {b=b-1;x=x*10} end;
     { {y(10) ||| z(10)};
      printf(x)
    }}}}}}; "



# create a race condition on variable x, However, the operation is mutative(idempotent)
# so eventually print(x) will print 15
paralell_test2="
var x; var y; var z; var a; var b;
     {x = 15;
     {a = 10;
     {b = 10;
     {y = proc n: while 0<a then {a=a-1;x=x+1} end;
     {z = proc n: while 0<b then {b=b-1;x=x-1} end;
     { {y(10) ||| z(10)};
      printf(x)
    }}}}}}; "



# atmoic tests, similar to test 1 but both control flow is atomic
# the result print(x) is either "110 000 000 000" or "10 000 000 010"
paralell_test3="
var x; var y; var z; var a; var b;
     {x = 1;
     {a = 10;
     {b = 10;
     {y = proc n: while 0<a then {a=a-1;x=x+1} end;
     {z = proc n: while 0<b then {b=b-1;x=x*10} end;
     { {atom(z(10)) ||| atom(y(10))};
      printf(x)
    }}}}}}; "



# scope error
# use variable not decline
scope_error_test1="
var x;y=10;
"



# scope error
# use variable declared but not in scope
scope_error_test2="
var x;
{var y;skip;
 y=10};
"

# assign(access) a field of a non-Object variable
runtime_error_test1="
var x; var f;
  {f = FOO;
   x.f =1
  };
"

# access a non-assigned field of a Object variable
runtime_error_test2="
var x; var f;
  {f = FOO;
  {malloc(x);
   printf(x.f)
  }};
"


dir="./traces"
mkdir traces traces/arithmatic traces/control_flow traces/field traces/paralell traces/scope_error traces/runtime_error

../src/interpreter -m "$arithmatic_test1" > "$dir/arithmatic/test1.txt"

../src/interpreter -m "$seq_test1" > "$dir/control_flow/test1.txt"
../src/interpreter -m "$seq_test2" > "$dir/control_flow/test2.txt"
../src/interpreter -m "$seq_test3" > "$dir/control_flow/test3.txt"

../src/interpreter -m "$field_test1" > "$dir/field/test1.txt"
../src/interpreter -m "$field_test2" > "$dir/field/test2.txt"

../src/interpreter -m "$paralell_test1" > "$dir/paralell/test1.txt"
../src/interpreter -m "$paralell_test2" > "$dir/paralell/test2.txt"
../src/interpreter -m "$paralell_test3" > "$dir/paralell/test3.txt"

../src/interpreter -m "$scope_error_test1" 2> "$dir/scope_error/test1.txt"
../src/interpreter -m "$scope_error_test2" 2> "$dir/scope_error/test2.txt"

../src/interpreter -m "$runtime_error_test1" > "$dir/runtime_error/test1.txt"
../src/interpreter -m "$runtime_error_test2" > "$dir/runtime_error/test2.txt"






