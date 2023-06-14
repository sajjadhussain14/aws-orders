
<cfoutput>

<cfscript>
function ArrayReduce2(array, expression, initialValue) {
    return Evaluate(expression);
}

myArray = [
  {itemTax = 4},
  {itemTax = 6}
];

sum = ArrayReduce2(myArray, "currentTotal + item.itemTax", 0);

writeOutput("Total: #sum#");
</cfscript>
</cfoutput>
