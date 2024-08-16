unit module FF::Classes;

role FontRole is export {
    has $.number is required;
    # more attributes required
}

class Font does FontRole is export {
    has $.font; # when Font is "loaded" at first use
}

role DocRole is export {
    has Numeric $.size   is required;
    has UInt    $.number is required;
}

class DocFont is Font does DocRole is export  {
    has $.face; # value set in TWEAK
}

