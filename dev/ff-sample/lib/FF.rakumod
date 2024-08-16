unit class FF;

use FF::Classes;

has FontClass %.font-classes; # keyed by: font-class-number
has DocFont   %.doc-fonts;    # keyed by: <font-class-number|size>
