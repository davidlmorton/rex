package Tool::F;

use strict;
use warnings FATAL => 'all';

use UR;

class Tool::F {
    is => 'Tool::Base',

    has_input => [
        fi1 => {},
    ],

    has_output => [
        fo1 => {},
    ],
};


1;
