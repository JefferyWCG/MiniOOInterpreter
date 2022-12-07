dir="./traces"


# compute the sum from 1 to 100
seq_test1="var x; var y; var z;
  {z=proc a:while x<a then {x=x+1;y=y+x} end ;
   {x=0; {y=0;z(15)}}}; "

../src/interpreter -m "$seq_test1" > "$dir/test1_trace.txt"


# compute the sum from 1 to 100 using recursion (tail recursive)
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
../src/interpreter -m "$seq_test2" > "$dir/test2_trace.txt"


# print 1 to 10 then print 10 to 1 using recursion
seq_test2="
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
../src/interpreter -m "$seq_test2" > "$dir/test3_trace.txt"

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

../src/interpreter -m "$field_test1" > "$dir/field_test1.txt"

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

../src/interpreter -m "$field_test2" > "$dir/field_test2.txt"


