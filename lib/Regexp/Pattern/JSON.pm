package Regexp::Pattern::JSON;

# DATE
# VERSION

our %RE;

$RE{number} = {
    summary => 'Match a JSON number literal',
    pat => qr{(?:
  (
    -?
    (?: 0 | [1-9][0-9]* )
    (?: \. [0-9]+ )?
    (?: [eE] [-+]? [0-9]+ )?
  )
    )}x,
    examples => [
        {str=>'12', matches=>1},
        {str=>'-34', matches=>1},
        {str=>'1.23', matches=>1},
        {str=>'-1.23e2', matches=>1},
    ],
};

$RE{string} = {
    summary => 'Match a JSON string literal',
    pat => qr{(?:
    "
    (?:
        [^\\"]+
    |
        \\ [0-7]{1,3}
    |
        \\ x [0-9A-Fa-f]{1,2}
    |
        \\ ["\\/bfnrt]
    #|
    #    \\ u [0-9a-fA-f]{4}
    )*
    "
    )}xms,
    examples => [
        {str=>q(""), matches=>1},
        {str=>q(''), matches=>0, summary=>"Single quotes are not string delimiters"},
        {str=>q("\\n"), matches=>1},
        {str=>q("contains \\" double quote"), matches=>1},
    ],
};

our $define = qr{

(?(DEFINE)

(?<OBJECT>
  \{\s*
    (?:
        (?&KV)
        \s*
        (?:,\s* (?&KV))*
    )?
    \s*
  \}
)

(?<KV>
  (?&STRING)
  \s*
  (?::\s* (?&VALUE))
)

(?<ARRAY>
  \[\s*
  (?:
      (?&VALUE)
      (?:\s*,\s* (?&VALUE))*
  )?
  \s*
  \]
)

(?<VALUE>
  \s*
  (?:
      (?&STRING)
  |
      (?&NUMBER)
  |
      (?&OBJECT)
  |
      (?&ARRAY)
  |
      true
  |
      false
  |
      null
  )
  \s*
)

(?<STRING> $RE{string}{pat})

(?<NUMBER> $RE{number}{pat})

) # DEFINE

}xms;

$RE{array} = {
    summary => 'Match a JSON array',
    pat => qr{(?:
    (?&ARRAY)
$define
    )}xms,
    examples => [
        {str=>q([]), matches=>1},
        {str=>q([1, true, "abc"]), matches=>1},
        {str=>q([1), matches=>0, summary=>"Missing closing bracket"},
    ],
};

$RE{object} = {
    summary => 'Match a JSON object (a.k.a. hash/dictionary)',
    pat => qr{(?:
    (?&OBJECT)
$define
    )}xms,
    examples => [
        {str=>q({}), matches=>1},
        {str=>q({"a":1}), matches=>1},
        {str=>q({"a":1), matches=>0, summary=>"Missing closing curly bracket"},
        {str=>q({a: 1}), matches=>0, summary=>"Unquoted key"},
    ],
};

$RE{value} = {
    summary => 'Match a JSON value',
    pat => qr{(?:
    (?&VALUE)
$define
    )}xms,
    examples => [
        {str=>q(true), matches=>1},
        {str=>q([]), matches=>1},
        {str=>q({}), matches=>1},
        {str=>q(-1), matches=>1},
        {str=>q(""), matches=>1},
    ],
};

1;
# ABSTRACT: Regexp patterns to match JSON

=head1 SEE ALSO

L<JSON::Decode::Regexp>

L<Regexp::Common::json>
